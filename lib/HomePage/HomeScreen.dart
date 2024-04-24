import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart_user/color.dart';
import 'package:flutter/material.dart';
import '../Brand/BrandScreen.dart';
import '../Models/CategoryModel.dart';
import '../Models/ProductModel.dart';
import '../Product/ProductDetails.dart';
import 'SearchScreen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> _fetchImages() async {
    final QuerySnapshot querySnapshot =
    await _firestore.collection('Sales').get();
    return querySnapshot.docs.map((doc) => doc['image'] as String).toList();
  }

  Future<bool> _onBackPressed() async {
    bool shouldExit =
        await ExitConfirmationDialog.showExitDialog(context) ?? false;
    return shouldExit;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text(
            'E-Mart',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchScreen()));
              },
              icon: const Icon(Icons.search),

            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, primaryColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const CategoryList(),
                  const SizedBox(height: 20),
                  FutureBuilder<List<String>>(
                    future: _fetchImages(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final carouselImages = snapshot.data;
                      if (carouselImages == null || carouselImages.isEmpty) {
                        return const SizedBox();
                      }
                      return CarouselSlider.builder(
                        itemCount: carouselImages.length,
                        itemBuilder: (context, index, realIndex) {
                          final imageUrl = carouselImages[index];
                          return Image.network(
                            imageUrl,
                            width: double.infinity,
                            // fit: BoxFit.cover,
                          );
                        },
                        options: CarouselOptions(
                          autoPlay: true,
                          aspectRatio: 16 / 9,
                          viewportFraction: 1.0,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const ProductHome(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryList extends StatelessWidget {
  const CategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Categories').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final categoryDocs = snapshot.data!.docs;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categoryDocs.map((doc) {
              final category = CategoryModel.fromSnapshot(doc);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: CategoryCard(category: category),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}


class CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const CategoryCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BrandScreen(selectedcategory: category),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: ClipOval(
                  child: Image.network(
                    category.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Center the text below the image
              Center(
                child: Text(
                  category.category,
                  maxLines: 1, // Ensures text stays in one line
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ProductHome extends StatelessWidget {
  const ProductHome({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No data available'));
        }

        final productDocs = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 0.7),
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
            MaterialPageRoute(
                builder: (context) => ProductDetails(product: product)),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    product.images![0], // Displaying only the first image
                    // fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                product.productName,
                maxLines: 1,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  Text(
                    '₹ ${product.productPrice}',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      decorationColor:
                      Colors.red, // Set the color of the line through
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'M.R.P ₹ ${product.newPrice}',
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
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

class ExitConfirmationDialog {
  static Future<bool?> showExitDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Exit Shopper Store?',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        content: const Text(
          'Are you sure you want to exit?',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(false); // Return false to indicate user canceled exit
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(true); // Return true to indicate user confirmed exit
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
