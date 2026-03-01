import {
  common
} from '@kit.AbilityKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { mapCommon, map } from '@kit.MapKit';
import { ApproachingBus } from '../../../model/ApproachingBusModel';
import { TransportationService } from '../../../service/TransportationService';
import { LocationUtils } from 'core';
import { NearbyStopModel } from '../../../model/NearbyStopModel';

@Observed
export class MapViewModel {
  mapOptions?: mapCommon.MapOptions;
  callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  private uiAbilityContext?: common.UIAbilityContext;
  // ---- Marker/API ----
  private readonly transportationService: TransportationService = TransportationService.getInstance();
  private selectedStopId: string | null = null;
  private stopMarkerMap: Map<string, string> = new Map(); // Maps Marker ID -> durakId
  private busMarkers: map.Marker[] = []; // Tracks active bus markers so we can clear them

  private refreshTimerId: number = -1;
  private readonly REFRESH_MS: number = 10_000;
  private lastMarkerCount: number = 0;
  private static readonly TAG: string = '[MapVM]';
  private initialTargetStopId?: string;

  init(uiCtx: common.UIAbilityContext): void {
    this.uiAbilityContext = uiCtx;

    this.mapOptions = {
      position: {
        target: { latitude: 38.4237, longitude: 27.1428 },
        zoom: 12
      }
    };

    this.callback = async (err, controller) => {
      if (err) {
        console.error(`${MapViewModel.TAG} Map init failed. Code=${err.code}; message=${err.message}`);
        return;
      }

      this.mapController = controller;
      this.mapEventManager = this.mapController.getEventManager();

      console.info(`${MapViewModel.TAG} Map controller ready.`);

      this.setupMarkerClickListener();

      const hasPermission = await LocationUtils.hasPermissions(this.uiAbilityContext!);
      console.info(`hasPermission: ${hasPermission} is the value`);
      if (!hasPermission) {
        const isGranted = await LocationUtils.requestPermissions(this.uiAbilityContext!);
        if (isGranted) {
          await this.afterPermissionGranted();
        } else {
          console.warn('Permissions denied. Showing fallback UI or showing an error.');
        }
        return;
      }
      await this.afterPermissionGranted();
    };
  }

  public setTargetStop(stopId: string): void {
    this.initialTargetStopId = stopId;
  }

  dispose(): void {
    this.stopAutoRefresh();

    this.mapEventManager = undefined;
    this.mapController = undefined;
    this.uiAbilityContext = undefined;
    this.stopMarkerMap.clear();
    this.busMarkers = [];

    this.lastMarkerCount = 0;
    console.info(`${MapViewModel.TAG} disposed.`);
  }

  private setupMarkerClickListener(): void {
    if (!this.mapEventManager) {
      return;
    }

    this.mapEventManager.on('markerClick', async (marker: map.Marker) => {
      const markerId = marker.getId();

      // Check if the clicked marker is a Stop Marker
      if (this.stopMarkerMap.has(markerId)) {
        const stopId = this.stopMarkerMap.get(markerId);
        if (stopId) {
          console.info(`${MapViewModel.TAG} Stop clicked: ${stopId}`);

          this.selectedStopId = stopId;

          marker.setInfoWindowVisible(true);

          // Stop old refresh loop and fetch new buses immediately
          this.stopAutoRefresh();
          await this.loadBusMarkersForStop(this.selectedStopId, false);
          this.startAutoRefresh();
        }
      } else {
        // It might be a bus marker handle if necessary
        console.info(`${MapViewModel.TAG} Bus marker clicked.`);
        marker.setInfoWindowVisible(true);
      }
    });
  }

