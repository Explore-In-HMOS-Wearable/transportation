import { PaymentResultViewModel } from '../viewmodel/PaymentResultViewModel';
import { common } from '@kit.AbilityKit';
import {
  PaymentResultIcon,
  PaymentResultMessage,
  PaymentResultTitle,
  PaymentResultActionButtons
} from '../../../component/nfcPay/PaymentResultComponents';
import { Theme, PaymentResult } from 'core';

@Builder
export function PaymentStatePageBuilder() {
  PaymentStatePage();
}

@Component
export struct PaymentStatePage {
  private pathStack: NavPathStack = new NavPathStack();
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State viewModel: PaymentResultViewModel = new PaymentResultViewModel(this.context);

  build() {
    NavDestination() {
      Stack() {
        Column() {
          PaymentResultIcon({ viewModel: this.viewModel });
          PaymentResultTitle({ viewModel: this.viewModel });
          PaymentResultMessage({ viewModel: this.viewModel });
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);

        PaymentResultActionButtons({ viewModel: this.viewModel });
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Center)
      .backgroundColor(Theme.Colors.globalBackground());
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack;
      this.viewModel.setPathStack(this.pathStack);

      const paymentResult = ctx.pathInfo.param as PaymentResult;
      this.viewModel.initialize(paymentResult);
    });
  }
}