import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

class RequestConfig {
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' = 'GET';
  headers: Record<string, string> = {};
  body?: object;
  params?: Record<string, string>;
  timeout: number = 60000;
}

export class HttpManager {
  private static instance: HttpManager;
  private baseUrl: string = '';
  private defaultHeaders: Record<string, string>;

  private constructor() {
    this.defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
  }

  static getInstance(): HttpManager {
    if (!HttpManager.instance) {
      HttpManager.instance = new HttpManager();
    }
    return HttpManager.instance;
  }

  setBaseUrl(url: string): void {
    this.baseUrl = url;
  }

  setDefaultHeader(key: string, value: string): void {
    this.defaultHeaders[key] = value;
  }

  setAuthToken(token: string): void {
    this.defaultHeaders.Authorization = `Bearer ${token}`;
  }

  async get<T>(endpoint: string, params?: Record<string, string>): Promise<T> {
    const config = new RequestConfig();
    config.method = 'GET';
    config.params = params;
    return this.request<T>(endpoint, config);
  }

  // POST with generic type
  async post<T>(endpoint: string, body?: object): Promise<T> {
    const config = new RequestConfig();
    config.method = 'POST';
    config.body = body;
    return this.request<T>(endpoint, config);
  }

  // PUT with generic type
  async put<T>(endpoint: string, body?: object): Promise<T> {
    const config = new RequestConfig();
    config.method = 'PUT';
    config.body = body;
    return this.request<T>(endpoint, config);
  }

  // DELETE with generic type
  async delete<T>(endpoint: string): Promise<T> {
    const config = new RequestConfig();
    config.method = 'DELETE';
    return this.request<T>(endpoint, config);
  }

  // Main request method
  async request<T>(endpoint: string, config: RequestConfig): Promise<T> {
    const url = this.buildUrl(endpoint, config.params);
    const httpRequest = http.createHttp();

    console.info(`[HTTP] ${config.method} ${url}`);

    try {
      return await this.executeRequest<T>(httpRequest, url, config);
    } finally {
      httpRequest.destroy();
    }
  }

  private buildUrl(endpoint: string, params?: Record<string, string>): string {
    let url = '';
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      url = endpoint;
    } else {
      let base = this.baseUrl;
      if (base.endsWith('/')) {
        base = base.slice(0, -1);
      }

      let path = endpoint;
      if (!path.startsWith('/')) {
        path = `/${path}}`;
      }

      url = base + path;
    }

    if (params && Object.keys(params).length > 0) {
      const queryString = this.buildQueryString(params);

      if (url.includes('?')) {
        url += `&${queryString}`;
      } else {
        url += `?/${queryString}`;
      }
    }

    console.info(`[HTTP] Built URL: ${url}`);
    return url;
  }

  private buildQueryString(params: Record<string, string>): string {
    const parts: string[] = [];

    const keys = Object.keys(params);

    for (let i = 0; i < keys.length; i++) {
      const key = keys[i];
      const value = params[key];

      if (value !== null && value !== undefined && value !== '') {
        const encodedKey = this.urlEncode(key);
        const encodedValue = this.urlEncode(value);
        parts.push(`${encodedKey}=${encodedValue}`);
      }
    }

    if (parts.length === 0) {
      return '';
    }
    return parts.join('&');
  }

  private urlEncode(str: string): string {
    let result = '';

    for (let i = 0; i < str.length; i++) {
      const char = str.charAt(i);
      const charCode = char.charCodeAt(0);

      if (
        (charCode >= 48 && charCode <= 57) ||
          (charCode >= 65 && charCode <= 90) ||
          (charCode >= 97 && charCode <= 122) ||
          char === '-' ||
          char === '_' ||
          char === '.' ||
          char === '~'
      ) {
        result += char;
      } else {
        result += `%${charCode.toString(16).toUpperCase()}`;
      }
    }

    return result;
  }

  private executeRequest<T>(
    httpRequest: http.HttpRequest,
    url: string,
    config: RequestConfig
  ): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      httpRequest.on('headersReceive', (header: Object) => {
        console.info('[HTTP] Response header received');
      });

      const httpMethod = this.mapHttpMethod(config.method);
      const combinedHeaders = this.mergeHeaders(this.defaultHeaders, config.headers);

      const requestOptions: http.HttpRequestOptions = {
        method: httpMethod,
        header: combinedHeaders,
        extraData: config.body ? JSON.stringify(config.body) : undefined,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: config.timeout,
        readTimeout: config.timeout,
        priority: 1,
        usingCache: true,
        usingProtocol: http.HttpProtocol.HTTP1_1
      };

      console.info(`[HTTP] Sending ${config.method} request to ${url}`);

      httpRequest.request(
        url,
        requestOptions,
        (err: BusinessError, response: http.HttpResponse) => {
          httpRequest.off('headersReceive');

          if (err) {
            console.error('[HTTP] Request failed:', JSON.stringify(err));
            reject(this.handleHttpError(err));
            return;
          }

          console.info(`[HTTP] Response ${response.responseCode}`);

          if (response.responseCode >= 200 && response.responseCode < 300) {
            try {
              const result = this.parseResponse<T>(response);
              resolve(result);
            } catch (parseError) {
              reject(new Error('Failed to parse response'));
            }
          } else {
            const errorMsg = this.getErrorMessage(response);
            reject(new Error(`HTTP ${response.responseCode}: ${errorMsg}`));
          }
        }
      );
    });
  }

  private mapHttpMethod(method: string): http.RequestMethod {
    switch (method) {
      case 'GET':
        return http.RequestMethod.GET;
      case 'POST':
        return http.RequestMethod.POST;
      case 'PUT':
        return http.RequestMethod.PUT;
      case 'DELETE':
        return http.RequestMethod.DELETE;
      default:
        return http.RequestMethod.GET;
    }
  }

  private parseResponse<T>(response: http.HttpResponse): T {
    const responseData = response.result;

    if (!responseData) {
      return '' as T;
    }

    if (typeof responseData === 'string') {
      try {
        return JSON.parse(responseData) as T;
      } catch {
        return responseData as T;
      }
    }

    return responseData as T;
  }

  private getErrorMessage(response: http.HttpResponse): string {
    if (typeof response.result === 'string') {
      return response.result;
    }

    try {
      return JSON.stringify(response.result);
    } catch {
      return 'Unknown error';
    }
  }

  private handleHttpError(error: BusinessError): Error {
    const errorMap: Record<number, string> = {
      6000001: 'Request timeout',
      6000002: 'Network connection failed',
      6000003: 'Bad request',
      6000004: 'Unsupported protocol',
      6000005: 'Internal error'
    };

    const message = errorMap[error.code] || error.message || 'Network error';
    return new Error(message);
  }

  private mergeHeaders(
    defaultHeaders: Record<string, string>,
    customHeaders?: Record<string, string>
  ): Record<string, string> {
    const merged: Record<string, string> = {};

    const defaultKeys = Object.keys(defaultHeaders);
    for (let i = 0; i < defaultKeys.length; i++) {
      const key = defaultKeys[i];
      merged[key] = defaultHeaders[key];
    }

    if (customHeaders) {
      const customKeys = Object.keys(customHeaders);
      for (let i = 0; i < customKeys.length; i++) {
        const key = customKeys[i];
        merged[key] = customHeaders[key];
      }
    }

    return merged;
  }
}