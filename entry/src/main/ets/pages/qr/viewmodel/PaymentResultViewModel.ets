import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { AudioUtils, PaymentResult, NavigationConstants } from 'core';

const TAG = 'PaymentResultViewModel';
const DOMAIN = 0xFF00;

@Observed
export class PaymentResultViewModel {
  public paymentResult: PaymentResult = PaymentResult.success;
  public animationOpacity: number = 0;
  private context: common.UIAbilityContext | null = null;
  private pathStack: NavPathStack | null = null;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  setPathStack(pathStack: NavPathStack): void {
    this.pathStack = pathStack;
  }

  async initialize(paymentResult: PaymentResult): Promise<void> {
    this.paymentResult = paymentResult;
    hilog.info(DOMAIN, TAG, `Payment result loaded: ${this.paymentResult}`);

    await this._playResultSound();
    this._startAnimation();
  }

  private async _playResultSound(): Promise<void> {
    if (!this.context) {
      return;
    }

    try {
      if (this.isSuccess()) {
        await AudioUtils._playSuccessSound(this.context);
      } else {
        await AudioUtils._playFailedSound(this.context);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Sound playback error: ${JSON.stringify(error)}`);
    }
  }

  private _startAnimation(): void {
    this.animationOpacity = 1;
  }

  isSuccess(): boolean {
    return this.paymentResult === PaymentResult.success;
  }

  done(): void {
    hilog.info(DOMAIN, TAG, 'User clicked Done');

    if (!this.pathStack) {
      hilog.error(DOMAIN, TAG, 'PathStack not initialized');
      return;
    }
    this.pathStack.clear();
    this.pathStack.pushPath({
      name: NavigationConstants.home
    });
  }

  tryAgain(): void {
    hilog.info(DOMAIN, TAG, 'User clicked Try Again');

    if (!this.pathStack) {
      hilog.error(DOMAIN, TAG, 'PathStack not initialized');
      return;
    }
    this.pathStack.pop();
  }
}