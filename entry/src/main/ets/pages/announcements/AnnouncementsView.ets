import { Theme } from 'core';
import { AnnouncementsViewModel } from './AnnouncementsViewModel';
import { ArcList, ArcListItem, ArcListAttribute } from '@kit.ArkUI';
import { AnnouncementModel } from '../../model/AnnouncementModel';
import { deviceInfo } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
export struct AnnouncementsView {
  @State viewModel: AnnouncementsViewModel = new AnnouncementsViewModel();

  aboutToAppear() {
    this.viewModel.loadNews();
  }

  build() {

    NavDestination() {
      Stack() {
        // Global Background
        Column().width('100%').height('100%').backgroundColor(Theme.Colors.globalBackground());

        if (this.viewModel.isLoading) {
          LoadingProgress()
            .width(44)
            .height(44)
            .color(Theme.Colors.primaryGreen());
        } else {
          if (deviceInfo.sdkApiVersion >= 18) {
            ArcList({ initialIndex: 0 }) {
              ArcListItem() {
                Text($r('app.string.page_title_announcements'))
                  .fontSize(Theme.FontSize.large)
                  .fontWeight(Theme.Weight.bold)
                  .fontColor(Theme.Colors.textPrimary())
                  .margin({ bottom: Theme.Margin.medium });
              };

              ForEach(this.viewModel.announcements, (item: AnnouncementModel) => {
                ArcListItem() {
                  // Wrap in Capsule Button for native watch interaction
                  Button({ type: ButtonType.Capsule }) {
                    this.announcementCard(item);
                  }
                  .backgroundColor(Theme.Colors.announcementCardBg())
                  .width('95%') // Slightly narrower for arc clearance
                  .onClick(() => {
                    hilog.info(0x0000, 'AnnouncementsView', `Click`);
                  });
                };
              }, (item: AnnouncementModel) => item.title + item.startDate);
            }
            .width('100%')
            .height('100%');
          } else {
            // Fallback to an earlier version
          }
        }
      }
      .width('100%')
      .height('100%');
    }.hideTitleBar(true);

  }

  @Builder
  announcementCard(item: AnnouncementModel) {
    Column() {
      Row() {
        Rect()
          .width(4)
          .height(20)
          .radius(Theme.Radius.pill)
          .fill(Color.White)
          .margin({ right: Theme.Margin.small });

        // DYNAMIC TITLE
        Text(item.title)
          .fontSize(Theme.FontSize.medium)
          .fontWeight(Theme.Weight.bold)
          .fontColor(Color.White)
          // Removing maxLines or setting it high makes it dynamic
          .textOverflow({ overflow: TextOverflow.None })
          .width('100%')
          .textAlign(TextAlign.Start);
      }
      .width('100%')
      .alignItems(VerticalAlign.Top); // Align to top so it grows downwards

      // Dynamic Spacer
      Column().height(Theme.Margin.medium);

      // Bottom Section: Dates (Solid contrast block)
      Column() {
        this.dateRow($r('app.string.label_start_date'), item.startDate);
        this.dateRow($r('app.string.label_end_date'), item.endDate);
      }
      .width('100%')
      .padding(Theme.Padding.small)
      .backgroundColor(Theme.Colors.primaryDarkGreen())
      .borderRadius(Theme.Radius.small);
    }
    .padding(Theme.Padding.medium)
    .margin(Theme.Margin.medium)
    .backgroundColor(Theme.Colors.primaryGreen())
    .borderRadius(Theme.Radius.large)
    .width('90%'); // Card stays full width, height is dynamic
  }

  @Builder
  dateRow(label: Resource, dateStr: string) {
    Row() {
      Text(label)
        .fontSize(Theme.FontSize.xs)
        .fontColor(Color.White)
        .opacity(0.7);
      Blank();
      Text(dateStr.split('T')[0])
        .fontSize(Theme.FontSize.xs)
        .fontWeight(Theme.Weight.medium)
        .fontColor(Color.White);
    }
    .width('100%')
    .margin({ bottom: 2 });
  }
}