import { nfcController } from '@kit.ConnectivityKit';
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'NfcUtils';
const DOMAIN = 0xFF00;

export class NfcUtils {
  static _hasNfcSupport(): boolean {
    try {
      const hasSupport = canIUse('SystemCapability.Communication.NFC.Core');
      hilog.info(DOMAIN, TAG, `NFC support: ${hasSupport}`);
      return hasSupport;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Error checking NFC support: ${JSON.stringify(error)}`);
      return false;
    }
  }

  static _isNfcEnabled(): boolean {
    try {
      if (!NfcUtils._hasNfcSupport()) {
        return false;
      }
      const isOpen = nfcController.isNfcOpen();
      hilog.info(DOMAIN, TAG, `NFC enabled: ${isOpen}`);
      return isOpen;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Error checking NFC state: ${JSON.stringify(error)}`);
      return false;
    }
  }

  static _getNfcState(): number {
    try {
      if (!NfcUtils._hasNfcSupport()) {
        return 1;
      }
      const state = nfcController.getNfcState();
      hilog.info(DOMAIN, TAG, `NFC state: ${state}`);
      return state;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Error getting NFC state: ${JSON.stringify(error)}`);
      return 1;
    }
  }

  static _openNfcSettings(context: common.UIAbilityContext): void {
    try {
      const want: Want = {
        bundleName: 'com.huawei.hmos.settings',
        abilityName: 'com.huawei.hmos.settings.MainAbility',
        uri: 'nfc_settings',
        parameters: {
          pushParams: context.abilityInfo.bundleName
        }
      };

      context.startAbility(want).then(() => {
        hilog.info(DOMAIN, TAG, 'Successfully opened NFC settings');
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, `Failed to open NFC settings. Code: ${err.code}, message: ${err.message}`);
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Error opening NFC settings: ${JSON.stringify(error)}`);
    }
  }

  static _registerNfcStateListener(callback: (state: number) => void): void {
    try {
      if (!NfcUtils._hasNfcSupport()) {
        hilog.warn(DOMAIN, TAG, 'Cannot register NFC listener: NFC not supported');
        return;
      }

      nfcController.on('nfcStateChange', (nfcState: number) => {
        hilog.info(DOMAIN, TAG, `NFC state changed to: ${nfcState}`);
        callback(nfcState);
      });

      hilog.info(DOMAIN, TAG, 'NFC state listener registered');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Error registering NFC listener: ${JSON.stringify(error)}`);
    }
  }

  static _unregisterNfcStateListener(): void {
    try {
      if (!NfcUtils._hasNfcSupport()) {
        return;
      }

      nfcController.off('nfcStateChange');
      hilog.info(DOMAIN, TAG, 'NFC state listener unregistered');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Error unregistering NFC listener: ${JSON.stringify(error)}`);
    }
  }
}