import { PromotionalOfferModel } from './PromotionalOfferModel';
import { SubscriptionInfoModel } from './SubscriptionInfoModel';
import { iap } from '@kit.IAPKit';

export class ProductModel {
  id?: string;
  type?: iap.ProductType;
  name?: string;
  description?: string;
  localPrice?: string;
  microPrice?: number;
  originalLocalPrice?: string;
  originalMicroPrice?: number;
  currency?: string;
  status?: iap.ProductStatus;
  subscriptionInfo?: SubscriptionInfoModel;
  promotionalOffers?: PromotionalOfferModel[];
  jsonRepresentation?: string;

  // For UI not from IAP
  displayName?: string;
  image?: Resource;

  static fromIapProduct(product: iap.Product): ProductModel {
    const model = new ProductModel();
    model.id = product.id;
    model.type = product.type;
    model.name = product.name;
    model.description = product.description;
    model.localPrice = product.localPrice;
    model.microPrice = product.microPrice;
    model.originalLocalPrice = product.originalLocalPrice;
    model.originalMicroPrice = product.originalMicroPrice;
    model.currency = product.currency;
    model.status = product.status;
    model.subscriptionInfo = product.subscriptionInfo as SubscriptionInfoModel | undefined;
    model.promotionalOffers = product.promotionalOffers as PromotionalOfferModel[] | undefined;
    model.jsonRepresentation = product.jsonRepresentation;
    return model;
  }
}