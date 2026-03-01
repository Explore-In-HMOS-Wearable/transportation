export class CardModel {
  title: string;
  image: ResourceStr;

  constructor(title: string, image: ResourceStr) {
    this.title = title;
    this.image = image;
  }
}