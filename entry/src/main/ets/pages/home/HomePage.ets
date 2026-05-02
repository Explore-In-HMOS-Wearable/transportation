import { MainMenuItemModel } from '../../model/MainMenuItemModel';
import { mainMenuItems, deviceSize } from '../../common/Common';
import { ArcList, ArcListItem, ArcListItemAttribute, ArcListAttribute, LengthMetrics } from '@kit.ArkUI';
import { NavigationManager, Theme } from 'core';

@Builder
export function HomePageBuilder() {
  HomePage();
}

@Component
export struct HomePage {
  build() {
    NavDestination() {
      Column() {
        Stack() {
          ArcList({ initialIndex: 0 }) {
            ForEach(mainMenuItems, (item: MainMenuItemModel) => {
              ArcListItem() {
                Button({ type: ButtonType.Circle }) {
                  Column() {
                    SymbolGlyph(item.icon).fontSize(deviceSize * 0.1).fontColor([Color.White]);
                    Text(`${item.description}`)
                      .fontSize(Theme.FontSize.large)
                      .fontColor(Color.White)
                      .fontWeight(Theme.Weight.bold);
                  };
                }
                .width(`${deviceSize * 0.6}px`)
                .height(`${deviceSize * 0.6}px`)
                .focusable(true)
                .opacity(0.9)
                .focusOnTouch(true)
                .backgroundColor(item.backgroundColor);
              }.align(Alignment.Center).onClick(() => {
                NavigationManager.getInstance().pageInfos.pushPath({ name: item.navigationName });
              });

            }, (item: string, index: number) => item);
          }
          .space(LengthMetrics.px(10))
          .borderRadius(`${deviceSize * 0.6}px`)
          .focusable(true)
          .focusOnTouch(true)
          .defaultFocus(true);
        }
        .align(Alignment.Center)
        .width(`${deviceSize}px`)
        .height(`${deviceSize}px`)
        .borderRadius(`${deviceSize}px`);
      }
      .height('100%')
      .width('100%');
    }.hideTitleBar(true);
  }
}