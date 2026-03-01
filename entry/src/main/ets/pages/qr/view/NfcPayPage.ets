import { Theme } from 'core';
import { PaymentActionButtons } from '../../../component/nfcPay/PaymentActionButton';
import { PaymentInfoText, PaymentStatusIcon, PaymentStatusMessage } from '../../../component/nfcPay/PaymentComponents';
import { PaymentIndexViewModel } from '../viewmodel/PaymentIndexViewModel';
import { common } from '@kit.AbilityKit';

@Builder
export function NfcPayPageBuilder() {
  NfcPayPage();
}

@Component
export struct NfcPayPage {
  private pathStack: NavPathStack = new NavPathStack();
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State viewModel: PaymentIndexViewModel = new PaymentIndexViewModel(this.context);

  aboutToAppear(): void {
    this.viewModel.initialize();
  }

  aboutToDisappear(): void {
    this.viewModel.cleanup();
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          PaymentStatusIcon({ currentState: this.viewModel.currentState });
          PaymentStatusMessage({
            currentState: this.viewModel.currentState,
            processingMessage: this.viewModel.processingMessage
          });
          PaymentInfoText({ currentState: this.viewModel.currentState });
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start);

        PaymentActionButtons({ viewModel: this.viewModel });
      }
      .alignContent(Alignment.TopStart)
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.Colors.globalBackground());
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack;
      this.viewModel.setPathStack(this.pathStack);
    });
  }
}