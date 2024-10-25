import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/ProductModel.dart';
import '../Product/ProductDetails.dart';

class BrandProduct extends StatelessWidget {
  final String selectedCategory;

  const BrandProduct({Key? key, required this.selectedCategory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Products')
          .where('category', isEqualTo: selectedCategory) // Filter by selected category
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products available',));
        }

        final productDocs = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.7,
          ),
          itemCount: productDocs.length,
          itemBuilder: (context, index) {
            final product = ProductModel.fromSnapshot(productDocs[index]);
            return ProductCard(product: product);
          },
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ProductDetails(product: product)),
          );
        },
        child: Card(
          color: Colors.white,
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 150,
                // width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    product.images![0], // Displaying only the first image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                product.productName,
                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  Text(
                    '₹ ${product.productPrice}',
                    style: const TextStyle(
                      color: Colors.red,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'M.R.P ₹ ${product.newPrice}',
                    style: const TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
