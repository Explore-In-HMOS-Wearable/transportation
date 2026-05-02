import { NavigationConstants, NavigationManager } from 'core';

@Component
export struct SplashScreen {
  delay(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  async aboutToAppear(): Promise<void> {
    // LoginCheck here
    await this.delay(2000);
    NavigationManager.getInstance().pageInfos.pushPath({ name: NavigationConstants.login });
  }

  build() {
    NavDestination() {
      Column() {
        LoadingProgress();
      };
    };
  }
}