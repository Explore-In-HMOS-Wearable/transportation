import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, Permissions, bundleManager, common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'LocationUtils';
const DOMAIN = 0xFF00;

export interface LocationResult {
  latitude: number;
  longitude: number;
}

export class LocationUtils {
  private static locationCallback: ((location: geoLocationManager.Location) => void) | null = null;

  static async hasPermissions(context: common.UIAbilityContext): Promise<boolean> {
    try {
      const bundleInfo = await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
      );
      const tokenId = bundleInfo.appInfo.accessTokenId;
      const atManager = abilityAccessCtrl.createAtManager();

      const permissions: Array<Permissions> = [
        'ohos.permission.APPROXIMATELY_LOCATION',
        'ohos.permission.LOCATION'
      ];

      for (const permission of permissions) {
        const status = await atManager.checkAccessToken(tokenId, permission);
        if (status !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          return false;
        }
      }
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Check permissions error: ${JSON.stringify(error)}`);
      return false;
    }
  }

  static async requestPermissions(context: common.UIAbilityContext): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const result = await atManager.requestPermissionsFromUser(context, [
        'ohos.permission.APPROXIMATELY_LOCATION',
        'ohos.permission.LOCATION'
      ]);

      const allGranted = result.authResults.every(
        status => status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
      );

      if (!allGranted) {
        const dialogShown = result.dialogShownResults?.some(shown => shown);
        if (!dialogShown) {
          await LocationUtils.openSettings(context);
        }
      }
      return allGranted;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Request permissions error: ${JSON.stringify(error)}`);
      return false;
    }
  }

  static async openSettings(context: common.UIAbilityContext): Promise<void> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      await atManager.requestPermissionOnSetting(context, [
        'ohos.permission.APPROXIMATELY_LOCATION',
        'ohos.permission.LOCATION'
      ]);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Open settings error: ${JSON.stringify(error)}`);
    }
  }

  static isLocationEnabled(): boolean {
    try {
      return geoLocationManager.isLocationEnabled();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Check location enabled error: ${JSON.stringify(error)}`);
      return false;
    }
  }

  static async requestLocationService(context: common.UIAbilityContext): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      return await atManager.requestGlobalSwitch(context, abilityAccessCtrl.SwitchType.LOCATION);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Request location service error: ${JSON.stringify(error)}`);
      return false;
    }
  }

  static async getCurrentLocation(): Promise<LocationResult> {
    try {
      const request: geoLocationManager.SingleLocationRequest = {
        locatingPriority: geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
        locatingTimeoutMs: 10000
      };

      const location = await geoLocationManager.getCurrentLocation(request);

      return {
        latitude: location.latitude,
        longitude: location.longitude
      };
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Get current location error: ${JSON.stringify(error)}`);
      if (error instanceof Error) {
        throw error;
      }
      throw new Error(`Unknown location error: ${JSON.stringify(error)}`);
    }
  }

  static startContinuousLocation(callback: (location: LocationResult) => void): void {
    try {
      const request: geoLocationManager.ContinuousLocationRequest = {
        interval: 1000,
        locationScenario: geoLocationManager.UserActivityScenario.NAVIGATION
      };

      LocationUtils.locationCallback = (location: geoLocationManager.Location) => {
        callback({
          latitude: location.latitude,
          longitude: location.longitude
        });
      };

      geoLocationManager.on('locationChange', request, LocationUtils.locationCallback);
      hilog.info(DOMAIN, TAG, 'Continuous location started');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Start continuous location error: ${JSON.stringify(error)}`);
    }
  }

  static stopContinuousLocation(): void {
    try {
      if (LocationUtils.locationCallback) {
        geoLocationManager.off('locationChange', LocationUtils.locationCallback);
        LocationUtils.locationCallback = null;
        hilog.info(DOMAIN, TAG, 'Continuous location stopped');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Stop continuous location error: ${JSON.stringify(error)}`);
    }
  }
}
