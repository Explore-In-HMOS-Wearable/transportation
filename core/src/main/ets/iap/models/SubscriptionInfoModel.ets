import { SubscriptionOfferModel } from './SubscriptionOfferModel';
import { iap } from '@kit.IAPKit';

export interface SubscriptionInfoModel {
  periodUnit: iap.PeriodUnit;
  periodCount: number;
  groupId: string;
  groupLevel: number;
  hasEligibilityForIntroOffer?: boolean;
  introductoryOffer?: SubscriptionOfferModel;
}