// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class OrderItem {
//   OrderItem({
//     required this.Name,
//     required this.Address,
//     required this.Amount,
//     required this.PaymentMethod,
//     required this.Items,
//     required this.UserMobileNumber,
//     required this.OrderId,
//     required this.UserEmail,
//     required this.id,
//     required this.uid,
//   });
//   late final String Name;
//   late final String Address;
//   late final String Amount;
//   late final String PaymentMethod;
//   late final List<ItemsData> Items;
//   late final String UserMobileNumber;
//   late final String OrderId;
//   late final String UserEmail;
//   late final String id;
//   late final String uid;
//
//
//   OrderItem.fromJson(DocumentSnapshot json) {
//     Name = json['Name'];
//     Address = json['Address'];
//     Amount = json['Amount'];
//     PaymentMethod = json['PaymentMethod'];
//     Items = List.from(json['Items']).map((e) => ItemsData.fromJson(e)).toList();
//     UserMobileNumber = json['UserPhoneNumber'];
//     OrderId = json['OrderId'];
//     UserEmail = json['UserEmail'];
//     id = json.id;
//     uid = FirebaseAuth.instance.currentUser!.uid;
//   }
//
//   OrderItem copyWith({
//     String? Name,
//     String? Address,
//     String? Amount,
//     String? PaymentMethod,
//     List<ItemsData>? Items,
//     String? UserPhoneNumber,
//     String? OrderId,
//     String? UserEmail,
//     String? id,
//     String? uid,
//   }) {
//     return OrderItem(
//       Name: Name ?? this.Name,
//       Address: Address ?? this.Address,
//       Amount: Amount ?? this.Amount,
//       PaymentMethod: PaymentMethod ?? this.PaymentMethod,
//       Items: Items ?? this.Items,
//       UserMobileNumber: UserPhoneNumber ?? this.UserMobileNumber,
//       OrderId: OrderId ?? this.OrderId,
//       UserEmail: UserEmail ?? this.UserEmail,
//       id: id ?? this.id,
//       uid: uid ?? this.uid,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['UserName'] = Name;
//     _data['Address'] = Address;
//     _data['Amount'] = Amount;
//     _data['PaymentMethod'] = PaymentMethod;
//     _data['Items'] = Items.map((e) => e.toJson()).toList();
//     _data['UserPhoneNumber'] = UserMobileNumber;
//     _data['OrderId'] = OrderId;
//     _data['UserEmail'] = UserEmail;
//     return _data;
//   }
// }
//
// class ItemsData {
//   ItemsData({
//     required this.Price,
//     required this.Product,
//     required this.ImageUrl,
//     required this.SelecetedQuantity,
//   });
//   late final String Price;
//   late final String Product;
//   late final String ImageUrl;
//   late final String SelecetedQuantity;
//
//   ItemsData.fromJson(Map<String, dynamic> json) {
//     Price = json['Price'];
//     Product = json['Product'];
//     ImageUrl = json['ImageUrl'];
//     SelecetedQuantity = json['SelecetedQuantity'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['Price'] = Price;
//     _data['Product'] = Product;
//     _data['ImageUrl'] = ImageUrl;
//     _data['SelecetedQuantity'] = SelecetedQuantity;
//     return _data;
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

// import '../TrackOrder.dart';

class OrderModel {
  final String? email;
  final String? adress;
  final String? paymentMethod;
  final String? phoneNumber;
  final List<String>? images;
  final String? orderId;
  final uid;
  final List? itemWanted;
  final String? status;
  final DateTime? time;
  OrderModel(
      {this.email,
        this.phoneNumber,
        this.adress,
        this.images,
        this.orderId,
        this.uid,
        this.itemWanted,
        this.status,
        this.time,
        this.paymentMethod});

  factory OrderModel.fromJson(DocumentSnapshot json) => OrderModel(
      email: json['UserEmail'],
      // phoneNumber: json['Mobile'],
      itemWanted: json['Product'],
      images: List<String>.from(json["ImageUrl"]),
      orderId: json["OrderId"],
      uid: json['UID'],
      paymentMethod: json['PaymentMethod'],
      time: (json["Timestamp"] as Timestamp).toDate(),
      status: json["Status"],
      adress: json['Address']);

  Map<String, dynamic> toJson() => {
    "UserEmail": email,
    "Mobile": phoneNumber,
    "Product": itemWanted,
    "ImageUrl": images,
    "OrderId": orderId,
    "Status": status,
    "Timestamp": DateTime.now(),
    "UID": uid,
    "PaymentMethod": paymentMethod,
    "Address": adress
  };

  static List<String> get statusList {
    return [
      "Order Placed",
      "Shipped",
      "Out for Delivery",
      "Delivered",
    ];
  }
}
