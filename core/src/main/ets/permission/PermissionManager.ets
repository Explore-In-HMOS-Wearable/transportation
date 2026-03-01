// PermissionManager.ts
import { Permissions, abilityAccessCtrl, bundleManager, common } from '@kit.AbilityKit';

interface PermissionRequestResult {
  authResults: number[];
  permissions?: Permissions[];
}

export class PermissionType {
  static readonly MIC: Permissions = 'ohos.permission.MICROPHONE';
  static readonly CAMERA: Permissions = 'ohos.permission.CAMERA';
  static readonly LOCATION: Permissions = 'ohos.permission.LOCATION';
  static readonly APPROX_LOCATION: Permissions = 'ohos.permission.APPROXIMATELY_LOCATION';
  static readonly BLUETOOTH: Permissions = 'ohos.permission.ACCESS_BLUETOOTH';
  static readonly NFC_CARD: Permissions = 'ohos.permission.NFC_CARD_EMULATION';
}

export enum PermissionResult {
  granted = 'GRANTED',
  denied = 'DENIED',
  error = 'ERROR'
}

export type OnePerm = string | Permissions;

function toPerm(p: OnePerm): Permissions {
  return p as Permissions;
}

function getSelfTokenId(): number {
  const info = bundleManager.getBundleInfoForSelfSync(
    bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
  );
  return info.appInfo.accessTokenId;
}

export class PermissionManager {
  private static instance?: PermissionManager;
  private static readonly TAG = '[PermissionManager]';

  static getInstance(): PermissionManager {
    if (!PermissionManager.instance) {
      PermissionManager.instance = new PermissionManager();
      console.info(`${PermissionManager.TAG} instance created`);
    }
    return PermissionManager.instance;
  }

  checkPermission(perm: OnePerm): PermissionResult {
    const p = toPerm(perm);
    const tokenId = getSelfTokenId();
    const at = abilityAccessCtrl.createAtManager();
    try {
      const st = at.checkAccessTokenSync(tokenId, p);
      console.info(`${PermissionManager.TAG} checkPermission ${p} => ${st}`);
      return st === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED ?
        PermissionResult.granted :
        PermissionResult.denied;
    } catch (error) {
      return PermissionResult.error;
    }

  }

  async requestPermission(
    perm: OnePerm,
    ctx: common.UIAbilityContext
  ): Promise<PermissionResult> {
    const current = this.checkPermission(perm);
    if (current === PermissionResult.granted) {
      return PermissionResult.granted;
    }

    const p = toPerm(perm);
    const at = abilityAccessCtrl.createAtManager();
    console.info(`[PermissionManager] requestPermission -> ${p}`);

    return new Promise<PermissionResult>((resolve, reject) => {
      at.requestPermissionsFromUser(ctx, [p], (err, data) => {
        if (err) {
          console.error(`[PermissionManager] request error: code=${err.code}, msg=${err.message}`);
          reject(err);
          return;
        }

        const code = data?.authResults?.[0] ?? -1;
        console.info(`[PermissionManager] user response ${p} => ${code}`);

        resolve(
          code === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED ?
            PermissionResult.granted :
            PermissionResult.denied
        );
      });
    });
  }
}

export default PermissionManager;
