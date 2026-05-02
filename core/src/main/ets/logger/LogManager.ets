import { hilog } from '@kit.PerformanceAnalysisKit';

type LogLevel = 'debug' | 'info' | 'warn' | 'error';

export class LogManager {
  private static readonly MAX_LOG_LENGTH = 4000;
  private static readonly DOMAIN_ID = 0x1000;
  private static readonly LEVELS: LogLevel[] = ['debug', 'info', 'warn', 'error'];
  private static LOG_LEVEL: LogLevel = 'debug';

  static setLogLevel(level: LogLevel): void {
    if (LogManager.LEVELS.includes(level)) {
      LogManager.LOG_LEVEL = level;
    }
  }

  private static _isLevelEnabled(level: LogLevel): boolean {
    const currentIndex = LogManager.LEVELS.indexOf(LogManager.LOG_LEVEL);
    const levelIndex = LogManager.LEVELS.indexOf(level);
    return levelIndex >= currentIndex;
  }

  private static _getTimestamp(): string {
    return new Date().toISOString();
  }

  private static _chunkAndLog(
    levelFn: (domain: number, tag: string, message: string) => void,
    levelLabel: string,
    tag: string,
    message: string
  ): void {
    const timestamp = LogManager._getTimestamp();
    const prefix = `[${levelLabel}] [${timestamp}] [${tag}] `;
    const fullMessage = prefix + message;

    const maxLength: number = LogManager.MAX_LOG_LENGTH;
    const domainId: number = LogManager.DOMAIN_ID;

    for (let i = 0; i < fullMessage.length; i += maxLength) {
      const part: string = fullMessage.substring(i, i + maxLength);
      levelFn(domainId, tag, part);
    }
  }

  static debug(tag: string, message: string): void {
    if (!LogManager._isLevelEnabled('debug')) {
      return;
    }
    LogManager._chunkAndLog(hilog.debug, 'DEBUG', tag, message);
  }

  static info(tag: string, message: string): void {
    if (!LogManager._isLevelEnabled('info')) {
      return;
    }
    LogManager._chunkAndLog(hilog.info, 'INFO', tag, message);
  }

  static warn(tag: string, message: string): void {
    if (!LogManager._isLevelEnabled('warn')) {
      return;
    }
    LogManager._chunkAndLog(hilog.warn, 'WARN', tag, message);
  }

  static error(tag: string, message: string): void {
    if (!LogManager._isLevelEnabled('error')) {
      return;
    }
    LogManager._chunkAndLog(hilog.error, 'ERROR', tag, message);
  }

  static log(level: LogLevel, tag: string, message: string): void {
    switch (level) {
      case 'debug':
        return LogManager.debug(tag, message);
      case 'info':
        return LogManager.info(tag, message);
      case 'warn':
        return LogManager.warn(tag, message);
      case 'error':
        return LogManager.error(tag, message);
      default:
        return LogManager.debug(tag, message);

    }
  }
}