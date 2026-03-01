import { FinishStatus, IapEnvironment } from '../IapManager';

export interface SubscriptionPurchaseOrder {
  subGroupGenerationId: string;
  purchaseOrderId: string;
  subscriptionId: string;
  purchaseToken: string;
  applicationId: string;
  productId: string;
  subGroupId: string;
  purchaseTime: number;
  duration: string;
  durationTypeCode: string;
  productType: string;
  developerPayload?: string;
  signedTime: number;
  environment: IapEnvironment;
  countryCode: string;
  price: number;
  currency: string;
  finishStatus: FinishStatus | string;
  needFinish: boolean;
}