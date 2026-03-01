import { FinishStatus, IapEnvironment } from '../IapManager';

export interface PurchaseOrderPayload {
  purchaseOrderId: string;
  purchaseToken: string;
  applicationId: string;
  productId: string;
  purchaseTime: number;
  productType: string;
  developerPayload?: string;
  signedTime: number;
  environment: IapEnvironment;
  countryCode: string;
  price: number;
  currency: string;
  finishStatus: FinishStatus | string;
  needFinish: boolean;

  title?: string;
  icon?: Resource;
}