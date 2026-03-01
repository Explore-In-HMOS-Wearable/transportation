import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { HceUtils, NfcUtils, AudioUtils, PaymentResult, NavigationConstants } from 'core';

const TAG = 'PaymentIndexViewModel';
const DOMAIN = 0xFF00;

export enum PaymentState {
  checkingNfc,
  nfcNotSupported,
  nfcDisabled,
  readyToPay,
  processing,
  completed
}

@Observed
export class PaymentIndexViewModel {
  public currentState: PaymentState = PaymentState.checkingNfc;
  public isProcessing: boolean = false;
  public processingMessage: string = '';
  private context: common.UIAbilityContext | null = null;
  private pathStack: NavPathStack | null = null;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  setPathStack(pathStack: NavPathStack): void {
    this.pathStack = pathStack;
  }

  initialize(): void {
    hilog.info(DOMAIN, TAG, 'Initializing payment system');
    this._checkNfcAvailability();
  }

  cleanup(): void {
    hilog.info(DOMAIN, TAG, 'Cleaning up payment system');
    NfcUtils._unregisterNfcStateListener();
    HceUtils._cleanup();
    AudioUtils.release();
  }

  private _checkNfcAvailability(): void {
    if (!NfcUtils._hasNfcSupport()) {
      this.currentState = PaymentState.nfcNotSupported;
      hilog.warn(DOMAIN, TAG, 'NFC not supported on this device');
      return;
    }

    if (!NfcUtils._isNfcEnabled()) {
      this.currentState = PaymentState.nfcDisabled;
      hilog.warn(DOMAIN, TAG, 'NFC is disabled');

      NfcUtils._registerNfcStateListener((state: number) => {
        hilog.info(DOMAIN, TAG, `NFC state changed: ${state}`);
        this._checkNfcAvailability();
      });
      return;
    }

    this._initializePaymentSystem();
  }

  private _initializePaymentSystem(): void {
    if (!this.context) {
      return;
    }

    HceUtils._initHceService(this.context);

    NfcUtils._registerNfcStateListener((state: number) => {
      hilog.info(DOMAIN, TAG, `NFC state changed: ${state}`);
      if (!NfcUtils._isNfcEnabled()) {
        HceUtils._cleanup();
        this.currentState = PaymentState.nfcDisabled;
      }
    });

    this.currentState = PaymentState.readyToPay;
    hilog.info(DOMAIN, TAG, 'NFC is ready for payment');
    this._startListeningForPos();
  }

  private _startListeningForPos(): void {
    hilog.info(DOMAIN, TAG, 'Waiting for POS terminal...');

    HceUtils._startHcePayment((apduData: number[]) => {
      hilog.info(DOMAIN, TAG, `POS detected! APDU: ${JSON.stringify(apduData)}`);

      if (!this.isProcessing) {
        this._startPaymentProcess();
      }
    });
  }

  private async _startPaymentProcess(): Promise<void> {
    if (this.isProcessing) {
      return;
    }

    try {
      this.isProcessing = true;
      this.currentState = PaymentState.processing;
      this.processingMessage = 'Processing payment...';

      const result = await HceUtils._simulatePosRead();

      HceUtils._stopHcePayment();

      this.currentState = PaymentState.completed;

      await this._navigateToResult(result);

    } catch (error) {
      hilog.error(DOMAIN, TAG, `Payment process error: ${JSON.stringify(error)}`);
      this.isProcessing = false;
      this.currentState = PaymentState.readyToPay;
    }
  }

  private async _navigateToResult(result: PaymentResult): Promise<void> {
    try {
      if (!this.pathStack) {
        hilog.error(DOMAIN, TAG, 'PathStack not initialized');
        return;
      }

      setTimeout(() => {
        if (this.pathStack) {
          this.pathStack.pushPath({
            name: NavigationConstants.paymentResult,
            param: result
          });
          hilog.info(DOMAIN, TAG, `Navigated to result: ${result}`);
        }
      }, 500);

    } catch (error) {
      hilog.error(DOMAIN, TAG, `Result navigation error: ${JSON.stringify(error)}`);
    }
  }

  openNfcSettings(): void {
    if (!this.context) {
      return;
    }

    hilog.info(DOMAIN, TAG, 'Opening NFC settings');
    NfcUtils._openNfcSettings(this.context);
  }

  continueWithQr(): void {
    hilog.info(DOMAIN, TAG, 'User chose to continue with QR payment');
    if (this.pathStack) {
      this.pathStack.pushPath({
        name: NavigationConstants.qrPay
      });
    }
  }
}