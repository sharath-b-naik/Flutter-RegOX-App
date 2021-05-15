class Client {
  int id;
  String fullname;
  int phoneNumber;
  String productType;
  String amount;
  String amountType;
  String profileImagePath;
  String date;

  Client(
      {this.id,
      this.fullname,
      this.phoneNumber,
      this.productType,
      this.amount,
      this.amountType,
      this.profileImagePath,
      this.date});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "id": this.id,
      "fullName": this.fullname,
      "phoneNumber": this.phoneNumber,
      "productType": this.productType,
      "amount": this.amount,
      "amountType": this.amountType,
      "profileImagePath": this.profileImagePath,
      "date": this.date
    };
    return map;
  }

  Client.fromMap(Map<String, dynamic> map) {
    this.id = map["id"];
    this.fullname = map["fullName"];
    this.phoneNumber = map["phoneNumber"];
    this.productType = map["productType"];
    this.amount = map["amount"];
    this.amountType = map["amountType"];
    this.profileImagePath = map["profileImagePath"];
    this.date = map["date"];
  }

  List<dynamic> lists() {
    List<dynamic> list = [
      this.id,
      this.fullname,
      this.phoneNumber,
      this.productType,
      this.amount,
      this.amountType,
      this.profileImagePath,
      this.date
    ];
    return list;
  }
}
