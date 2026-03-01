import { NavigationConstants, NavigationManager, Theme } from 'core';
import { BusLine } from '../../model/searchPageModel/BusLine';
import { BusSchedule } from '../../model/searchPageModel/BusSchedule';
import { BusStop } from '../../model/searchPageModel/BusStop';
import { SearchPageViewModel } from './SearchPageViewModel';

@Builder
export function SearchPageBuilder() {
  SearchPage()
}

@Entry
@Component
export struct SearchPage {
  private scroller: Scroller = new Scroller();
  @State searchKeyword: string = '';
  @State vm: SearchPageViewModel = new SearchPageViewModel();
  @State busName: string = '';
  @State departuresA: BusSchedule[] = [];
  @State departuresB: BusSchedule[] = [];
  @State stops: BusStop[] = [];

  async aboutToAppear() {
    this.searchKeyword = '5';
    await this.vm.loadDetails(Number(this.searchKeyword),
      (lineInfo: BusLine, outboundData: BusSchedule[], inboundData: BusSchedule[], stopsFilter: BusStop[]) => {
        this.busName = lineInfo.busMap;
        this.departuresB = outboundData.slice(0);
        this.departuresA = inboundData.slice(0);
        this.stops = stopsFilter.slice(0);
      });
  }

  build() {
    NavDestination() {

      Scroll(this.scroller) {
        Swiper() {
          this.busSearchPage();
          this.stopSearchPage();
        }
        .loop(false)
        .indicator(
          new DotIndicator()
            .color(Theme.Colors.dividerGray())
            .selectedColor(Theme.Colors.primaryGreen())
        )

      }
      .scrollable(ScrollDirection.Vertical)
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.Colors.globalBackground())

    }.hideTitleBar(true).hideBackButton(true)
  }

  @Builder
  busSearchPage() {
    Stack() {
      Column() {
        // Native Search component with brand styling
        Search({ placeholder: 'Search Bus No ' })
          .width('75%')
          .placeholderColor(Theme.Colors.textSecondary())
          .placeholderFont({ size: Theme.FontSize.xs })
          .height(40)
          .minFontSize(Theme.FontSize.xs)
          .fontColor(Theme.Colors.textPrimary())
          .border({ width: 1.5, color: Theme.Colors.searchBarBorder(), radius: 20 })
          .searchIcon({ color: Theme.Colors.searchIconColor() })
          .margin({ top: '15%', bottom: 10 })
          .onSubmit(async (value: string) => {
            this.searchKeyword = value;
            this.departuresA = [];
            this.departuresB = [];
            this.stops = [];
            await this.vm.loadDetails(Number(this.searchKeyword),
              (lineInfo: BusLine, outboundData: BusSchedule[], inboundData: BusSchedule[], stopsFilter: BusStop[]) => {
                this.busName = lineInfo.busMap;
                this.departuresB = outboundData.slice(0);
                this.departuresA = inboundData.slice(0);
                this.stops = stopsFilter.slice(0);
              });
          })
        if (Number(this.searchKeyword) > 4) {
          Text(this.busName)
            .fontSize(16).fontWeight(FontWeight.Bold)
            .fontColor(Theme.Colors.textPrimary()).margin({ bottom: 15 })
          Row() {
            // --- LEFT COLUMN: STATION A ---
            Column() {
              Text('INBOUND').fontSize(13).fontWeight(FontWeight.Bolder)
                .fontColor(Theme.Colors.primaryGreen()).margin({ bottom: 8 })

              List({ space: 6 }) {
                ForEach(this.departuresA, (time: BusSchedule) => {
                  ListItem() {
                    Text(time.inBound).fontSize(14).textAlign(TextAlign.Center).fontColor(Theme.Colors.textPrimary())
                  }
                  .width('100%')
                  .height(38)
                  .backgroundColor(Theme.Colors.announcementCardBg()) // Light theme background
                  .borderRadius(10)
                  .border({ width: 0.5, color: Theme.Colors.tableGridBorder() }) // Subtle grid border
                }, (item: BusSchedule, index:number) => item.inBound );
              }.width('100%').height('100%')
            }.layoutWeight(1).padding({ right: 5 })

            // --- RIGHT COLUMN: STATION B ---
            Column() {
              Text('OUTBOUND').fontSize(13).fontWeight(FontWeight.Bolder)
                .fontColor(Theme.Colors.primaryGreen()).margin({ bottom: 8 })

              List({ space: 6 }) {
                ForEach(this.departuresB, (time: BusSchedule) => {
                  ListItem() {
                    Text(time.outBond).fontSize(14).textAlign(TextAlign.Center).fontColor(Theme.Colors.textPrimary())
                  }
                  .width('100%')
                  .height(38)
                  .backgroundColor(Theme.Colors.announcementCardBg())
                  .borderRadius(10)
                  .border({ width: 0.5, color: Theme.Colors.tableGridBorder() })
                }, (item: BusSchedule, index:number) => item.outBond );
              }.width('100%').height('100%')
            }.layoutWeight(1).padding({ left: 5 })
          }
          .width('90%')
          .alignItems(VerticalAlign.Top)
          .margin({ bottom: '15%' })
        }
      }
      .width('100%')
    }.width('100%')
  }

  // --- BUS STOP SEARCH PAGE (PAGE 2) ---
  @Builder
  stopSearchPage() {

      Column() {
        Text(this.busName)
          .fontSize(Theme.FontSize.xs)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.Colors.textPrimary())
          .margin({
            top: 32,
            bottom: 10,
            left: 24,
            right: 24
          }).width('%80')

        // List of bus stops
        List({ space: 10 }) {
          ForEach(this.stops, (stop: BusStop) => {
            ListItem() {
              Row() {
                // Circular icon representing the bus stop
                Circle({ width: 10, height: 10 })
                  .fill(Theme.Colors.primaryGreen())
                  .margin({ right: 10 })

                Text(stop.stopName)
                  .fontSize(15)
                  .fontColor(Theme.Colors.textPrimary())
              }
              .width('90%')
              .padding(12)
              .backgroundColor(Theme.Colors.announcementCardBg())
              .borderRadius(12)
            }.onClick(() => {
              const data: BusStop  = {
                busNo: this.searchKeyword,
                stopId: stop.stopId,
                stopName: stop.stopName
              }
              NavigationManager.getInstance().pageInfos.pushPathByName('map', data );
            });
          }, (item: BusStop, index:number) => item.busNo );
        }.margin({bottom:'30%'})
        .width('100%')
        .alignListItem(ListItemAlign.Center)

      }.width('100%').height('100%')

  }
}


