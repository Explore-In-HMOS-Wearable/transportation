import { Theme } from 'core';
import { LoginHeader } from '../../component/login/LoginHeader';
import { LoginViewModel } from './LoginViewModel';
import { common } from '@kit.AbilityKit';

@Builder
export function LoginPageBuilder() {
  LoginView();
}

@Component
export struct LoginView {
  @State viewModel: LoginViewModel = new LoginViewModel();

  build() {
    NavDestination() {
      Stack() {
        // 1. Global Background
        Rect()
          .width('100%')
          .height('100%')
          .fill(Theme.Colors.globalBackground());

        // 2. Main Content
        Column() {
          if (this.viewModel.isLoggedIn) {
            LoginSuccessView({ viewModel: this.viewModel });
          } else {
            // Login Layout
            Column() {
              // Spacer to push content down on round screens
              Blank().height('15%');

              LoginHeader();

              LoginActionButton({ viewModel: this.viewModel, });
            }
            .width('100%')
            .height('100%')
            .alignItems(HorizontalAlign.Center);
          }
        }
        // Apply global horizontal padding for round screen safety
        .padding({
          left: Theme.Padding.small,
          right: Theme.Padding.small
        });
      };
    }
    .hideTitleBar(true);
  }
}

@Component
export struct LoginActionButton {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @ObjectLink viewModel: LoginViewModel;

  build() {
    Column() {
      if (this.viewModel.isLoading) {
        LoadingProgress()
          .color(Theme.Colors.primaryGreen())
          .width(32)
          .height(32);
      } else {
        Button({ type: ButtonType.Capsule, stateEffect: true }) {
          Text($r('app.string.login_button_text'))
            .fontSize(Theme.FontSize.medium)
            .fontColor(Theme.Colors.textPrimary()) // Assuming text is readable on primaryGreen
            .fontWeight(Theme.Weight.medium);
        }
        .width('100%')
        .height(48) // A bit larger for wearable touch targets
        .backgroundColor(Theme.Colors.primaryGreen())
        .onClick(() => {
          this.viewModel.login();
        });
      }

      if (this.viewModel.errorMessage) {
        Text($r('app.string.login_failed_message', this.viewModel.errorMessage))
          .fontSize(Theme.FontSize.xs)
          .fontColor(Theme.Colors.errorCrimson())
          .margin({ top: Theme.Margin.small })
          .textAlign(TextAlign.Center);
      }
    }
    .margin({ top: Theme.Margin.large })
    .padding({
      left: Theme.Padding.medium,
      right: Theme.Padding.medium
    })
    .width('100%');
  }
}

@Component
export struct LoginSuccessView {
  @ObjectLink viewModel: LoginViewModel;

  build() {
    Column({ space: Theme.Margin.medium }) {
      // FIX: Use Stack instead of overlay for better stability
      Stack({ alignContent: Alignment.Center }) {
        Circle({ width: 56, height: 56 })
          .fill(Theme.Colors.successEmerald());

        Text('✓')
          .fontColor(Theme.Colors.textPrimary())
          .fontSize(Theme.FontSize.title)
          .fontWeight(Theme.Weight.bold);
      };

      // Greeting Text
      Text($r('app.string.login_success_greeting', this.viewModel.currentUser?.displayName ?? 'User'))
        .fontSize(Theme.FontSize.large)
        .fontColor(Theme.Colors.textPrimary())
        .fontWeight(Theme.Weight.medium)
        .textAlign(TextAlign.Center);

      // Logout Button
      Button($r('app.string.logout_button_text'))
        .type(ButtonType.Capsule)
        .fontSize(Theme.FontSize.small)
        .fontColor(Theme.Colors.textSecondary())
        .height(32)
        .backgroundColor(Color.Transparent)
        .borderWidth(1)
        .borderColor(Theme.Colors.dividerGray())
        .margin({ top: Theme.Margin.small })
        .onClick(() => {
          this.viewModel.logout();
        });
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .padding(Theme.Padding.medium);
  }
}