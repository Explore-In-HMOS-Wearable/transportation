import { deviceInfo } from '@kit.BasicServicesKit';

export function isEmulator(): boolean {
  // Get the market name and product model
  const marketName = deviceInfo.marketName.toLowerCase();
  const productModel = deviceInfo.productModel.toLowerCase();

  // Check for common emulator keywords
  // HarmonyOS emulators often contain "emulator" in these fields
  if (marketName.includes('emulator') || productModel.includes('emulator')) {
    return true;
  }

  return false;
}