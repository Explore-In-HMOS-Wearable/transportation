import { cardEmulation } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { bundleManager, common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'HceUtils';
const DOMAIN = 0xFF00;

export enum PaymentResult {
  success = 'success',
  failed = 'failed'
}

export class HceUtils {
  private static _hceService: cardEmulation.HceService | null = null;
  private static _hceElementName: bundleManager.ElementName | null = null;
  private static _isHceActive: boolean = false;

  static _hasHceSupport(): boolean {
    try {
      const hasSupport = cardEmulation.hasHceCapability();
      hilog.info(DOMAIN, TAG, `HCE support: ${hasSupport}`);
      return hasSupport;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Error checking HCE support: ${JSON.stringify(error)}`);
      return false;
    }
  }

  static _initHceService(context: common.UIAbilityContext): void {
    try {
      if (!HceUtils._hasHceSupport()) {
        hilog.error(DOMAIN, TAG, 'HCE not supported on this device');
        return;
      }

      HceUtils._hceService = new cardEmulation.HceService();

      HceUtils._hceElementName = {
        bundleName: context.abilityInfo.bundleName,
        moduleName: context.abilityInfo.moduleName ?? 'entry',
        abilityName: context.abilityInfo.name
      };

      hilog.info(DOMAIN, TAG, 'HCE service initialized successfully');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Error initializing HCE service: ${JSON.stringify(error)}`);
    }
  }

  static _startHcePayment(onApduReceived?: (apdu: number[]) => void): void {
    try {
      if (!HceUtils._hceService || !HceUtils._hceElementName) {
        hilog.error(DOMAIN, TAG, 'HCE service not initialized');
        return;
      }

      if (HceUtils._isHceActive) {
        hilog.warn(DOMAIN, TAG, 'HCE session already active');
        return;
      }

      const mockAidList = [
        '325041592E5359532E4444463031',
        'A0000000031010',
        'A0000000041010'
      ];

      HceUtils._hceService.start(HceUtils._hceElementName, mockAidList);
      HceUtils._isHceActive = true;

      HceUtils._hceService.on('hceCmd', (error: BusinessError | null, apduData: number[] | null) => {
        if (error) {
          hilog.error(DOMAIN, TAG, `HCE command error: ${error.code} - ${error.message}`);
          return;
        }

        if (apduData) {
          hilog.info(DOMAIN, TAG, `Received APDU from POS: ${JSON.stringify(apduData)}`);

          if (onApduReceived) {
            onApduReceived(apduData);
          }

          HceUtils._sendMockResponse(true);
        }
      });

      hilog.info(DOMAIN, TAG, 'HCE payment session started successfully');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Error starting HCE payment: ${JSON.stringify(error)}`);
      HceUtils._isHceActive = false;
    }
  }

  private static _sendMockResponse(success: boolean): void {
    if (!HceUtils._hceService) {
      return;
    }

    try {
      const response = success ? [0x90, 0x00] : [0x6A, 0x82];

      HceUtils._hceService.transmit(response).then(() => {
        hilog.info(DOMAIN, TAG, `Mock APDU response sent: ${success ? 'SUCCESS' : 'FAILED'}`);
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, `Failed to transmit APDU response: ${err.code} - ${err.message}`);
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Error sending mock response: ${JSON.stringify(error)}`);
    }
  }

  static async _simulatePosRead(): Promise<PaymentResult> {
    return new Promise((resolve) => {
      hilog.info(DOMAIN, TAG, 'Simulating POS terminal reading...');

      const readingDelay = 3000;

      const ms: number = Date.now();
      const rnd = ms % 100

      setTimeout(() => {
        const isSuccess = rnd > 50;
        const result = isSuccess ? PaymentResult.success : PaymentResult.failed;

        hilog.info(DOMAIN, TAG, `POS reading completed: ${result}`);

        HceUtils._sendMockResponse(isSuccess);

        resolve(result);
      }, readingDelay);
    });
  }

  static _stopHcePayment(): void {
    try {
      if (!HceUtils._hceService || !HceUtils._hceElementName) {
        return;
      }

      if (!HceUtils._isHceActive) {
        hilog.warn(DOMAIN, TAG, 'No active HCE session to stop');
        return;
      }

      HceUtils._hceService.off('hceCmd');

      HceUtils._hceService.stop(HceUtils._hceElementName);
      HceUtils._isHceActive = false;

      hilog.info(DOMAIN, TAG, 'HCE payment session stopped successfully');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Error stopping HCE payment: ${JSON.stringify(error)}`);
    }
  }

  static _isActive(): boolean {
    return HceUtils._isHceActive;
  }

  static _cleanup(): void {
    HceUtils._stopHcePayment();
    HceUtils._hceService = null;
    HceUtils._hceElementName = null;
    HceUtils._isHceActive = false;
    hilog.info(DOMAIN, TAG, 'HCE service cleaned up');
  }
}