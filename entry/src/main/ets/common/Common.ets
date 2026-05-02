import { MainMenuItemModel } from '../model/MainMenuItemModel';
import display from '@ohos.display';
import { Theme } from 'core';

export const mainMenuItems: MainMenuItemModel[] = [
  new MainMenuItemModel(
    $r('sys.symbol.credit_card_repayment'),
    Theme.Colors.homePayQrButton(),
    'Purchase',
    'payment'
  ),
  new MainMenuItemModel(
    $r('sys.symbol.bus_fill'),
    Theme.Colors.homeBusButton(),
    'Bus',
    'bus'
  ),
  new MainMenuItemModel(
    $r('sys.symbol.map_badge_local'),
    Theme.Colors.homeMapButton(),
    'Map',
    'map'
  ),
  new MainMenuItemModel(
    $r('sys.symbol.wallet_fill'),
    Theme.Colors.homeWalletButton(),
    'Balance',
    'balance'
  ),
  new MainMenuItemModel(
    $r('sys.symbol.bell'),
    Theme.Colors.homeAnnouncementButton(),
    'Announcements',
    'announcements'
  )
];
export const deviceSize: number = display.getDefaultDisplaySync().width;
