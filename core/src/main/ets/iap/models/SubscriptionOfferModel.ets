import { iap } from '@kit.IAPKit';

export interface SubscriptionOfferModel {
  paymentMode: iap.OfferPaymentMode;
  periodUnit: iap.PeriodUnit;
  periodCount: number;
  localPrice: string;
  microPrice: number;
  offerType: iap.OfferType;
}