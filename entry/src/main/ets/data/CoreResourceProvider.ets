import { common } from '@kit.AbilityKit';

export class CoreResourceProvider {
  private static ctx: common.Context | null = null;

  static init(ctx: common.Context) {
    CoreResourceProvider.ctx = ctx;
  }

  static rm() {
    if (!CoreResourceProvider.ctx) {
      throw new Error('[CoreResourceProvider] not initialized. Call init() in EntryAbility.');
    }
    return CoreResourceProvider.ctx.resourceManager;
  }
}
