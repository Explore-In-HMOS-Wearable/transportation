import preferences from '@ohos.data.preferences';
import { BusinessError } from '@kit.BasicServicesKit';
import { BaseModel } from '../base/BaseModel';
import { Duration } from '../base/DurationModel';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

interface StorageDataModel {
  data: object;
  expireAt: number;
}

export class StorageManager {
  private static instance: StorageManager;
  private pref?: preferences.Preferences;
  private initialized = false;

  private constructor() {
  }

  static getInstance(): StorageManager {
    if (!StorageManager.instance) {
      StorageManager.instance = new StorageManager();
    }
    return StorageManager.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.initialized) {
      return;
    }

    try {
      this.pref = await preferences.getPreferences(
        context.getApplicationContext(),
        'airline'
      );
      this.initialized = true;
      hilog.info(0, 'StorageManager', 'Preferences initialized');
    } catch (e) {
      console.error('Preferences init failed', (e as BusinessError).message);
    }
  }

  private _ensureInit() {
    if (!this.pref) {
      throw new Error('StorageManager not initialized');
    }
  }

  async set(key: string, value: string): Promise<void> {
    this._ensureInit();
    this.pref!.putSync(key, value);
    await this.pref!.flush();
  }

  async get(key: string): Promise<string | null> {
    this._ensureInit();
    const val = this.pref!.getSync(key, '') as string;
    return val.length > 0 ? val : null;
  }

  async remove(key: string): Promise<void> {
    this._ensureInit();
    this.pref!.deleteSync(key);
    await this.pref!.flush();
  }

  async clear(): Promise<void> {
    this._ensureInit();
    this.pref!.clearSync();
    await this.pref!.flush();
  }

  async saveModel<T extends BaseModel>(key: string, model: T): Promise<void> {
    this._ensureInit();
    this.pref!.putSync(key, JSON.stringify(model.toJson()));
    await this.pref!.flush();
  }

  async saveModelWithExpiry<T extends BaseModel>(
    key: string,
    model: T,
    duration: Duration
  ): Promise<void> {
    this._ensureInit();

    const wrapper: StorageDataModel = {
      data: model.toJson(),
      expireAt: Date.now() + duration.inMilliseconds()
    };

    this.pref!.putSync(key, JSON.stringify(wrapper));
    await this.pref!.flush();
  }

  async getModelWithExpiry<TModel, TJson>(
    key: string,
    fromJson: (json: TJson) => TModel
  ): Promise<TModel | null> {
    this._ensureInit();

    const value = this.pref!.getSync(key, '') as string;
    if (!value) {
      return null;
    }

    try {
      const parsed = JSON.parse(value) as StorageDataModel;
      if (Date.now() > parsed.expireAt) {
        this.pref!.deleteSync(key);
        await this.pref!.flush();
        return null;
      }
      return fromJson(parsed.data as TJson);
    } catch {
      return null;
    }
  }

  async getModel<TModel, TJson>(
    key: string,
    fromJson: (json: TJson) => TModel
  ): Promise<TModel | null> {
    this._ensureInit();

    const value = this.pref!.getSync(key, '') as string;
    if (!value) {
      return null;
    }

    try {
      return fromJson(JSON.parse(value) as TJson);
    } catch {
      return null;
    }
  }
}