  private async afterPermissionGranted(): Promise<void> {
    const isGpsOn = LocationUtils.isLocationEnabled();

    if (!isGpsOn) {
      console.warn(`${MapViewModel.TAG} GPS is off. Prompting user to turn it on...`);

      const switchedOn = await LocationUtils.requestLocationService(this.uiAbilityContext!);

      if (!switchedOn) {
        console.warn(`${MapViewModel.TAG} User refused to turn on GPS.`);
        return;
      }
    }

    this.enableMyLocation();

    // BRANCH LOGIC: Did we come from the menu or with parameters?
    if (this.initialTargetStopId) {
      // MODE 2: TRACKING A SPECIFIC BUS
      console.info(`${MapViewModel.TAG} Navigated directly to stop: ${this.initialTargetStopId}`);
      this.selectedStopId = this.initialTargetStopId;
      // Fetch this specific bus and center the camera on it
      await this.loadBusMarkersForStop(this.selectedStopId!, true);

      // Start refreshing just this bus
      this.startAutoRefresh();

    } else {
      // MODE 1: EXPLORE NEARBY STOPS (No parameters)
      console.info(`${MapViewModel.TAG} No target parameters. Loading nearby stops.`);
      try {
        const location = await LocationUtils.getCurrentLocation();
        if (this.mapController) {
          const cameraUpdate = map.newCameraPosition({
            target: { latitude: location.latitude, longitude: location.longitude },
            zoom: 14
          });
          this.mapController.animateCamera(cameraUpdate, 1000);
        }
        await this.loadNearbyStops(location.latitude, location.longitude);
      } catch (error) {
        console.error(`${MapViewModel.TAG} Failed to get location/nearby stops: ${JSON.stringify(error)}`);
      }
    }
  }

  private enableMyLocation(): void {
    this.mapController?.setMyLocationEnabled(true);
    this.mapController?.setMyLocationControlsEnabled(true);
  }

  private async loadNearbyStops(lat: number, lng: number): Promise<void> {
    if (!this.mapController) {
      return;
    }

    console.info(`${MapViewModel.TAG} Fetching nearby stops...`);
    const stops: NearbyStopModel[] = await this.transportationService.getNearbyStops(lat, lng);

    for (const stop of stops) {
      const pos: mapCommon.LatLng = { latitude: stop.enlem, longitude: stop.boylam };

      const markerOptions: mapCommon.MarkerOptions = {
        position: pos,
        title: stop.adi,
        snippet: 'Durak (Stop)',
        clickable: true,
        icon: 'bus_stop.png'
      };

      const marker = await this.mapController.addMarker(markerOptions);

      // Save the association between this specific marker UI and the API's stop ID
      this.stopMarkerMap.set(marker.getId(), stop.durakId);
    }

    console.info(`${MapViewModel.TAG} Loaded ${stops.length} stop markers.`);
  }

  // ---------- AUTO REFRESH ----------
  private startAutoRefresh(): void {
    if (this.refreshTimerId !== -1) {
      return;
    }

    console.info(`${MapViewModel.TAG} Auto refresh started.`);

    const id: number = setInterval(() => {
      if (this.selectedStopId) {
        this.loadBusMarkersForStop(this.selectedStopId, false)
          .catch((e: Error) => console.error(`${MapViewModel.TAG} refresh error: ${e.message}`));
      }
    }, this.REFRESH_MS) as number;

    this.refreshTimerId = id;
  }

  private stopAutoRefresh(): void {
    if (this.refreshTimerId === -1) {
      return;
    }

    clearInterval(this.refreshTimerId);
    this.refreshTimerId = -1;

    console.info(`${MapViewModel.TAG} Auto refresh stopped.`);
  }

