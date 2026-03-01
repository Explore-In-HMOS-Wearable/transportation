import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import type { common } from '@kit.AbilityKit';
import { LogManager } from '../logger/LogManager';

export class NotificationManager {
  private static instance: NotificationManager;

  private constructor() {
  }

  public static getInstance(): NotificationManager {
    if (!NotificationManager.instance) {
      NotificationManager.instance = new NotificationManager();
    }
    return NotificationManager.instance;
  }

  async requestPermission(context: common.UIAbilityContext): Promise<boolean> {
    try {
      const isEnabled = await notificationManager.isNotificationEnabled();
      LogManager.info('notification', `Notification enabled: ${isEnabled}`);
      if (!isEnabled) {
        await notificationManager.requestEnableNotification(context);
        LogManager.info('notification', 'Permission granted after request.');
      }
      return true;
    } catch (err) {
      const error = err as BusinessError;
      LogManager.error('notification', `Permission check/request failed: ${error.code} - ${error.message}`);
      return false;
    }
  }

  publishSimpleNotification(title: string, text: string, additional: string = '', id: number = 1000): void {
    const request: notificationManager.NotificationRequest = {
      id,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title,
          text,
          additionalText: additional
        }
      }
    };

    notificationManager.publish(request, (err: BusinessError) => {
      if (err) {
        LogManager.error('notification', `Publish failed: ${err.code}, ${err.message}`);
      } else {
        LogManager.info('notification', 'Notification published successfully.');
      }
    });
  }

  publishProgressNotification(progress: number, id: number = 2000): void {
    const request: notificationManager.NotificationRequest = {
      id,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: 'Download in progress',
          text: `Downloading... ${progress}%`,
          additionalText: ''
        }
      },
      template: {
        name: 'downloadTemplate',
        data: {
          title: 'Download Progress',
          fileName: 'file.zip',
          progressValue: progress
        }
      }
    };

    notificationManager.publish(request, (err: BusinessError) => {
      if (err) {
        LogManager.error('notification', `Progress notification failed: ${err.code}, ${err.message}`);
      } else {
        LogManager.info('notification', 'Progress notification published.');
      }
    });
  }

  setBadgeNumber(number: number): void {
    notificationManager.setBadgeNumber(number, (err: BusinessError) => {
      if (err) {
        LogManager.error('notification', `setBadgeNumber failed: ${err.code}, ${err.message}`);
      } else {
        LogManager.info('notification', `Badge number set to ${number}.`);
      }
    });
  }

  addSlot(type: notificationManager.SlotType): void {
    notificationManager.addSlot(type, (err: BusinessError) => {
      if (err) {
        LogManager.error('notification', `addSlot failed: ${err.code}, ${err.message}`);
      } else {
        LogManager.info('notification', `Slot ${type} added.`);
      }
    });
  }

  getSlot(type: notificationManager.SlotType): void {
    notificationManager.getSlot(type, (err: BusinessError, data: notificationManager.NotificationSlot) => {
      if (err) {
        LogManager.error('notification', `getSlot failed: ${err.code}, ${err.message}`);
      } else {
        LogManager.info('notification', `Slot info: enabled=${data.enabled}`);
      }
    });
  }

  removeSlot(type: notificationManager.SlotType): void {
    notificationManager.removeSlot(type, (err: BusinessError) => {
      if (err) {
        LogManager.error('notification', `removeSlot failed: ${err.code}, ${err.message}`);
      } else {
        LogManager.info('notification', `Slot ${type} removed.`);
      }
    });
  }
}
