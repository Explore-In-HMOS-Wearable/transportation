import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

const TAG = 'AudioUtils';
const DOMAIN = 0xFF00;

export enum PaymentSound {
  success = 'payment_success',
  failed = 'payment_failed'
}

export class AudioUtils {
  private static _avPlayer: media.AVPlayer | null = null;
  private static _isPlaying: boolean = false;

  private static async _ensurePlayer(): Promise<void> {
    if (AudioUtils._avPlayer) {
      return;
    }

    try {
      AudioUtils._avPlayer = await media.createAVPlayer();
      const audioManager = audio.getAudioManager();
      const audioRoutingManager = audioManager.getRoutingManager();
      AudioUtils._avPlayer.audioRendererInfo = {
        usage: audio.StreamUsage.STREAM_USAGE_NOTIFICATION,
        rendererFlags: 0
      };

      AudioUtils._avPlayer.on('audioOutputDeviceChangeWithInfo', () => {
        hilog.info(DOMAIN, TAG, 'AVPlayer audioOutputDeviceChangeWithInfo');
        AudioUtils._avPlayer?.pause();
        AudioUtils._isPlaying = false;
      });

      AudioUtils._avPlayer.on('stateChange', (state: string) => {
        hilog.info(DOMAIN, TAG, `AVPlayer state: ${state}`);

        if (state === 'initialized') {
          AudioUtils._avPlayer?.prepare();
        } else if (state === 'prepared') {
          AudioUtils._avPlayer!.setVolume(1.0);
          AudioUtils._avPlayer?.play();
        } else if (state === 'playing') {
          AudioUtils._isPlaying = true;
        } else if (state === 'completed' || state === 'stopped') {
          AudioUtils._isPlaying = false;
        }
      });
      AudioUtils._avPlayer.on('audioInterrupt', (interruptEvent) => {
        if (interruptEvent.hintType === audio.InterruptHint.INTERRUPT_HINT_PAUSE) {
          AudioUtils._avPlayer?.pause();
        } else if (interruptEvent.hintType === audio.InterruptHint.INTERRUPT_HINT_RESUME) {
          AudioUtils._avPlayer?.play();
        }
      });
      audioRoutingManager.on('deviceChange', audio.DeviceFlag.OUTPUT_DEVICES_FLAG, (deviceChangeAction) => {
        hilog.info(DOMAIN, TAG, `Device change type: ${deviceChangeAction.type}`);
        if (deviceChangeAction.type === audio.DeviceChangeType.DISCONNECT) {
          AudioUtils._avPlayer?.pause();
          hilog.info(DOMAIN, TAG, 'Audio device disconnected, pausing playback');
        } else if (deviceChangeAction.type === audio.DeviceChangeType.CONNECT) {
          deviceChangeAction.deviceDescriptors.forEach((device) => {
            if (device.deviceType === audio.DeviceType.SPEAKER) {
              AudioUtils._avPlayer?.pause();
              hilog.info(DOMAIN, TAG, 'Audio output switched to speaker, pausing playback');
            }
          });
        }
      });
      AudioUtils._avPlayer.on('error', (err: BusinessError) => {
        hilog.error(DOMAIN, TAG, `AVPlayer error: ${err.code} - ${err.message}`);
        AudioUtils._isPlaying = false;
      });

      hilog.info(DOMAIN, TAG, 'AVPlayer created successfully');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to create AVPlayer: ${error}`);
      AudioUtils._avPlayer = null;
    }
  }

  static async _playPaymentSound(context: common.UIAbilityContext, soundType: PaymentSound): Promise<void> {
    try {
      await AudioUtils._ensurePlayer();

      if (!AudioUtils._avPlayer) {
        hilog.error(DOMAIN, TAG, 'AVPlayer not available');
        return;
      }
      if (AudioUtils._isPlaying) {
        await AudioUtils._avPlayer.stop();
      }
      await AudioUtils._avPlayer.reset();

      const soundFileName = `${soundType}.mp3`;
      hilog.info(DOMAIN, TAG, `Loading sound: ${soundFileName}`);

      const fileDescriptor = await context.resourceManager.getRawFd(soundFileName);

      AudioUtils._avPlayer.fdSrc = {
        fd: fileDescriptor.fd,
        offset: fileDescriptor.offset,
        length: fileDescriptor.length
      };
      await context.resourceManager.closeRawFd(soundFileName);

      hilog.info(DOMAIN, TAG, `Playing ${soundFileName}`);

    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to play sound: ${error}`);
    }
  }

  static async _playSuccessSound(context: common.UIAbilityContext): Promise<void> {
    await AudioUtils._playPaymentSound(context, PaymentSound.success);
  }

  static async _playFailedSound(context: common.UIAbilityContext): Promise<void> {
    await AudioUtils._playPaymentSound(context, PaymentSound.failed);
  }

  static async release(): Promise<void> {
    if (!AudioUtils._avPlayer) {
      return;
    }

    try {
      if (AudioUtils._isPlaying) {
        await AudioUtils._avPlayer.stop();
      }

      await AudioUtils._avPlayer.release();
      AudioUtils._avPlayer = null;
      AudioUtils._isPlaying = false;

      hilog.info(DOMAIN, TAG, 'AVPlayer released');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to release AVPlayer: ${error}`);
    }
  }
}