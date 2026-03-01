import { NavigationManager, Theme } from 'core';
import { common } from '@kit.AbilityKit';
import { CardItemModel } from '../../../model/CardItemModel';
import { BUS_CARDS_DUMMY } from '../viewModel/CardData';

const deviceSize: number = 466;

@Component
export struct BalancePage {
  private pathStack: NavPathStack = new NavPathStack();
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  @Builder
  cardItemContent(item: CardItemModel) {
    Column() {
      Row() {
        Text(item.title)
          .fontSize(Theme.FontSize.medium)
          .fontColor(Color.White)
          .fontWeight(Theme.Weight.bold);

        Blank();

        Path()
          .commands('M21.53 7.15A15.93 15.93 0 0012 4C7.63 4 3.65 5.76.47 8.59l1.42 1.42A13.91 13.91 0 0112 6c3.85 0 7.34 1.55 9.88 4.06l1.42-1.42a17.88 17.88 0 00-1.77-1.49zM17.43 11.23A9.95 9.95 0 0012 9c-2.76 0-5.26 1.12-7.07 2.93l1.42 1.42A7.95 7.95 0 0112 11c2.21 0 4.21.9 5.65 2.34l1.42-1.42a11.9 11.9 0 00-1.64-1.69zM13.34 15.31A3.98 3.98 0 0012 14c-1.1 0-2.1.45-2.83 1.17l1.42 1.42c.36-.36.86-.59 1.41-.59.55 0 1.05.23 1.41.59l1.42-1.42a5.96 5.96 0 00-1.49-1.28zM12 19a2 2 0 100-4 2 2 0 000 4z')
          .fill(Color.White)
          .width(20)
          .height(20)
          .opacity(0.8);
      }
      .width('100%')
      .alignItems(VerticalAlign.Top);

      Blank();

      Column() {
        Text('Balance')
          .fontSize(12)
          .fontColor('#EEEEEE')
          .opacity(0.8)
          .width('100%')
          .textAlign(TextAlign.Start);

        Text(item.balance)
          .fontSize(24)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bolder)
          .width('100%')
          .textAlign(TextAlign.Start);

        Text(`**** **** **** ${item.cardNumber.slice(-4)}`)
          .fontSize(12)
          .fontColor(Color.White)
          .opacity(0.7)
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 });
      }
      .width('100%');
    }
    .width(`${deviceSize * 0.75}px`)
    .height(`${deviceSize * 0.48}px`)
    .padding(20)
    .backgroundColor(item.color)
    .borderRadius(16)
    .shadow({ radius: 10, color: '#40000000', offsetY: 5 })
    .onClick(() => {
      NavigationManager.getInstance().pageInfos.pushPath({
        name: 'balanceDetail',
        param: item
      });
    });
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Swiper() {
          ForEach(BUS_CARDS_DUMMY, (item: CardItemModel) => {
            Column({ space: 15 }) {
              this.cardItemContent(item);

              Row({ space: 20 }) {
                Button({ type: ButtonType.Circle }) {
                  Text('QR')
                    .fontSize(12)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold);
                }
                .width(40)
                .height(40)
                .backgroundColor('#333333')
                .onClick(() => {
                  NavigationManager.getInstance().pageInfos.pushPath({
                    name: 'QrPay'
                  });
                });

                Button({ type: ButtonType.Circle }) {
                  Text('NFC')
                    .fontSize(12)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold);
                }
                .width(40)
                .height(40)
                .backgroundColor(item.color)
                .onClick(() => {
                  NavigationManager.getInstance().pageInfos.pushPath({
                    name: 'NfcPay',
                    param: item
                  });
                });
              };
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          }, (item: CardItemModel) => item.id);
        }
        .width('100%')
        .height('100%')
        .loop(false)
        .indicator(
          Indicator.dot()
            .itemWidth(6)
            .itemHeight(6)
            .selectedItemWidth(8)
            .selectedItemHeight(8)
            .color(Color.Gray)
            .selectedColor(Color.White)
        );
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black);
    }
    .hideTitleBar(true);
  }
}