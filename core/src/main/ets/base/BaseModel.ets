export interface BaseModel {
  toJson: () => object;
}

export interface BaseModelConstructor<T extends BaseModel> {
  fromJson(json: object): T;
}
