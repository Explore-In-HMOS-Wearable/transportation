import http from '@ohos.net.http';
import { CKANResponse } from '../../model/searchPageModel/CKANResponse';

export class ApiManager {
  async executeGet<T>(url: string): Promise<T[]> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: { 'Content-Type': 'application/json' },
        expectDataType: http.HttpDataType.STRING,
        readTimeout: 15000
      });

      if (response.responseCode === 200) {
        const responseData = JSON.parse(response.result.toString()) as CKANResponse<T>;
        if (responseData && responseData.success && responseData.result) {
          return responseData.result.records;
        }
      } else {
        console.error(`API_FAIL | Code: ${response.responseCode} | URL: ${url}`);
      }
      return [];
    } catch (err) {
      console.error('NETWORK_CRASH: ' + (err as Error).message);
      return [];
    } finally {
      httpRequest.destroy();
    }
  }
}