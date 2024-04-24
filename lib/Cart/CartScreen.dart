import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart_user/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../Models/ProductModel.dart';
import '../Payment/CheckOut.dart';
import '../Product/ProductDetails.dart';

class AddToCartScreen extends StatefulWidget {
  const AddToCartScreen({super.key});

  @override
  _AddToCartScreenState createState() => _AddToCartScreenState();
}

class _AddToCartScreenState extends State<AddToCartScreen> {
  List<ProductModel> _cartItems = [];
  double _subtotal = 0.0;
  bool _isLoading = true;

  final NumberFormat _indianCurrencyFormat =
  NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  String _formatCurrency(double amount) {
    return _indianCurrencyFormat.format(amount);
  }

  @override
  void initState() {
    super.initState();
    _fetchUserCartProducts();
  }

  Future<void> _fetchUserCartProducts() async {
    try {
      String UID = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('ShoppingCart')
          .where('UID', isEqualTo: UID)
          .get();

      List<ProductModel> products = [];
      double subtotal = 0.0;
      for (var doc in querySnapshot.docs) {
        ProductModel product = ProductModel.fromSnapshot(doc);
        try {
          // Remove commas from the price string
          String priceWithoutCommas = product.newPrice.replaceAll(',', '');
          // Parse the price as a double
          double totalPrice =
              double.parse(priceWithoutCommas) * int.parse(product.selectedqty);
          // Assign the calculated total price to the product
          product.totalprice = totalPrice.toString();
          subtotal += totalPrice;
        } catch (e) {
          print('Error calculating total price: $e');
        }
        products.add(product);
      }

      setState(() {
        _cartItems = products;
        _subtotal = subtotal;
        _isLoading = false; // Set loading state to false when data is fetched
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        _isLoading = false; // Set loading state to false even if there's an error
      });
    }
  }

  void _deleteProduct(ProductModel product) async {
    try {
      await FirebaseFirestore.instance
          .collection('ShoppingCart')
          .doc(product.id)
          .delete();

      _fetchUserCartProducts();

      // Show snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product removed from cart'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error deleting product: $e');
    }
  }


  void _updateQuantity(ProductModel product, int quantity) async {
    try {
      if (quantity > 0) {
        // Calculate the new total price based on the updated quantity
        double newTotalPrice =
            double.parse(product.newPrice.replaceAll(',', '')) * quantity;

        // Update the quantity and totalprice fields in Firestore
        await FirebaseFirestore.instance
            .collection('ShoppingCart')
            .doc(product.id)
            .update({
          'quantity': quantity.toString(),
          'totalprice': newTotalPrice.toString(),
        });

        // Refresh cart items after updating quantity
        _fetchUserCartProducts();
      } else {
        // If quantity becomes 0, delete the product from the cart
        await FirebaseFirestore.instance
            .collection('ShoppingCart')
            .doc(product.id)
            .delete();

        // Refresh cart items after deleting product
        _fetchUserCartProducts();
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
        actions: _cartItems.isNotEmpty
            ? [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Delete all products from the cart
              _showDeleteAllConfirmationDialog();
            },
          ),
        ]
            : [],
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(),
      )
          : _cartItems.isEmpty
          ? const Center(
          child: Text(
          'No items added to cart.',
          style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
        ),
      )
          : Stack(
          children: [
            ListView.builder(
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              ProductModel product = _cartItems[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetails(product: product)
                    ),
                  );
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      contentPadding:
                      const EdgeInsets.all(0), // Added this line
                      leading: Image.network(
                        product.images![0],
                        width: 100,
                        height: 100,
                      ),
                      title: Text(product.productName),
                      subtitle: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'M.R.P: ${product.newPrice}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total Price: ${_formatCurrency(double.parse(product.totalprice))}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      int newQuantity = int.parse(
                                          product.selectedqty) -
                                          1;
                                      if (newQuantity >= 0) {
                                        _updateQuantity(
                                            product, newQuantity);
                                      }
                                    },
                                  ),
                                  Text(product.selectedqty.toString()),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      int newQuantity = int.parse(
                                          product.selectedqty) +
                                          1;
                                      _updateQuantity(
                                          product, newQuantity);
                                    },
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(
                                      product);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: _cartItems.isNotEmpty
          ? Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal: ${_formatCurrency(_subtotal)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () {
                if (_subtotal > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CheckOutScreen(cartItems: _cartItems),
                    ),
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "Add items to the cart",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness ==
                    Brightness.dark
                    ? Colors.white : Colors.black,
              ),
              child: Text(
                'Checkout',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      )
          : null,
    );
  }

  void _showDeleteConfirmationDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(product);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAllConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Products'),
          content: const Text('Are you sure you want to delete all products?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteAllProducts();
                Navigator.of(context).pop();
              },
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAllProducts() async {
    try {
      String UID = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('ShoppingCart')
          .where('UID', isEqualTo: UID)
          .get();

      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('ShoppingCart')
            .doc(doc.id)
            .delete();
      }

      _fetchUserCartProducts();
    } catch (e) {
      print('Error deleting all products: $e');
    }
  }
}