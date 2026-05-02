
import { common } from '@kit.AbilityKit';
import { IapError, IapManager, ProductModel } from 'core';
import { ProductManager } from '../../../common/IapProductConstants';
import { BalanceDetailPageState } from '../state/BalanceDetailPageState';
import iap from '@hms.core.iap';
import { BalanceDetailPageStateEnum } from '../state/IBalanceDetailPageState';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class BalanceDetailPageViewModel {
  private _state: BalanceDetailPageState = BalanceDetailPageState.initial();
  private listeners: Array<(state: BalanceDetailPageState) => void> = [];
  private readonly TAG = 'BalanceDetailPageViewModel';

  get state(): BalanceDetailPageState {
    return this._state;
  }

  private setState(newState: BalanceDetailPageState): void {
    this._state = newState;
    this.notifyListeners();
  }

  addListener(listener: (state: BalanceDetailPageState) => void): void {
    this.listeners.push(listener);
  }

  removeAllListeners(): void {
    this.listeners = [];
  }

  private notifyListeners(): void {
    this.listeners.forEach(listener => listener(this._state));
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    this.setState(this.state.with({state: BalanceDetailPageStateEnum.loading}))
    await this.checkIsSandboxActivated(context)
    await this.checkQueryEnvironmentStatus(context)
    await this.queryProducts(context)
  }

  async checkIsSandboxActivated(context: common.UIAbilityContext): Promise<void> {
    const isSandboxActivated = await IapManager.getInstance().isSandboxActivated(context);
    if (!isSandboxActivated) {
      this.setState(this.state.with({
        state: BalanceDetailPageStateEnum.error,
        errorMessage: 'Sandbox is not activated. Please activate it'
      }))
      return
    }
  }

  async checkQueryEnvironmentStatus(context: common.UIAbilityContext): Promise<void> {
    const isEnabledQueryEnvironment = await IapManager.getInstance().queryEnvironmentStatus(context)
    if (!isEnabledQueryEnvironment) {
      this.setState(this.state.with({
        state: BalanceDetailPageStateEnum.error,
        errorMessage: 'Environment Status is not activated. Please activate it'
      }))
    }
  }

  async queryProducts(context: common.UIAbilityContext): Promise<void> {
    const products = await IapManager.getInstance().queryProducts(
      context,
      ProductManager.idsOf(ProductManager.consumables),
      iap.ProductType.CONSUMABLE
    );

    const enrichedProducts = products.map(product => {
      product.displayName = product.name;
      product.image = product?.image;
      return product;
    });

    this.setState(this.state.with({ productList: enrichedProducts!, state: BalanceDetailPageStateEnum.completed}))

  }

  async createPurchase(
    context: common.UIAbilityContext,
    product: ProductModel
  ): Promise<void> {
    await this.purchase(context, product);
  }

  async purchase(
    context: common.UIAbilityContext,
    product: ProductModel
  ): Promise<void> {
    try {

      const result = await IapManager.getInstance().createPurchase(
        context,
        product.id!,
        product.type!
      );

      await IapManager.getInstance().handleCreatePurchaseResult(result, context, product.type!);

      this.setState(this.state.with({selectedProduct: null}))

    } catch (error) {
      if (error instanceof IapError) {
        this.setState(this.state.with({state: BalanceDetailPageStateEnum.error, errorMessage: `code: ${error.sdkCode} message: ${error.message}`}))
      } else {
        this.setState(this.state.with({state: BalanceDetailPageStateEnum.error, errorMessage: `Unknown Error: ${error}`}))
      }
    }
  }

  setSelectedProduct(product: ProductModel) {
    this.setState(this.state.with({selectedProduct: product}))
  }
}