import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String id;
  List<String>? images;
  final String category;
  final String brand;
  final String productName;
  final String productPrice;
  final String color;
  final String productDescription;
  final String product1;
  final String product2;
  final String product3;
  final String product4;
  final String title1;
  final String title2;
  final String title3;
  final String title4;
  final String discount;
  final String newPrice;
  String selectedqty;
  String userId;
  // final String imageUrls;



  CartModel({required this.id,
    required this.images,
    required this.category,
    required this.brand,
    required this.productName,
    required this.productPrice,
    required this.color,
    required this.productDescription,
    required this.product1,
    required this.product2,
    required this.product3,
    required this.product4,
    required this.title1,
    required this.title2,
    required this.title3,
    required this.title4,
    required this.discount,
    required this.newPrice,
    required this.selectedqty,
    required this.userId,
    // required this.imageUrls


  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'images': images,
      'category': category,
      'brand': brand,
      'productName': productName,
      'productPrice': productPrice,
      'color': color,
      'productDescription': productDescription,
      'product1': product1,
      'product2': product2,
      'product3': product3,
      'product4': product4,
      'title1': title1,
      'title2': title2,
      'title3': title3,
      'title4': title4,
      'discount': discount,
      'newPrice': newPrice,
      'selectedqty': selectedqty,
      'userId': userId,
    };
  }

  factory CartModel.fromSnapshot(DocumentSnapshot snapshot){
    Map<String,dynamic> data = snapshot.data() as Map<String,dynamic>;
    return CartModel(
      id: snapshot.id,
      category: data['category']?? '',
      brand: data['brand']?? '',
      images: List<String>.from(data['images'] ?? []),
      productName: data['productName'] ?? '',
      productPrice: data['productPrice'] ?? '',
      color: data['productColor'] ?? '',
      productDescription: data['productDescription'] ?? '',
      product1: data['productTitleDetail1']?? '',
      product2: data['productTitleDetail2']?? '',
      product3: data['productTitleDetail3']?? '',
      product4: data['productTitleDetail4']?? '',
      title1: data['productTitle1']?? '',
      title2: data['productTitle2']?? '',
      title3: data['productTitle3']?? '',
      title4: data['productTitle4']?? '',
      discount: data['discount']?? '',
      newPrice: data['productNewPrice']?? '',
      selectedqty: data['quantity']?? '',
      userId: data['UID']?? '',
      // imageUrls: data['images']?? '',


    );
  }
}