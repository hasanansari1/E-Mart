import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel{

  final String id;
  final String image;
  final String category;

  CategoryModel({
    required this.id,
    required this.image,
    required this.category,
  });

  factory CategoryModel.fromSnapshot(DocumentSnapshot snapshot){
    var data = snapshot.data() as Map<String, dynamic>;
    return CategoryModel(
      id: snapshot.id,
      category: data['category'] ?? '',
      image: data['image'] ?? '',
    );
  }
}