import { ProductModel } from 'core/src/main/ets/iap/models/ProductModel';

export enum BalanceDetailPageStateEnum{
  initial,
  loading,
  error,
  completed
}

export interface IBalanceDetailPageState {
  state?: BalanceDetailPageStateEnum;
  errorMessage?: ResourceStr;
  productList?: ProductModel[];
  selectedProduct?: ProductModel | null;
}