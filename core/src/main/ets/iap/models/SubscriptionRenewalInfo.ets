import { IapEnvironment } from '../IapManager';

export interface SubscriptionRenewalInfo {
  subGroupGenerationId: string;
  productId: string;
  nextRenewPeriodProductId: string;
  renewalPrice: number;
  currency: string;
  autoRenewStatusCode: string;
  hasInBillingRetryPeriod: boolean;
  environment: IapEnvironment;
  renewalTime: number;
  nextRenewPeriodPayload?: string;
}