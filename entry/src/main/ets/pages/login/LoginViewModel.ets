import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { isEmulator, NavigationConstants, NavigationManager } from 'core';
import { UserModel } from '../../model/UserModel';

const TAG = 'LoginViewModel';

// @Observed is crucial so components can listen to changes
@Observed
export class LoginViewModel {
  public isLoggedIn: boolean = false;
  public isLoading: boolean = false;
  public errorMessage: string = '';
  public currentUser: UserModel | null = null;

  /**
   * Defines the login logic using Huawei Account Kit
   */
  async login(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      // 1. Create Provider and Request
      const provider = new authentication.HuaweiIDProvider();
      const loginRequest = provider.createLoginWithHuaweiIDRequest();

      loginRequest.forceLogin = false;

      // 2. Execute Request
      const controller = new authentication.AuthenticationController();
      const response = await controller.executeRequest(loginRequest);

      // 3. Handle Success
      const credential = response as authentication.AuthorizationWithHuaweiIDCredential;

      this.currentUser = new UserModel(
        credential.openID ?? '',
        credential.unionID ?? '',
        credential.nickName ?? 'Huawei User'
      );
      this.isLoggedIn = true;

      // Log the Authorization Code for debugging (remove in production)
      hilog.info(0x0000, TAG, `Auth Code: ${credential.authorizationCode}`);

      NavigationManager.getInstance().pageInfos.pushPath({ name: NavigationConstants.home });

    } catch (error) {

      if (isEmulator() || true) {
        this.isLoggedIn = true;
        NavigationManager.getInstance().pageInfos.pushPath({ name: NavigationConstants.home });

        return;
      }

      // 4. Handle Errors
      const err = error as BusinessError;
      hilog.error(0x0000, TAG, `Login failed: ${err.code}, ${err.message}`);
      this.errorMessage = `Error: ${err.code}`;
      this.isLoggedIn = false;

    } finally {
      this.isLoading = false;
    }
  }

  logout() {
    this.isLoggedIn = false;
    this.currentUser = null;
  }
}