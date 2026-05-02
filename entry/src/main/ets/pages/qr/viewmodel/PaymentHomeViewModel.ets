import { PaymentRouteItem } from '../../../model/PaymentRoute';

@Observed
export class PaymentHomeViewModel {
  readonly actions: PaymentRouteItem[] = [
    { title: 'QR Code', route: 'QrPay' },
    { title: 'NFC Pay', route: 'NfcPay' },
    { title: 'PaymentResult Pay', route: 'PaymentResult' }
  ];
}