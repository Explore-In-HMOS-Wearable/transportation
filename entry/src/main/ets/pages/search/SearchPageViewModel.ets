import { BusLine } from '../../model/searchPageModel/BusLine';
import { BusSchedule } from '../../model/searchPageModel/BusSchedule';
import { BusStop } from '../../model/searchPageModel/BusStop';

import { EshotService } from '../../service/searchPageService/EshotService';

export type UpdateCallback = (
  lineInfo: BusLine,
  outbound: BusSchedule[],
  inbound: BusSchedule[],
  stops: BusStop[],
) => void;

@Observed
export class SearchPageViewModel {
  private service = new EshotService();
  private _isLoading: boolean = false;
  private _error: string | null = '';

  public set error(value) {
    this._error = value;
  }

  public get error() {
    return this._error;
  }

  public set isLoading(value: boolean) {
    this._isLoading = value;
  }

  public get isLoading(): boolean {
    return this._isLoading;
  }

  private _outboundTimes: BusSchedule[] = [];

  public set outboundTimes(value: BusSchedule[]) {
    this._outboundTimes = value;
  }

  public get outboundTimes(): BusSchedule[] {
    return this._outboundTimes;
  }

  private _inboundTimes: BusSchedule[] = [];

  public set inboundTimes(value: BusSchedule[]) {
    this._inboundTimes = value;
  }

  public get inboundTimes(): BusSchedule[] {
    return this._inboundTimes;
  }

  private _outboundStops: BusStop[] = [];

  public set outboundStops(value: BusStop[]) {
    this._outboundStops = value;
  }

  public get outboundStops(): BusStop[] {
    return this._outboundStops;
  }

  private _inboundStops: BusStop[] = [];

  public set inboundStops(value: BusStop[]) {
    this._inboundStops = value;
  }

  public get inboundStops(): BusStop[] {
    return this._inboundStops;
  }

  async loadDetails(busNo: number, onUpdate?: UpdateCallback) {
    try {
      this._isLoading = true;
      this._error = null;

      const lines = await this.service.getAllLines();
      const schedules = await this.service.getSchedules(busNo);

      const foundLine = lines.find(l => l.busNumber === busNo);

      const outTimes = schedules.filter(t => t.outBond);
      const inTimes = schedules.filter(t => t.inBound);
      const stops = await this.service.getStops();
      const stopsFilter = stops.filter(t => t.busNo.split('-').includes(busNo.toString()));

      if (onUpdate && foundLine) {
        onUpdate(foundLine, outTimes, inTimes, stopsFilter);
      }
    } catch (error) {
      const err = error as BusinessError;
      this._error = 'Error when loading data';
      this._isLoading = false;

    }

  }
}