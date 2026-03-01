import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonPosition,
  ArcButtonStyleMode,
  ColorMetrics,
  LengthMetrics,
  LengthUnit
} from '@kit.ArkUI';
import { Theme } from 'core';
import { PaymentIndexViewModel, PaymentState } from '../../pages/qr/viewmodel/PaymentIndexViewModel';

@Component
export struct PaymentActionButtons {
  @ObjectLink viewModel: PaymentIndexViewModel;

  build() {
    Column() {
      if (this.viewModel.currentState === PaymentState.nfcNotSupported) {
        ArcButton({
          options: new ArcButtonOptions({
            label: $r('app.string.payment_continue_qr'),
            position: ArcButtonPosition.BOTTOM_EDGE,
            styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
            backgroundColor: ColorMetrics.resourceColor('#ffb8ff00'),
            shadowEnabled: true,
            fontSize: new LengthMetrics(Theme.FontSize.large, LengthUnit.FP),
            onClick: () => {
              this.viewModel.continueWithQr();
            }
          })
        });
      } else if (this.viewModel.currentState === PaymentState.nfcDisabled) {
        ArcButton({
          options: new ArcButtonOptions({
            label: $r('app.string.payment_open_nfc_settings'),
            position: ArcButtonPosition.BOTTOM_EDGE,
            backgroundColor: ColorMetrics.resourceColor('#ffb8ff00'),
            styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
            shadowEnabled: true,
            fontSize: new LengthMetrics(Theme.FontSize.large, LengthUnit.FP),
            onClick: () => {
              this.viewModel.openNfcSettings();
            }
          })
        });
      }
    }
    .position({ x: 0, y: 200 })
    .width('100%')
    .height('100%');
  }
}