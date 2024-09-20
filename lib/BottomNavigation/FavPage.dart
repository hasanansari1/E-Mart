import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart_user/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/FavModel.dart';

class FavPage extends StatefulWidget {
  const FavPage({Key? key}) : super(key: key);

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  late List<FavModel> favoriteProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    fetchFavoriteProducts();
  }

  Future<void> fetchFavoriteProducts() async {
    try {
      final UID = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('Favorites')
          .where('UID', isEqualTo: UID)
          .get();

      final List<FavModel> products = snapshot.docs.map((doc) {
        return FavModel(
          id: doc.id,
          productName: doc['productName'],
          newPrice: doc['productNewPrice'],
          selectedqty: doc['quantity'],

          images: List<String>.from(doc['images'] ?? []),
          // category: doc['category'],
          brand: doc['brand'],
          productPrice: doc['productPrice'],
          color: doc['productColor'],
          productDescription: doc['productDescription'],
          product1: doc['productTitleDetail1'],
          product2: doc['productTitleDetail2'],
          product3: doc['productTitleDetail3'],
          product4: doc['productTitleDetail4'],
          title1: doc['productTitle1'],
          title2: doc['productTitle2'],
          title3: doc['productTitle3'],
          title4: doc['productTitle4'],
          discount: doc['discount'],
          totalprice: doc['totalprice'],
          itemdetails: doc['itemdetails'],
        );
      }).toList();

      setState(() {
        favoriteProducts = products;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching favorite products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Favorites',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : favoriteProducts.isEmpty
              ? const Center(
                  child: Text(
                    'No favorite products found',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: favoriteProducts.length,
                  itemBuilder: (context, index) {
                    final product = favoriteProducts[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetails(product: product)));
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: SizedBox(
                              width: 150,
                              height: 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  product.images![0],
                                ),
                              ),
                            ),
                            title: Text(product.productName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Price: ${product.newPrice}'),
                                Text('Quantity: ${product.selectedqty}')
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.favorite),
                                  color: Colors.red,
                                  onPressed: () {
                                    _removeFromFavorites(product);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.shopping_cart),
                                  onPressed: () {
                                    _addToCartAndRemoveFromFavorites(product);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _addToCartAndRemoveFromFavorites(FavModel product) async {
    try {
      await FirebaseFirestore.instance.collection('ShoppingCart').add({
        'UID': FirebaseAuth.instance.currentUser!.uid,
        'images': product.images,
        'productName': product.productName,
        'productPrice': product.productPrice,
        'productNewPrice': product.newPrice,
        'discount': product.discount,
        'quantity': product.selectedqty,
        'totalprice': product.totalprice,
        'productTitle1': product.title1,
        'productTitle2': product.title2,
        'productTitle3': product.title3,
        'productTitle4': product.title4,
        'productTitleDetail1': product.product1,
        'productTitleDetail2': product.product2,
        'productTitleDetail3': product.product3,
        'productTitleDetail4': product.product4,
        'productDescription': product.productDescription,
        'productColor': product.color,
        'brand': product.brand,
      });

      await FirebaseFirestore.instance
          .collection('Favorites')
          .doc(product.id)
          .delete();

      fetchFavoriteProducts();

      // Displaying the Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added to cart.'),
        ),
      );
    } catch (e) {
      print('Error adding to cart and removing from favorites: $e');
    }
  }

  Future<void> _addToFavorites(FavModel product) async {
    try {
      final currentUserID = FirebaseAuth.instance.currentUser!.uid;

      // Check if the product is already in favorites
      final isFavorite = favoriteProducts.contains(product);

      if (isFavorite) {
        // If it's already a favorite, remove it
        await FirebaseFirestore.instance
            .collection('Favorites')
            .doc(product.id)
            .delete();
        // Remove the product from the list of favorite products
        favoriteProducts.remove(product);
      } else {
        // If it's not a favorite, add it
        await FirebaseFirestore.instance.collection('Favorites').add({
          'UID': currentUserID,
          'images': product.images,
          'productName': product.productName,
          'productNewPrice': product.newPrice,
          'quantity': product.selectedqty,
        });
        // Add the product to the list of favorite products
        favoriteProducts.add(product);
      }

      // Check if the product is in the cart
      final cartSnapshot = await FirebaseFirestore.instance
          .collection('ShoppingCart')
          .where('UID', isEqualTo: currentUserID)
          .where('productName', isEqualTo: product.productName)
          .get();

      if (cartSnapshot.docs.isNotEmpty) {
        // If the product is in the cart, remove it
        await FirebaseFirestore.instance
            .collection('ShoppingCart')
            .doc(cartSnapshot.docs.first.id)
            .delete();
      }

      setState(() {});
    } catch (e) {
      print('Error adding/removing product to/from favorites: $e');
    }
  }

  Future<void> _removeFromFavorites(FavModel product) async {
    try {
      await FirebaseFirestore.instance
          .collection('Favorites')
          .doc(product.id)
          .delete();
      fetchFavoriteProducts();

      // Displaying the Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product removed from Favorites.'),
        ),
      );
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }
}
