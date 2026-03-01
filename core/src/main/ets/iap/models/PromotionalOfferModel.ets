import { iap } from '@kit.IAPKit';

export interface PromotionalOfferModel {
  offerId: string;
  paymentMode: iap.OfferPaymentMode;
  periodUnit?: iap.PeriodUnit;
  periodCount?: number;
  localPrice: string;
  microPrice: number;
}
