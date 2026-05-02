export class Duration {
  private readonly milliseconds: number;

  private constructor(milliseconds: number) {
    this.milliseconds = milliseconds;
  }

  static milliseconds(ms: number): Duration {
    return new Duration(ms);
  }

  static seconds(sec: number): Duration {
    return new Duration(sec * 1000);
  }

  static minutes(min: number): Duration {
    return new Duration(min * 60 * 1000);
  }

  static hours(hours: number): Duration {
    return new Duration(hours * 60 * 60 * 1000);
  }

  static days(days: number): Duration {
    return new Duration(days * 24 * 60 * 60 * 1000);
  }

  inMilliseconds(): number {
    return this.milliseconds;
  }
}
