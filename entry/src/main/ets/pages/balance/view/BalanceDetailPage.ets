import { ProductModel, Theme } from 'core';
import { CardItemModel } from '../../../model/CardItemModel';
import { BalanceDetailPageState } from '../state/BalanceDetailPageState';
import { BalanceDetailPageViewModel } from '../viewModel/BalanceDetailPageViewModel';
import { common } from '@kit.AbilityKit';
import { BalanceDetailPageStateEnum } from '../state/IBalanceDetailPageState';

@Component
export struct BalanceDetailPage {
  @State cardInfo: CardItemModel | null = null;
  @State state: BalanceDetailPageState = BalanceDetailPageState.initial();
  private viewModel: BalanceDetailPageViewModel = new BalanceDetailPageViewModel();
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    this.viewModel.addListener((newState: BalanceDetailPageState) => {
      this.state = newState;
    });

    this.viewModel.init(this.context);
  }

  aboutToDisappear(): void {
    this.viewModel.removeAllListeners();
  }

  @Builder
  amountButton(product: ProductModel) {
    Button({ type: ButtonType.Circle }) {
      Text(`₺${(product.microPrice!) / 1000000}`)
        .fontSize(16)
        .fontColor(this.state.selectedProduct?.id === product.id ? Color.White : '#999999')
        .fontWeight(FontWeight.Bold);
    }
    .width(65)
    .height(65)
    .backgroundColor(this.state.selectedProduct?.id === product.id ? this.cardInfo?.color : '#222222')
    .border({
      width: 2,
      color: this.state.selectedProduct?.id === product.id ? this.cardInfo?.color : '#444444'
    })
    .onClick(() => {
      this.viewModel.setSelectedProduct(product);
    });
  }

  @Builder
  actionButton(title: string, iconPath: string) {
    Row() {
      Path()
        .commands(iconPath)
        .fill(Color.White)
        .width(30)
        .height(30)
        .scale({ x: 1.5, y: 1.5 })
        .margin({ right: 10 });

      Text(title)
        .fontSize(14)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium);
    }
    .width('85%')
    .height(50)
    .backgroundColor('#1A1A1A')
    .borderRadius(25)
    .justifyContent(FlexAlign.Center)
  }

  build() {

    NavDestination() {
      if (this.state.state === BalanceDetailPageStateEnum.loading) {
        LoadingProgress();
      } else if (this.state.state === BalanceDetailPageStateEnum.error) {

      } else {
        Scroll() {
          Column({ space: 15 }) {
            if (this.cardInfo) {
              Text(this.cardInfo.title)
                .fontSize(Theme.FontSize.medium)
                .fontColor(Color.White)
                .fontWeight(Theme.Weight.bold)
                .margin({ top: 30 });

              Text(this.cardInfo.balance)
                .fontSize(32)
                .fontColor(this.cardInfo.color)
                .fontWeight(FontWeight.Bolder);

              Text('Add Money')
                .fontSize(12)
                .fontColor('#EEEEEE')
                .opacity(0.8)
                .margin({ top: 10 });

              List({ space: 5 }) {
                ForEach(this.state.productList, (item: ProductModel) => {
                  ListItem() {
                    this.amountButton(item);
                  };
                }, (item: ProductModel) => item.id?.toString());
              }
              .listDirection(Axis.Horizontal)
              .width('100%')
              .margin({ bottom: 10 });

              Button('Top Up')
                .width('85%')
                .height(50)
                .backgroundColor(this.cardInfo.color)
                .fontColor(Color.White)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 20 })
                .onClick(() => {
                  this.viewModel.createPurchase(this.context, this.state.selectedProduct!);
                });
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center);
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black);
      }
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.cardInfo = context.pathInfo.param as CardItemModel;
    });
  }
}

