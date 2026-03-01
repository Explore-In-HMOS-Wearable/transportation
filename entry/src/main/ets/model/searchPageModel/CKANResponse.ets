import { CKANResult } from './CKANResult';

export interface CKANResponse<T> {
  success: boolean;
  result: CKANResult<T>;
}