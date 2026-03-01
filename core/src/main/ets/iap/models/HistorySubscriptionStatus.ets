import { SubscriptionPurchaseOrder } from './SubscriptionPurchaseOrder';
import { SubscriptionRenewalInfo } from './SubscriptionRenewalInfo';

export interface HistorySubscriptionStatus {
  subGroupGenerationId: string;
  subscriptionId: string;
  purchaseToken: string;
  status: string;
  expiresTime: number;

  lastPurchaseOrder: SubscriptionPurchaseOrder;
  recentPurchaseOrderList?: SubscriptionPurchaseOrder[];
  renewalInfo?: SubscriptionRenewalInfo;
}