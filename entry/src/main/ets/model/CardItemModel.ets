export class CardItemModel {
  id: string;
  title: string;
  cardNumber: string;
  balance: string;
  color: string;

  constructor(id: string, title: string, cardNumber: string, balance: string, color: string) {
    this.id = id;
    this.title = title;
    this.cardNumber = cardNumber;
    this.balance = balance;
    this.color = color;
  }
}