import { ProductModel } from 'core/src/main/ets/iap/models/ProductModel';
import { IBalanceDetailPageState, BalanceDetailPageStateEnum } from './IBalanceDetailPageState';

export class BalanceDetailPageState {
  public errorMessage?: ResourceStr;
  public state?: BalanceDetailPageStateEnum;
  public productList?: ProductModel[];
  public selectedProduct?: ProductModel | null;

  constructor(init: IBalanceDetailPageState) {
    this.state = init.state;
    this.errorMessage = init.errorMessage;
    this.productList = init.productList;
    this.selectedProduct = init.selectedProduct;
  }

  with(updates: IBalanceDetailPageState): BalanceDetailPageState {
    return new BalanceDetailPageState({
      errorMessage: updates.errorMessage ?? this.errorMessage,
      state: updates.state ?? this.state,
      productList: updates.productList ?? this.productList,
      selectedProduct: updates.selectedProduct ?? this.selectedProduct
    });
  }

  static initial(): BalanceDetailPageState {
    return new BalanceDetailPageState({
      errorMessage: '',
      state: BalanceDetailPageStateEnum.initial,
      productList: [],
      selectedProduct: null
    });
  }
}
