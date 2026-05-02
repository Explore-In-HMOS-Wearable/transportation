import { NavigationManager, Theme } from 'core';
import { PaymentRouteItem } from '../../../model/PaymentRoute';
import { PaymentHomeViewModel } from '../viewmodel/PaymentHomeViewModel';

@Builder
export function PaymentHomePageBuilder() {
  PaymentHomePage()
}

@Component
export struct PaymentHomePage {

  @State private vm: PaymentHomeViewModel = new PaymentHomeViewModel();

  build() {
    NavDestination() {
      Column({ space: 15 }) {
        Text('Select Payment Method')
          .fontSize(Theme.FontSize.large)
          .fontColor(Theme.Colors.textPrimary())
          .margin({ top: 20 });

        Button(this.vm.actions[0].title, {
          type: ButtonType.Circle,
          stateEffect: false
        })
          .width(55)
          .height(55)
          .backgroundColor(Theme.Colors.homePayQrButton())
          .onClick(() => {
            NavigationManager.getInstance().pageInfos.pushPath({ name: this.vm.actions[0].route});
          });

        Button(this.vm.actions[1].title, {
          type: ButtonType.Circle,
          stateEffect: false
        })
          .width(55)
          .height(55)
          .backgroundColor(Theme.Colors.primaryGreen())
          .onClick(() => {
            NavigationManager.getInstance().pageInfos.pushPath({ name: this.vm.actions[1].route});
          });

      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.Colors.globalBackground())
      .width('100%')
      .height('100%');
    }.hideTitleBar(true);

  }
}
