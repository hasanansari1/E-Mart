import 'package:cloud_firestore/cloud_firestore.dart';

import 'ProductModel.dart';

class BrandModel{

  final String id;
  final String image;
  final String brand;
  final String category;
  // final String product;

  BrandModel({
    required this.id,
    required this.image,
    required this.brand,
    required this.category,
    // required this.product
  });


  factory BrandModel.fromSnapshot (DocumentSnapshot snapshot){
    return BrandModel(
        id: snapshot.id,
        image: snapshot['image'],
        brand: snapshot['brand'],
        category: snapshot['category'],
        // product: snapshot['product'],
    );
  }
}
