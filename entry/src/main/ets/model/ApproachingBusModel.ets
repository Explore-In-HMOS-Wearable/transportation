export interface ApproachingBus {
  remainingStopCount: number;
  routeDirection: number;
  latitude: string;
  longitude: string;
  hasBikeRack: boolean;
  isAccessible: boolean;
  lineNumber: number;
  lineName: string;
  busId: number;
}

export interface ApproachingBusResponse {
  remainingStopCount: number;
  routeDirection: number;
  latitude: string;
  hasBicycleRack: boolean;
  longitude: string;
  isAccessible: boolean;
  routeNumber: number;
  routeName: string;
  busId: number;
}
