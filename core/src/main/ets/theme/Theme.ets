export namespace Theme {

  export namespace Colors {

    export function primaryGreen(): Resource { return $r('app.color.primary_green'); }
    export function primaryDarkGreen(): Resource { return $r('app.color.primary_dark_green'); }
    export function globalBackground(): Resource { return $r('app.color.global_background'); }
    export function textPrimary(): Resource { return $r('app.color.text_primary'); }
    export function textSecondary(): Resource { return $r('app.color.text_secondary'); }
    export function dividerGray(): Resource { return $r('app.color.divider_gray'); }

    export function homeBusButton(): Resource { return $r('app.color.home_bus_button'); }
    export function homeMapButton(): Resource { return $r('app.color.home_map_button'); }
    export function homeWalletButton(): Resource { return $r('app.color.home_wallet_button'); }
    export function homePayQrButton(): Resource { return $r('app.color.home_pay_qr_button'); }
    export function homeAnnouncementButton(): Resource { return $r('app.color.home_announcement_button'); }

    export function searchBarBorder(): Resource { return $r('app.color.search_bar_border'); }
    export function searchIconColor(): Resource { return $r('app.color.search_icon_color'); }
    export function tableGridBorder(): Resource { return $r('app.color.table_grid_border'); }
    export function tableActiveCellBg(): Resource { return $r('app.color.table_active_cell_bg'); }
    export function tableActiveCellText(): Resource { return $r('app.color.table_active_cell_text'); }

    export function announcementCardBg(): Resource { return $r('app.color.announcement_card_bg'); }
    export function announcementIconWarning(): Resource { return $r('app.color.announcement_icon_warning'); }
    export function announcementIconInfo(): Resource { return $r('app.color.announcement_icon_info'); }
    export function announcementIconSuccess(): Resource { return $r('app.color.announcement_icon_success'); }

    export function successEmerald(): Resource { return $r('app.color.success_emerald'); }
    export function errorCrimson(): Resource { return $r('app.color.error_crimson'); }
    export function warningAmber(): Resource { return $r('app.color.warning_amber'); }

    export function nfcRippleLight(): Resource { return $r('app.color.nfc_ripple_light'); }
    export function nfcSignalDark(): Resource { return $r('app.color.nfc_signal_dark'); }
  }

  export namespace FontSize {
    export const xs = 10;

    export const small = 12;

    export const medium = 14;

    export const large = 16;

    export const xlarge = 20;

    export const xxlarge = 24;

    export const title = 28;
  }

  export namespace Weight {
    export const regular = FontWeight.Regular;

    export const medium = FontWeight.Medium;

    export const bold = FontWeight.Bold;
  }

  export namespace FontFamily {
    export const defaultFont = 'HarmonyOS Sans';
  }

  export namespace Padding {
    export const xs = 6;

    export const small = 10;

    export const medium = 14;

    export const large = 18;

    export const xlarge = 24;

    export function horizontal(value: number): Padding {
      return { left: value, right: value };
    }

    export function vertical(value: number): Padding {
      return { top: value, bottom: value };
    }

    export function all(value: number): Padding {
      return {
        left: value,
        right: value,
        top: value,
        bottom: value
      };
    }

    export function only(p: Padding): Padding {
      return p;
    }
  }

  export namespace Margin {
    export const xs = 4;

    export const small = 8;

    export const medium = 12;

    export const large = 16;

    export const xlarge = 24;

    export function horizontal(value: number): Margin {
      return { left: value, right: value };
    }

    export function vertical(value: number): Margin {
      return { top: value, bottom: value };
    }

    export function all(value: number): Margin {
      return {
        left: value,
        right: value,
        top: value,
        bottom: value
      };
    }

    export function only(m: Margin): Margin {
      return m;
    }
  }

  export namespace Radius {
    export const small = 6;

    export const medium = 10;

    export const large = 16;

    export const xlarge = 24;

    export const pill = 999;
  }
}