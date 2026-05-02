import { Theme } from 'core';

@Component
export struct QrCard {
  @Prop value: string = '';
  @Prop paymentId: string = '';

  build() {
    Column() {
      QRCode(this.value)
        .width(100)
        .height(100)
        .color(Theme.Colors.primaryGreen())
        .backgroundColor(Theme.Colors.textPrimary())
        .borderRadius(Theme.Radius.medium);

      Text(`${this.paymentId}`)
        .fontSize(12)
        .fontColor(Theme.Colors.primaryGreen())
        .maxLines(2)
        .padding({ left: 20, right: 20 })
        .margin({ top: 5 });

    }
    .margin({ bottom: 10 });
  }
}