import { IapEnvironment } from '../IapManager';
import { HistorySubscriptionStatus } from './HistorySubscriptionStatus';
import { LastSubscriptionStatus } from './LastSubscriptionStatus';

export interface SubscriptionStatusPayload {
  environment: IapEnvironment;
  applicationId: string;
  packageName: string;
  subGroupId: string;

  lastSubscriptionStatus: LastSubscriptionStatus;
  historySubscriptionStatusList?: HistorySubscriptionStatus[];
}
