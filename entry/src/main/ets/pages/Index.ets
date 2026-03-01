import { NavigationConstants, NavigationManager } from 'core';
import { SplashScreen } from '../pages/splash/SplashPage';
import { HomePage } from '../pages/home/HomePage';
import { PaymentHomePage } from './qr/view/PaymentHomePage';
import { NfcPayPage } from './qr/view/NfcPayPage';
import { QrPayPage } from './qr/view/QrPayPage';
import { PaymentStatePage } from './qr/view/PaymentStatePage';
import { BalancePage } from './balance/view/BalancePage';
import { BalanceDetailPage } from './balance/view/BalanceDetailPage';
import { LoginPageBuilder } from './login/LoginView';
import { AnnouncementsView } from './announcements/AnnouncementsView';
import { MapPage } from './map/view/MapPage';
import { SearchPage } from './search/SearchPage';

@Entry
@Component
struct Index {
  @Builder
  routeMap(name: string) {
    if (name === NavigationConstants.splash) {
      Column() {
        SplashScreen();
      };
    } else if (name === NavigationConstants.login) {
      Column() {
        LoginPageBuilder();
      };
    } else if (name === NavigationConstants.home) {
      Column() {
        HomePage();
      };
    } else if (name === NavigationConstants.payment) {
      Column() {
        PaymentHomePage();
      };
    } else if (name === NavigationConstants.nfcPay) {
      Column() {
        NfcPayPage();
      };
    } else if (name === NavigationConstants.paymentResult) {
      Column() {
        PaymentStatePage();
      };
    } else if (name === NavigationConstants.qrPay) {
      Column() {
        QrPayPage();
      };
    } else if (name === NavigationConstants.balance) {
      Column() {
        BalancePage();
      };
    } else if (name === NavigationConstants.balanceDetail) {
      Column() {
        BalanceDetailPage();
      };
    } else if (name === NavigationConstants.announcements) {
      Column() {
        AnnouncementsView();
      };
    } else if (name === NavigationConstants.map) {
      Column() {
        MapPage();
      };
    } else if (name === NavigationConstants.search) {
      Column() {
        SearchPage();
      };
    }
  }

  build() {
    Navigation(NavigationManager.getInstance().pageInfos) {
      Column() {
        SplashScreen();
      };
    }
    .navDestination(this.routeMap)
    .ignoreLayoutSafeArea()
    .hideTitleBar(true)
    .width('100%')
    .height('100%');
  }
}
