import { BusLine } from '../../model/searchPageModel/BusLine';
import { BusSchedule } from '../../model/searchPageModel/BusSchedule';
import { BusStop } from '../../model/searchPageModel/BusStop';
import { RawBusLine } from '../../model/searchPageModel/RawBusLine';
import { RawBusSchedule } from '../../model/searchPageModel/RawBusSchedule';
import { RawBusStop } from '../../model/searchPageModel/RawBusStop';
import { ApiManager } from './ApiManager';

export class EshotService {
  private apiManager = new ApiManager();
  // set base url
  private readonly baseUrl = '';

  private readonly activeLinesId = 'c6fa6046-f755-47d7-b69e-db6bb06a8b5a';
  async getAllLines(): Promise<BusLine[]> {
    const urlLine = this.baseUrl + `?resource_id=bd6c84f8-49ba-4cf4-81f8-81a0fbb5caa3`;
    const url = urlLine;

    const rawData = await this.apiManager.executeGet<RawBusLine>(url);

    return rawData.map((item: RawBusLine): BusLine => ({
      busNumber: item.ROUTE_NUMBER,
      busMap: item.ROUTE_NAME
    }));
  };

  async getSchedules(busNo: number): Promise<BusSchedule[]> {
    const filters = encodeURIComponent(JSON.stringify({ 'HAT_NO': busNo }));
    const url = `${this.baseUrl}?resource_id=${this.activeLinesId}&filters=${filters}`;
    const rawData = await this.apiManager.executeGet<RawBusSchedule>(url);
    return rawData.map((item: RawBusSchedule): BusSchedule => {

      const busNo = item.ROUTE_NO;
      const inBound = item.DEPARTURE_TIME;
      const outBound = item.RETURN_TIME;

      return {
        busNo:busNo,
        inBound:inBound,
        outBond:outBound
      };
    });
  };

  async getStops(): Promise<BusStop[]> {
    const resourceId = `0c791266-a2e4-4f14-82b8-9a9b102fbf94`;
    const url = `${this.baseUrl}?resource_id=${resourceId}`;

    const rawData = await this.apiManager.executeGet<RawBusStop>(url);

    return rawData.map((item: RawBusStop): BusStop => {

      return {
        stopName: item.STOP_NAME,
        busNo: item.LINES_PASSING_THROUGH_STOP,
        stopId: item.STOP_ID
      };
    });
  };
};