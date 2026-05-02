import { mapCommon, map, navi, petalMaps } from '@kit.MapKit';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { LocationUtils } from './LocationUtils';

const TAG = 'NavigationUtils';
const DOMAIN = 0xFF00;

interface NavParam {
  latitude: number;
  longitude: number;
}

interface MapNaviParam {
  destinationPosition: NavParam;
  destinationName: string | undefined;
}

export class NavigationUtils {
  static async convertToMapCoordinate(
    latitude: number,
    longitude: number
  ): Promise<mapCommon.LatLng> {
    try {
      const wgs84: mapCommon.LatLng = { latitude, longitude };
      return await map.convertCoordinate(
        mapCommon.CoordinateType.WGS84,
        mapCommon.CoordinateType.GCJ02,
        wgs84
      );
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Convert coordinate error: ${JSON.stringify(error)}`);
      if (error instanceof Error) {
        throw error;
      }
      throw new Error(`Unknown location error: ${JSON.stringify(error)}`);
    }
  }

  static async getDrivingRoute(destination: mapCommon.LatLng): Promise<navi.RouteResult | null> {
    try {
      const currentLocation = await LocationUtils.getCurrentLocation();

      const params: navi.DrivingRouteParams = {
        origins: [currentLocation],
        destination: destination,
        language: 'en'
      };

      const result = await navi.getDrivingRoutes(params);
      hilog.info(DOMAIN, TAG, 'Route fetched successfully');
      return result;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Get route error: ${JSON.stringify(error)}`);
      return null;
    }
  }

  static async openNavigation(
    context: common.UIAbilityContext,
    destLat: number,
    destLon: number,
    destName?: string
  ): Promise<void> {
    try {
      const params: MapNaviParam = {
        destinationPosition: ({ latitude: destLat, longitude: destLon } as NavParam),
        destinationName: destName
      };

      await petalMaps.openMapNavi(context, params);
      hilog.info(DOMAIN, TAG, 'Navigation opened');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Open navigation error: ${JSON.stringify(error)}`);
    }
  }

  static createMarker(
    latitude: number,
    longitude: number,
    title?: string,
    icon?: Resource
  ): mapCommon.MarkerOptions {
    return {
      position: { latitude, longitude },
      title: title,
      icon: icon,
      clickable: true
    };
  }

  static createPolyline(
    points: mapCommon.LatLng[],
    color: number = 0xFF0A84FF,
    width: number = 10
  ): mapCommon.MapPolylineOptions {
    return {
      points: points,
      color: color,
      width: width
    };
  }
}
