import { QrCard } from '../../../component/QrCard';
import { QrPayViewModel } from '../viewmodel/QrPayViewModel';
import { Theme } from 'core';

@Builder
export function QrPayPageBuilder(name: string, param?: string) {
  QrPayPage({ name: name });
}

@Component
export struct QrPayPage {
  name: string = '';
  @State private vm: QrPayViewModel = new QrPayViewModel();
  private pathStack: NavPathStack = new NavPathStack();

  private _regenerate(): void {
    const newVm = new QrPayViewModel();
    newVm.init();
    this.vm = newVm;
  }

  build() {
    NavDestination() {
      Column({ space: 16 }) {
        SymbolGlyph($r('sys.symbol.circle_and_plus'))
          .borderColor(Theme.Colors.primaryGreen())
          .fontSize(40)
          .onClick(() => {
            this._regenerate();
          });

        QrCard({
          value: this.vm.qrValue,
          paymentId: this.vm.paymentId
        });
      }
      .padding(16);
    }
    .backgroundColor(Theme.Colors.globalBackground())
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack;
      this._regenerate();
    })
    .hideTitleBar(true);
  }
}
