

import 'package:e_mart_user/color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/ProductModel.dart';
import 'Address.dart';

class CheckOutScreen extends StatefulWidget {
  final List<ProductModel> cartItems;

  const CheckOutScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  String _formatCurrency(double amount) {
    final NumberFormat indianCurrencyFormat =
    NumberFormat.currency(locale: 'en_IN', symbol: '');
    return indianCurrencyFormat.format(amount);
  }

  double totalPrice = 0;
  double totalDiscount = 0;
  double deliveryCharges = 0;
  double subtotal = 0;

  @override
  void initState() {
    super.initState();
    _calculatePriceDetails();
  }

  void _calculatePriceDetails() {
    totalPrice = 0;
    totalDiscount = 0;
    for (var product in widget.cartItems) {
      double productPrice =
      double.parse(product.productPrice.replaceAll(',', ''));
      double newPrice = double.parse(product.newPrice.replaceAll(',', ''));
      totalPrice += productPrice * int.parse(product.selectedqty);
      totalDiscount +=
          (productPrice - newPrice) * int.parse(product.selectedqty);
    }

    subtotal = totalPrice - totalDiscount + deliveryCharges;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Checkout',style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                ProductModel product = widget.cartItems[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListTile(
                      leading: Image.network(
                        product.images![0],
                        width: 100,
                        height: 150,
                        // fit: BoxFit.cover,
                      ),
                      title: Text(
                        product.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${product.productPrice}',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text('MRP ${product.newPrice}'),
                          Text('Qty: ${product.selectedqty}'),
                          Text(
                              'Total Price ${_formatCurrency(double.parse(product.totalprice))}'), // Format total price with commas
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Price Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Product Price:'),
                        Text(
                            '₹${_formatCurrency(totalPrice)}'), // Format product price with commas
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Discount:'),
                        Text('₹${_formatCurrency(totalDiscount)}'), // Format total discount with commas
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Charges:'),
                        Text(
                            '₹${_formatCurrency(deliveryCharges)}'), // Format delivery charges with commas
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${_formatCurrency(subtotal)}', // Format subtotal with commas
                          style: const TextStyle(fontWeight: FontWeight.bold,),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
              'Subtotal: ₹${_formatCurrency(subtotal)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Address()));
                }, style: ElevatedButton.styleFrom(
                primary: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
                child: Text(
                  'Place Order',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}