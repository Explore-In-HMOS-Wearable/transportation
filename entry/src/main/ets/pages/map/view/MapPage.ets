import { common } from '@kit.AbilityKit';
import { MapComponent } from '@kit.MapKit';
import { NavigationManager } from 'core';
import { BusStop } from '../../../model/searchPageModel/BusStop';
import { MapViewModel } from '../viewmodel/MapViewModel';

@Entry
@Component
export struct MapPage {
  @State vm: MapViewModel = new MapViewModel();

  aboutToAppear(): void {
    const uiAbilityCtx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.vm.init(uiAbilityCtx);
  }

  aboutToDisappear(): void {
    this.vm.dispose();
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        MapComponent({ mapOptions: this.vm.mapOptions, mapCallback: this.vm.callback })
          .width('100%')
          .height('100%');

        Button({ type: ButtonType.Circle, stateEffect: true }) {
          // You can replace this with your own icon if you have one in resources/rawfile/
          Image($r('sys.media.ohos_ic_compnent_titlebar_back'))
            .width(24)
            .height(24)
            .fillColor(Color.Black)
        }
        .width(48)
        .height(48)
        .backgroundColor(Color.White)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.2)', offsetX: 0, offsetY: 2 })
        .margin({ top: 56, left: 16 })
        .onClick(() => {
          NavigationManager.getInstance().pageInfos.pop();
        });

      }.height('100%');
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      const params = context.pathInfo.param as BusStop;

      if (params) {
        const targetStopId = params.stopId;

        console.info(`[MapPage] Received routing params: Stop=${targetStopId}`);

        if (targetStopId) {
          this.vm.setTargetStop(targetStopId);
        }
      }
    });
  }
}