  private async loadBusMarkersForStop(stopId: string, moveCamera: boolean): Promise<void> {
    if (!this.mapController) {
      console.warn(`${MapViewModel.TAG} mapController is undefined.`);
      return;
    }

    console.info(`${MapViewModel.TAG} Fetching buses for stopId=${stopId} ...`);

    const buses: ApproachingBus[] = await this.transportationService.getBusesApproachingStop(stopId);

    for (const oldMarker of this.busMarkers) {
      oldMarker.remove();
    }
    this.busMarkers = []; // Clear the array

    if (!buses.length) {
      console.info(`${MapViewModel.TAG} No buses approaching right now.`);
      return;
    }

    const firstValid = this.findFirstValidBus(buses);
    if (!firstValid && moveCamera) {
      console.warn(`${MapViewModel.TAG} No valid coordinates in response.`);
      return;
    }

    // 2. Add new bus markers
    let added = 0;
    for (const bus of buses) {
      const lat = this.toFiniteNumber(bus.latitude);
      const lng = this.toFiniteNumber(bus.longitude);

      if (!this.isValidLatLng(lat, lng)) {
        continue;
      }

      const pos: mapCommon.LatLng = { latitude: lat, longitude: lng };

      const markerOptions: mapCommon.MarkerOptions = {
        position: pos,
        title: `${bus.lineNumber || 'N/A'} • ${bus.remainingStopCount ?? 'N/A'} durak`,
        snippet: bus.lineName,
        clickable: true
      };

      const marker = await this.mapController.addMarker(markerOptions);
      this.busMarkers.push(marker); // Track the bus marker so we can delete it next refresh
      added++;
    }

    console.info(`${MapViewModel.TAG} Bus markers added: ${added}`);

    if (moveCamera && firstValid) {
      const camLat = this.toFiniteNumber(firstValid.latitude);
      const camLng = this.toFiniteNumber(firstValid.longitude);

      const cameraPosition: mapCommon.CameraPosition = {
        target: { latitude: camLat, longitude: camLng },
        zoom: 16
      };
      const cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
      this.mapController.animateCamera(cameraUpdate, 500);
    }

    this.lastMarkerCount = added;
  }

  private async loadSpecificBus(busId: string, stopId: string, moveCamera: boolean): Promise<void> {
    if (!this.mapController) {
      return;
    }

    const buses: ApproachingBus[] = await this.transportationService.getSpecificBusLocation(busId, stopId);

    // Clear old markers
    for (const oldMarker of this.busMarkers) {
      oldMarker.remove();
    }
    this.busMarkers = [];

    if (!buses.length) {
      console.info(`${MapViewModel.TAG} Target bus not found on route.`);
      return;
    }

    const firstValid = this.findFirstValidBus(buses);

    // Draw the bus marker
    for (const bus of buses) {
      const lat = this.toFiniteNumber(bus.latitude);
      const lng = this.toFiniteNumber(bus.longitude);

      if (!this.isValidLatLng(lat, lng)) {
        continue;
      }

      const pos: mapCommon.LatLng = { latitude: lat, longitude: lng };
      const markerOptions: mapCommon.MarkerOptions = {
        position: pos,
        title: `${bus.lineNumber || busId} • ${bus.remainingStopCount ?? '?'} durak`,
        snippet: bus.lineName || 'Hedef Hat',
        clickable: true
      };

      const marker = await this.mapController.addMarker(markerOptions);
      this.busMarkers.push(marker);

      // Force open the InfoWindow since this is the specific bus we care about
      marker.setInfoWindowVisible(true);
    }

    // Zoom tightly onto the bus if requested
    if (moveCamera && firstValid) {
      const camLat = this.toFiniteNumber(firstValid.latitude);
      const camLng = this.toFiniteNumber(firstValid.longitude);

      const cameraUpdate: map.CameraUpdate = map.newCameraPosition({
        target: { latitude: camLat, longitude: camLng },
        zoom: 16
      });
      this.mapController.animateCamera(cameraUpdate, 500);
    }
  }

  private findFirstValidBus(buses: ApproachingBus[]): ApproachingBus | undefined {
    for (const bus of buses) {
      const lat = this.toFiniteNumber(bus.latitude);
      const lng = this.toFiniteNumber(bus.longitude);
      if (this.isValidLatLng(lat, lng)) {
        return bus;
      }
    }
    return undefined;
  }

  private isValidLatLng(lat: number, lng: number): boolean {
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
      return false;
    }
    if (lat < -90 || lat > 90) {
      return false;
    }
    if (lng < -180 || lng > 180) {
      return false;
    }
    if (lat === 0 && lng === 0) {
      return false;
    }
    return true;
  }

  private toFiniteNumber(v: string | number): number {
    if (typeof v === 'number') {
      return Number.isFinite(v) ? v : NaN;
    }
    const normalized = v.replace(',', '.');
    const n = Number(normalized);
    return Number.isFinite(n) ? n : NaN;
  }
}
