import { common } from '@kit.AbilityKit';
import { iap } from '@kit.IAPKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ProductModel } from './models/ProductModel';
import { PurchaseOrderPayload } from './models/PurchaseOrderPayload';
import { SubscriptionStatusPayload } from './models/SubscriptionStatusPayload';
import { SubscriptionPurchaseOrder } from './models/SubscriptionPurchaseOrder';
import { JWSUtil } from './JwsUtil';

export type IapEnvironment = 'SANDBOX' | 'PRODUCTION' | 'RELEASE';

export enum FinishStatus {
  FINISHED = '1',
  UNFINISHED = '2'
}

function safeJsonParse<T>(json: string): T | undefined {
  try {
    return JSON.parse(json) as T;
  } catch (e) {
    hilog.error(0, 'IapManager', `JSON parse failed: ${JSON.stringify(e)}`);
    return undefined;
  }
}

function parseProductType(type: string): iap.ProductType {
  return Number(type) as iap.ProductType;
}

export enum IapDomainError {
  userCancelled,
  retryable,
  permission,
  configuration,
  network,
  alreadyOwned,
  invalidState,
  fatal
}

export class IapError extends Error {
  public readonly domain: IapDomainError;
  public readonly sdkCode: iap.IAPErrorCode;
  public readonly original?: BusinessError;

  constructor(
    domain: IapDomainError,
    sdkCode: iap.IAPErrorCode,
    message?: string,
    original?: BusinessError
  ) {
    super(message ?? IapDomainError[domain]);
    this.domain = domain;
    this.sdkCode = sdkCode;
    this.original = original;
  }
}

function handleIapError(err: BusinessError): IapError {
  const code = (err?.code ?? -1) as iap.IAPErrorCode;

  switch (code) {
    case iap.IAPErrorCode.USER_CANCELED:
      return new IapError(IapDomainError.userCancelled, code, 'User cancelled purchase', err);

    case iap.IAPErrorCode.NETWORK_ERROR:
    case iap.IAPErrorCode.FREQUENT_CALLS:
      return new IapError(IapDomainError.retryable, code, err?.message, err);

    case iap.IAPErrorCode.PRODUCT_OWNED:
      return new IapError(IapDomainError.alreadyOwned, code, err?.message, err);

    case iap.IAPErrorCode.ACCOUNT_NOT_LOGGED_IN:
    case iap.IAPErrorCode.USER_NOT_ALLOWED:
      return new IapError(IapDomainError.permission, code, err?.message, err);

    case iap.IAPErrorCode.INVALID_PRODUCT:
    case iap.IAPErrorCode.APP_NOT_AUTHORIZED:
      return new IapError(IapDomainError.configuration, code, err?.message, err);

    default:
      return new IapError(IapDomainError.fatal, code, err?.message, err);
  }
}

export class IapManager {
  private static instance?: IapManager;
  private static readonly TAG = 'IapManager';

  private constructor() {
  }

  static getInstance(): IapManager {
    if (!IapManager.instance) {
      IapManager.instance = new IapManager();
    }
    return IapManager.instance;
  }

  async queryEnvironmentStatus(context: common.UIAbilityContext): Promise<boolean> {
    try {
      await iap.queryEnvironmentStatus(context);
      return true;
    } catch {
      return false;
    }
  }

  async isSandboxActivated(context: common.UIAbilityContext): Promise<boolean> {
    try {
      return await iap.isSandboxActivated(context);
    } catch {
      return false;
    }
  }

  async queryProducts(
    context: common.UIAbilityContext,
    productIds: string[],
    productType: iap.ProductType
  ): Promise<ProductModel[]> {
    const param: iap.QueryProductsParameter = { productType, productIds };

    try {
      const products: iap.Product[] = await iap.queryProducts(context, param);
      return products.map((p: iap.Product): ProductModel => ProductModel.fromIapProduct(p));
    } catch (e) {
      const ie = handleIapError(e);
      throw new Error(`queryProducts failed: ${ie.message} (code=${ie.sdkCode})`);
    }
  }

  async createPurchase(
    context: common.UIAbilityContext,
    productId: string,
    productType: iap.ProductType,
    developerPayload: string = 'payload'
  ): Promise<iap.CreatePurchaseResult> {
    try {
      const result = await iap.createPurchase(context, {
        productId,
        productType,
        developerPayload
      });
      return result;
    } catch (e) {
      const ie = handleIapError(e);
      throw new Error(`createPurchase failed: ${ie.message} (code=${ie.sdkCode})`);
    }
  }

  async finishPurchase(
    context: common.UIAbilityContext,
    productType: iap.ProductType,
    purchaseToken: string,
    purchaseOrderId: string
  ): Promise<boolean> {
    try {
      await iap.finishPurchase(context, {
        productType,
        purchaseToken,
        purchaseOrderId
      });
      return true;
    } catch (e) {
      const ie = handleIapError(e);
      hilog.error(0, IapManager.TAG, `finishPurchase failed: ${ie.message}`);
      return false;
    }
  }

