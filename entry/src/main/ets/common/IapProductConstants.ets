import { iap } from '@kit.IAPKit';

export interface ProductDefinition {
  id: string;
  type: iap.ProductType;
  icon: Resource;
}

export class ProductManager {
  static consumables: ProductDefinition[] = [
    {
      id: '50tl',
      type: iap.ProductType.CONSUMABLE,
      icon: $r('app.media.startIcon')
    },
    {
      id: '100tl',
      type: iap.ProductType.CONSUMABLE,
      icon: $r('app.media.startIcon')
    },
    {
      id: '200tl',
      type: iap.ProductType.CONSUMABLE,
      icon: $r('app.media.startIcon')
    }
  ];

  static all(): ProductDefinition[] {
    return [
      ...ProductManager.consumables
    ];
  }

  static idsOf(list: ProductDefinition[]): string[] {
    return list.map(p => p.id);
  }

  static findById(id: string): ProductDefinition | undefined {
    return ProductManager.all().find(p => p.id === id);
  }

  static formatPurchaseDate(timestamp: number): string {
    const date = new Date(timestamp);

    const day = date.getDate().toString().padStart(2, '0');
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const year = date.getFullYear();

    return `${day}/${month}/${year}`;
  }
}