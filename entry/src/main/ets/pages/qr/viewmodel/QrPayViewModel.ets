import { IdGeneratorService } from '../../../service/IdGeneratorService';

export interface QrPayload {
  type: string;
  id: string;
  ts: number;
}

@Observed
export class QrPayViewModel {
  @Track paymentId: string = '';
  @Track qrValue: string = '';
  private readonly idService: IdGeneratorService = new IdGeneratorService();

  init(): void {
    const newId: string = this.idService.createPaymentId();

    const payload: QrPayload = {
      type: 'PAYMENT_QR',
      id: newId,
      ts: Date.now()
    };

    this.paymentId = newId;
    this.qrValue = JSON.stringify(payload);
  }

  refresh(): void {
    this.init();
  }
}
