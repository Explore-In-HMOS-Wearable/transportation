import { PaymentHomePage } from './view/PaymentHomePage';
import { QrPayPage } from './view/QrPayPage';
import { NfcPayPage } from './view/NfcPayPage';

@Entry
@Component
struct AppNav {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  private _navBuilder(name: string) {
    if (name === 'QrPay') {
      QrPayPage();
    } else if (name === 'NfcPay') {
      NfcPayPage();
    } else {
      PaymentHomePage();
    }
  }

  build() {
    Navigation(this.pageStack) {
      PaymentHomePage();
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .navDestination(this._navBuilder);
  }
}
