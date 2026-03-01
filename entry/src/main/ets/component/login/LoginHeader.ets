import { Theme } from 'core';

@Component
export struct LoginHeader {
  build() {
    Column({ space: Theme.Margin.small }) {
      Text($r('app.string.welcome_title'))
        .fontSize(Theme.FontSize.title)
        .fontWeight(Theme.Weight.bold)
        .fontColor(Theme.Colors.textPrimary())
        .fontFamily(Theme.FontFamily.defaultFont);

      Text($r('app.string.login_subtitle'))
        .fontSize(Theme.FontSize.small)
        .fontWeight(Theme.Weight.regular)
        .fontColor(Theme.Colors.textSecondary())
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .padding({
          left: Theme.Padding.small,
          right: Theme.Padding.small
        });
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%');
  }
}