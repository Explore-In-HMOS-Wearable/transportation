import { CoreResourceProvider } from './CoreResourceProvider';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class RawDataManager {
  private static textCache: Map<string, string> = new Map();

  static async readRawfileText(filename: string): Promise<string> {
    try {
      if (RawDataManager.textCache.has(filename)) {
        return RawDataManager.textCache.get(filename)!;
      }

      const rm = CoreResourceProvider.rm();

      const bytes = await rm.getRawFileContent(filename);
      const text = RawDataManager._utf8Decode(bytes);

      RawDataManager.textCache.set(filename, text);
      return text;

    } catch (e) {
      const msg = (e as Error)?.message ?? String(e);

      hilog.error(0, 'test', `[RawDataManager] Failed to read rawfile: ${filename}. Reason: ${msg}`);

      throw new Error(
        `[RawDataManager] readRawfileText failed for ${filename}`
      );
    }
  }

  static async readRawfileJson<T>(filename: string): Promise<T> {
    const text = await RawDataManager.readRawfileText(filename);
    return JSON.parse(text) as T;
  }

  private static _utf8Decode(bytes: Uint8Array): string {
    let out = '';
    let i = 0;
    const len = bytes.length;

    if (len >= 3 && bytes[0] === 0xEF && bytes[1] === 0xBB && bytes[2] === 0xBF) {
      i = 3;
    }

    while (i < len) {
      const b1 = bytes[i++];

      if (b1 < 0x80) {
        out += String.fromCharCode(b1);
        continue;
      }

      if ((b1 & 0xE0) === 0xC0) {
        if (i >= len) {
          out += '\uFFFD';
          break;
        }
        const b2 = bytes[i++];
        if ((b2 & 0xC0) !== 0x80) {
          out += '\uFFFD';
          continue;
        }
        out += String.fromCharCode(((b1 & 0x1F) << 6) | (b2 & 0x3F));
        continue;
      }

      if ((b1 & 0xF0) === 0xE0) {
        if (i + 1 >= len) {
          out += '\uFFFD';
          break;
        }
        const b2 = bytes[i++];
        const b3 = bytes[i++];
        if ((b2 & 0xC0) !== 0x80 || (b3 & 0xC0) !== 0x80) {
          out += '\uFFFD';
          continue;
        }
        out += String.fromCharCode(((b1 & 0x0F) << 12) | ((b2 & 0x3F) << 6) | (b3 & 0x3F));
        continue;
      }

      if ((b1 & 0xF8) === 0xF0) {
        if (i + 2 >= len) {
          out += '\uFFFD';
          break;
        }
        const b2 = bytes[i++];
        const b3 = bytes[i++];
        const b4 = bytes[i++];
        if ((b2 & 0xC0) !== 0x80 || (b3 & 0xC0) !== 0x80 || (b4 & 0xC0) !== 0x80) {
          out += '\uFFFD';
          continue;
        }
        const cp = ((b1 & 0x07) << 18) | ((b2 & 0x3F) << 12) | ((b3 & 0x3F) << 6) | (b4 & 0x3F);
        const offset = cp - 0x10000;
        out += String.fromCharCode(0xD800 + (offset >> 10), 0xDC00 + (offset & 0x3FF));
        continue;
      }

      out += '\uFFFD';
    }
    return out;
  }
}

