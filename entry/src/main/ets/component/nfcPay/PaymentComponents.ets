import { Theme } from 'core';
import { PaymentState } from '../../pages/qr/viewmodel/PaymentIndexViewModel';

@Component
export struct PaymentStatusIcon {
  @Prop currentState: PaymentState;

  build() {
    if (this.currentState === PaymentState.processing) {
      LoadingProgress()
        .width(60)
        .height(60)
        .color(Theme.Colors.textPrimary());
    } else if (this.currentState === PaymentState.nfcNotSupported) {
      Image($r('app.media.noNfc'))
        .width(100)
        .height(100)
        .objectFit(ImageFit.Contain);
    } else if (this.currentState === PaymentState.nfcDisabled) {
      Image($r('app.media.disabledNfc'))
        .width(100)
        .height(100)
        .objectFit(ImageFit.Contain);
    } else {
      Image($r('app.media.loadingNfc'))
        .width(120)
        .height(120)
        .objectFit(ImageFit.Contain);
    }
  }
}

@Component
export struct PaymentStatusMessage {
  @Prop currentState: PaymentState;
  @Prop processingMessage: string;

  build() {
    if (this.currentState === PaymentState.processing) {
      Text(this.processingMessage)
        .fontSize(Theme.FontSize.large)
        .fontColor(Theme.Colors.textPrimary())
        .fontWeight(Theme.Weight.medium)
        .textAlign(TextAlign.Center)
        .width('80%');
    } else if (this.currentState === PaymentState.nfcNotSupported) {
      Text($r('app.string.payment_nfc_not_available'))
        .fontSize(Theme.FontSize.large)
        .fontColor(Theme.Colors.textPrimary())
        .fontWeight(Theme.Weight.bold)
        .textAlign(TextAlign.Center)
        .margin({ bottom: Theme.Margin.small });
    } else if (this.currentState === PaymentState.nfcDisabled) {
      Text($r('app.string.payment_nfc_disabled'))
        .fontSize(Theme.FontSize.large)
        .fontColor(Theme.Colors.textPrimary())
        .fontWeight(Theme.Weight.bold)
        .textAlign(TextAlign.Center);
    } else if (this.currentState === PaymentState.readyToPay) {
      Text($r('app.string.payment_ready_to_pay'))
        .fontSize(Theme.FontSize.xlarge)
        .fontColor(Theme.Colors.textPrimary())
        .fontWeight(Theme.Weight.bold)
        .textAlign(TextAlign.Center);
    } else {
      Text($r('app.string.payment_checking_nfc'))
        .fontSize(Theme.FontSize.large)
        .fontColor(Theme.Colors.textPrimary())
        .textAlign(TextAlign.Center);
    }
  }
}

@Component
export struct PaymentInfoText {
  @Prop currentState: PaymentState;

  build() {
    if (this.currentState === PaymentState.nfcNotSupported) {
      Text($r('app.string.payment_no_support_message'))
        .fontSize(Theme.FontSize.medium)
        .fontColor(Theme.Colors.textPrimary())
        .textAlign(TextAlign.Center)
        .width('80%');
    } else if (this.currentState === PaymentState.nfcDisabled) {
      Text($r('app.string.payment_disabled_message'))
        .fontSize(Theme.FontSize.medium)
        .fontColor(Theme.Colors.textPrimary())
        .textAlign(TextAlign.Center)
        .width('80%')
        .margin({ bottom: Theme.Margin.xs });
    } else if (this.currentState === PaymentState.processing) {
      Text($r('app.string.payment_do_not_move'))
        .fontSize(Theme.FontSize.medium)
        .fontColor(Theme.Colors.textPrimary())
        .textAlign(TextAlign.Center)
        .width('80%');
    } else if (this.currentState === PaymentState.readyToPay) {
      Text($r('app.string.payment_hold_near_pos'))
        .fontSize(Theme.FontSize.medium)
        .fontColor(Theme.Colors.textPrimary())
        .textAlign(TextAlign.Center)
        .width('80%');
    }
  }
}