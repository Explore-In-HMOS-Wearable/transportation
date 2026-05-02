@ObservedV2
export class NavigationManager {
  static _instance: NavigationManager;
  @Trace pageInfos: NavPathStack = new NavPathStack();

  static getInstance() {
    if (!NavigationManager._instance) {
      NavigationManager._instance = new NavigationManager();
    }
    return NavigationManager._instance;
  }
}
