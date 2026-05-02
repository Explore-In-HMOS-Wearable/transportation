export class MainMenuItemModel {
  icon: Resource = $r('app.media.startIcon');
  backgroundColor: ResourceColor = Color.Black;
  description: string = '';
  navigationName: string = '';

  constructor(icon: Resource, backgroundColor: ResourceColor, description: string, navigationName: string) {
    this.icon = icon;
    this.backgroundColor = backgroundColor;
    this.description = description;
    this.navigationName = navigationName;
  }
}