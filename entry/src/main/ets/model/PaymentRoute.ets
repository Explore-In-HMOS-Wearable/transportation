export type PaymentRouteName = 'PaymentHome' | 'QrPay' | 'NfcPay' | 'PaymentResult';

export interface PaymentRouteItem {
  title: string;
  route: PaymentRouteName;
}