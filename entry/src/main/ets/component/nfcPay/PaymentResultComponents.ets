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
import { PaymentResultViewModel } from '../../pages/qr/viewmodel/PaymentResultViewModel';

@Component
export struct PaymentResultIcon {
  @ObjectLink viewModel: PaymentResultViewModel;

  build() {
    if (this.viewModel.isSuccess()) {
      Image($r('app.media.paymentSuccess'))
        .width(90)
        .height(90)
        .objectFit(ImageFit.Contain)
        .opacity(this.viewModel.animationOpacity);
    } else {
      Image($r('app.media.paymentFailed'))
        .width(90)
        .height(90)
        .objectFit(ImageFit.Contain)
        .opacity(this.viewModel.animationOpacity);
    }
  }
}

@Component
export struct PaymentResultTitle {
  @ObjectLink viewModel: PaymentResultViewModel;

  build() {
    if (this.viewModel.isSuccess()) {
      Text($r('app.string.payment_success_title'))
        .fontSize(Theme.FontSize.large)
        .fontColor(Theme.Colors.primaryDarkGreen())
        .fontWeight(Theme.Weight.bold)
        .textAlign(TextAlign.Center)
        .opacity(this.viewModel.animationOpacity);
    } else {
      Text($r('app.string.payment_failed_title'))
        .fontSize(Theme.FontSize.large)
        .fontColor(Theme.Colors.homePayQrButton())
        .fontWeight(Theme.Weight.bold)
        .textAlign(TextAlign.Center)
        .opacity(this.viewModel.animationOpacity);
    }
  }
}

@Component
export struct PaymentResultMessage {
  @ObjectLink viewModel: PaymentResultViewModel;

  build() {
    if (this.viewModel.isSuccess()) {
      Text($r('app.string.payment_success_message'))
        .fontSize(Theme.FontSize.small)
        .fontColor(Theme.Colors.textPrimary())
        .textAlign(TextAlign.Center)
        .width('85%')
        .margin({ top: Theme.Margin.small })
        .opacity(this.viewModel.animationOpacity);
    } else {
      Text($r('app.string.payment_failed_message'))
        .fontSize(Theme.FontSize.small)
        .fontColor(Theme.Colors.textPrimary())
        .textAlign(TextAlign.Center)
        .width('85%')
        .margin({ top: Theme.Margin.small })
        .opacity(this.viewModel.animationOpacity);
    }
  }
}

@Component
export struct PaymentResultActionButtons {
  @ObjectLink viewModel: PaymentResultViewModel;

  build() {
    Column() {
      if (this.viewModel.isSuccess()) {
        ArcButton({
          options: new ArcButtonOptions({
            label: $r('app.string.payment_done'),
            position: ArcButtonPosition.BOTTOM_EDGE,
            styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
            backgroundColor: ColorMetrics.resourceColor(Theme.Colors.primaryDarkGreen()),
            shadowEnabled: true,
            fontSize: new LengthMetrics(Theme.FontSize.large, LengthUnit.FP),
            onClick: () => {
              this.viewModel.done();
            }
          })
        });
      } else {
        ArcButton({
          options: new ArcButtonOptions({
            label: $r('app.string.payment_try_again'),
            position: ArcButtonPosition.BOTTOM_EDGE,
            styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
            backgroundColor: ColorMetrics.resourceColor(Theme.Colors.homePayQrButton()),
            shadowEnabled: true,
            fontSize: new LengthMetrics(Theme.FontSize.large, LengthUnit.FP),
            onClick: () => {
              this.viewModel.done();
            }
          })
        });
      }
    }
    .position({ x: 0, y: 200 })
    .width('100%')
    .height('100%')
    .opacity(this.viewModel.animationOpacity);
  }
}