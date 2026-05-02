export class UserModel {
  openID: string = '';
  unionID: string = '';
  displayName: string = '';

  constructor(openID: string, unionID: string, displayName: string) {
    this.openID = openID;
    this.unionID = unionID;
    this.displayName = displayName;
  }
}