import 'package:cloud_firestore/cloud_firestore.dart';

class SalesModel{
  final String id;
  final String image;
  final String sales;

  SalesModel({
    required this.id,
    required this.image,
    required this.sales});

  factory SalesModel.fromSnapshot (DocumentSnapshot snapshot){
    return SalesModel(
        id:snapshot.id,
        image: snapshot['image'],
        sales: snapshot['sales']);
  }
}