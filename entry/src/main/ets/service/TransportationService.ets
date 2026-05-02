import { HttpManager } from 'core';
import {
  AnnouncementModel, AnnouncementRecords, AnnouncementRoot
} from '../model/AnnouncementModel';
import { ApproachingBus, ApproachingBusResponse } from '../model/ApproachingBusModel';
import { NearbyStopModel } from '../model/NearbyStopModel';

export class TransportationService {
  private static instance: TransportationService;
  private httpManager: HttpManager;

  private constructor() {
    this.httpManager = HttpManager.getInstance();
    // set base url
    this.httpManager.setBaseUrl('');
  }

  static getInstance(): TransportationService {
    if (!TransportationService.instance) {
      TransportationService.instance = new TransportationService();
    }
    return TransportationService.instance;
  }

  async getBusesApproachingStop(stopId: string): Promise<ApproachingBus[]> {
    try {
      // 1. Get raw data from API
      const rawBuses = await this.httpManager.get<ApproachingBusResponse[]>(
        `/api/iztek/duragayaklasanotobusler/${stopId}`
      );

      // 2. Map raw response to our interface
      const mappedBuses: ApproachingBus[] = rawBuses.map((bus: ApproachingBusResponse): ApproachingBus => {
        return {
          remainingStopCount: bus.remainingStopCount,
          routeDirection: bus.routeDirection,
          latitude: bus.latitude,
          longitude: bus.longitude,
          hasBikeRack: bus.hasBicycleRack,
          isAccessible: bus.isAccessible,
          lineNumber: bus.routeNumber,
          lineName: bus.routeName,
          busId: bus.busId
        };
      });

      return mappedBuses;

    } catch (error) {
      console.error(`Error getting buses for stop ${stopId}:`, error);
      return []; // Always return an array, never undefined
    }
  }

  /**
   * Get buses for a specific line approaching a specific stop
   * @param lineNumber Bus line number (e.g., "125")
   * @param stopId Bus stop ID
   * @returns Array of approaching buses for that line
   */
  async getBusesForLineApproachingStop(lineNumber: string, stopId: string): Promise<ApproachingBus[]> {
    try {

      // This endpoint returns same structure as the first one
      const rawBuses = await this.httpManager.get<ApproachingBusResponse[]>(
        `/api/iztek/hattinyaklasanotobusleri/${lineNumber}/${stopId}`
      );

      // Map to our interface - with explicit return type
      const mappedBuses: ApproachingBus[] = rawBuses.map((bus: ApproachingBusResponse): ApproachingBus => {
        return {
          remainingStopCount: bus.remainingStopCount,
          routeDirection: bus.routeDirection,
          latitude: bus.latitude,
          longitude: bus.longitude,
          hasBikeRack: bus.hasBicycleRack,
          isAccessible: bus.isAccessible,
          lineNumber: bus.routeNumber,
          lineName: bus.routeName,
          busId: bus.busId
        };
      });

      return mappedBuses;

    } catch (error) {
      console.error(`Error getting buses for line ${lineNumber}:`, error);
      return []; // Always return an array, never undefined
    }
  }

  async getNews(): Promise<AnnouncementModel[]> {

    try {

      const rootResult = await this.httpManager.get<AnnouncementRoot>(
        `/api/3/action/datastore_search?resource_id=aeafda53-3db8-46fa-abe3-47b773fc8b90&limit=10`
      );

      const mappedAnnouncements: AnnouncementModel[] | undefined =
        rootResult?.result?.records.map((announce: AnnouncementRecords): AnnouncementModel => {
          return {
            title: announce.title,
            startDate: announce.startDate,
            endDate: announce.endDate
          };
        });

      if (mappedAnnouncements !== undefined) {
        return mappedAnnouncements;
      } else {
        return [];
      }

    } catch (error) {
      console.error(`Error getting announcements:`, error);
      return []; // Always return an array, never undefined
    }
  }

  /**
   * Get nearby bus stops based on user's current coordinates
   * @param latitude User's current latitude (y)
   * @param longitude User's current longitude (x)
   * @returns Array of nearby stops
   */
  async getNearbyStops(latitude: number, longitude: number): Promise<NearbyStopModel[]> {
    try {
      const endpoint =
        `/api/ibb/cbs/noktayayakinduraklar?x=${longitude}&y=${latitude}&inCoordSys=EPSG:4326&outCoordSys=EPSG:4326`;

      const nearbyStops = await this.httpManager.get<NearbyStopModel[]>(endpoint);

      console.info(`[TransportationService] Found ${nearbyStops.length} nearby stops: \n${JSON.stringify(nearbyStops,
        null, 2)}`);

      return nearbyStops;

    } catch (error) {
      console.error(`[TransportationService] Error getting nearby stops for lat: ${latitude}, lon: ${longitude}`,
        error);
      return [];
    }
  }

  /**
   * Get location of a specific bus/line approaching a specific stop
   * @param busId The line number or bus ID (e.g., "446")
   * @param stopId The stop ID (e.g., "21056")
   * @returns Array of approaching buses
   */
  async getSpecificBusLocation(busId: string, stopId: string): Promise<ApproachingBus[]> {
    try {
      // Safely expect either a single object or an array of ApproachingBusResponse
      const rawData = await this.httpManager.get<ApproachingBusResponse | ApproachingBusResponse[]>(
        `/api/iztek/hattinyaklasanotobusleri/${busId}/${stopId}`
      );

      // Normalize it into an array of ApproachingBusResponse so we can map it safely
      const rawBuses: ApproachingBusResponse[] = Array.isArray(rawData) ? rawData : [rawData];

      const mappedBuses: ApproachingBus[] = rawBuses.map((bus: ApproachingBusResponse): ApproachingBus => {
        return {
          remainingStopCount: bus.remainingStopCount,
          routeDirection: bus.routeDirection,
          latitude: bus.latitude,
          longitude: bus.longitude,
          hasBikeRack: bus.hasBicycleRack,
          isAccessible: bus.isAccessible,
          lineNumber: bus.routeNumber,
          lineName: bus.routeName,
          busId: bus.busId
        };
      });

      return mappedBuses;

    } catch (error) {
      console.error(`[TransportationService] Error getting specific bus ${busId} for stop ${stopId}:`, error);
      return [];
    }
  }
}