  async dealPurchaseOrderJws(
    jwsPurchaseOrder: string,
    context: common.UIAbilityContext
  ): Promise<void> {

    const payloadStr = JWSUtil.decodeJwsObj(jwsPurchaseOrder);
    if (!payloadStr) {
      hilog.warn(0, IapManager.TAG, 'JWS decode failed');
      return;
    }

    const payload = safeJsonParse<PurchaseOrderPayload>(payloadStr);
    if (!payload) {
      hilog.warn(0, IapManager.TAG, 'PurchaseOrder payload parse failed');
      return;
    }

    if (!payload.needFinish || payload.finishStatus === FinishStatus.FINISHED) {
      return;
    }

    try {
      const ok = await this.finishPurchase(
        context,
        parseProductType(payload.productType),
        payload.purchaseToken,
        payload.purchaseOrderId
      );

      hilog.info(
        0,
        IapManager.TAG,
        `finishPurchase result=${ok} productId=${payload.productId}`
      );

    } catch (e) {
      hilog.error(
        0,
        IapManager.TAG,
        `finishPurchase failed productId=${payload.productId}, error=${JSON.stringify(e)}`
      );
    }
  }

  async dealSubscriptionStatusJws(
    jwsSubscriptionStatus: string,
    context: common.UIAbilityContext
  ): Promise<void> {

    const payloadStr = JWSUtil.decodeJwsObj(jwsSubscriptionStatus);
    if (!payloadStr) {
      hilog.warn(0, IapManager.TAG, 'Subscription JWS decode failed');
      return;
    }

    const payload = safeJsonParse<SubscriptionStatusPayload>(payloadStr);
    if (!payload) {
      hilog.warn(0, IapManager.TAG, 'Subscription payload parse failed');
      return;
    }

    const last = payload.lastSubscriptionStatus;
    const order = last?.lastPurchaseOrder;
    if (!order) {
      hilog.warn(0, IapManager.TAG, 'No lastPurchaseOrder found');
      return;
    }

    const isActive =
      last.status === '1' && last.expiresTime > Date.now();

    hilog.info(
      0,
      IapManager.TAG,
      `subscription active=${isActive} productId=${order.productId}`
    );

    if (!order.needFinish || order.finishStatus === FinishStatus.FINISHED) {
      return;
    }

    try {
      const ok = await this.finishPurchase(
        context,
        iap.ProductType.AUTORENEWABLE,
        order.purchaseToken,
        order.purchaseOrderId
      );

      hilog.info(
        0,
        IapManager.TAG,
        `subscription ACK finished=${ok} productId=${order.productId}`
      );

    } catch (e) {
      hilog.error(
        0,
        IapManager.TAG,
        `subscription ACK failed productId=${order.productId}, error=${JSON.stringify(e)}`
      );
    }
  }

  async queryPurchaseOrders(
    context: common.UIAbilityContext,
    productType: iap.ProductType,
    queryType: iap.PurchaseQueryType
  ): Promise<PurchaseOrderPayload[]> {
    const all: PurchaseOrderPayload[] = [];
    let continuationToken: string | undefined;

    try {
      do {
        const result = await iap.queryPurchases(context, {
          productType,
          queryType,
          continuationToken
        });

        for (const jws of result.purchaseDataList ?? []) {
          const payloadStr = JWSUtil.decodeJwsObj(jws);
          if (!payloadStr) {
            continue;
          }

          const payload = safeJsonParse<PurchaseOrderPayload>(payloadStr);
          if (payload) {
            all.push(payload);
          }
        }

        continuationToken = result.continuationToken;
      } while (continuationToken);

      return all;
    } catch (e) {
      const ie = handleIapError(e);
      throw new Error(`queryPurchaseOrders failed: ${ie.message} (code=${ie.sdkCode})`);
    }
  }

  async querySubscriptionOrders(
    context: common.UIAbilityContext,
    queryType: iap.PurchaseQueryType
  ): Promise<SubscriptionPurchaseOrder[]> {
    const all: SubscriptionPurchaseOrder[] = [];
    let continuationToken: string | undefined;

    try {
      do {
        const result = await iap.queryPurchases(context, {
          productType: iap.ProductType.AUTORENEWABLE,
          queryType,
          continuationToken
        });

        for (const jws of result.purchaseDataList ?? []) {
          const payloadStr = JWSUtil.decodeJwsObj(jws);
          if (!payloadStr) {
            continue;
          }

          const payload = safeJsonParse<SubscriptionStatusPayload>(payloadStr);
          const order = payload?.lastSubscriptionStatus?.lastPurchaseOrder;

          if (order) {
            all.push(order);
          }
        }

        continuationToken = result.continuationToken;
      } while (continuationToken);

      return all;
    } catch (e) {
      const ie = handleIapError(e);
      throw new Error(`querySubscriptionOrders failed: ${ie.message} (code=${ie.sdkCode})`);
    }
  }

  async showManagedSubscriptions(context: common.UIAbilityContext, groupId?: string): Promise<boolean> {
    try {
      const ui: iap.UIWindowParameter = { windowScreenMode: iap.WindowScreenMode.DIALOG_BOX };
      await iap.showManagedSubscriptions(context, ui, groupId);
      return true;
    } catch {
      return false;
    }
  }

  async handleCreatePurchaseResult(
    result: iap.CreatePurchaseResult,
    context: common.UIAbilityContext,
    productType: iap.ProductType
  ): Promise<void> {

    if (result.purchaseData && productType === iap.ProductType.AUTORENEWABLE) {
      await this.dealSubscriptionStatusJws(
        result.purchaseData,
        context
      );
      return;
    } else if (result.purchaseData) {
      await this.dealPurchaseOrderJws(
        result.purchaseData,
        context
      );
      return;
    }

  }
}

//export const iapProductType = iap.ProductType;  // TODO
//export const iapPurchaseQueryType = iap.PurchaseQueryType; //TODO
