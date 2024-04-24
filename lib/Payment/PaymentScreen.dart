import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart_user/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../BottomNavigation/BottomNavigation.dart';
import '../Orders/Orders.dart';


class PaymentScreen extends StatefulWidget {
  final String selectedAddress; // Add this field

  const PaymentScreen({Key? key, required this.selectedAddress}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _paymentMethod = 'Cash on Delivery';
  double _subtotal = 0.0;
  late Razorpay _razorpay;
  bool _razorpayOrderPlaced = false; // Flag to check if order placed via Razorpay

  String _formatCurrency(double amount) {
    final NumberFormat indianCurrencyFormat =
    NumberFormat.currency(locale: 'en_IN', symbol: '');

    // Format the amount with commas
    String formattedAmount = indianCurrencyFormat.format(amount);

    // Return the formatted amount
    return formattedAmount;
  }


  @override
  void initState() {
    super.initState();
    _calculateSubtotal();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _calculateSubtotal() async {
    String currentUserUID = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('ShoppingCart')
        .where('UID', isEqualTo: currentUserUID)
        .get();

    double subtotal = 0.0;
    cartSnapshot.docs.forEach((doc) {
      print('Total Price String: ${doc['totalprice']}'); // Add this line for logging
      try {
        double totalprice = double.parse(doc['totalprice']);
        subtotal += totalprice;
      } catch (e) {
        print('Error parsing total price: $e');
      }
    });

    setState(() {
      _subtotal = subtotal;
    });
  }


  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment Successful: ${response.paymentId}");
    if (_paymentMethod == 'Online Payment') {
      _placeOrder('Online Payment');
      // Navigate to confirmation screen after placing order
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ConfirmationScreen()),
      );
    }
    _razorpayOrderPlaced = true; // Set flag to true when order placed via Razorpay
  }


  void _handlePaymentError(PaymentFailureResponse response) {
    print("Error: ${response.message} - ${response.code}");
  }

  void _openRazorpay() {
    final options = {
      'key': 'rzp_test_nLQYAWuOKvzENb',
      'amount': (_subtotal * 100).toInt(),
      'name': 'Shopper Store',
      'description': 'Product Purchase',
      'prefill': {
        'contact': '9664802800',
        'email': 'CUSTOMER_EMAIL',
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error in opening Razorpay: $e');
    }
  }

  Future<void> _placeOrder(String paymentMethod) async {
    try {
      String currentUserUID = FirebaseAuth.instance.currentUser!.uid;

      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('ShoppingCart')
          .where('UID', isEqualTo: currentUserUID)
          .get();

      List<Map<String, dynamic>> items = [];
      List<String> imageUrls = []; // List to store image URLs

      cartSnapshot.docs.forEach((doc) {
        Map<String, dynamic> item = {
          'Price': doc['productNewPrice'],
          'Product': doc['productName'],
          'SelectedQuantity': doc['quantity'],
        };
        items.add(item);

        var images = doc['images'];
        if (images is List) {
          imageUrls.addAll(images.map((imageUrl) => imageUrl.toString()));
        } else if (images is String) {
          imageUrls.add(images);
        }
      });

      Map<String, dynamic> order = {
        'Address': widget.selectedAddress,
        'Amount': _subtotal.toStringAsFixed(2),
        'PaymentMethod': paymentMethod,
        'Items': items,
        'ImageUrls': imageUrls,
        'OrderId': '',
        'UserEmail': FirebaseAuth.instance.currentUser!.email ?? '',
        'UID': currentUserUID,
        'Timestamp': Timestamp.now(),
        'Status': 'Pending',
      };

      DocumentReference orderRef = await FirebaseFirestore.instance
          .collection('Orders')
          .add(order);
      String orderId = orderRef.id;

      order['OrderId'] = orderId;
      await orderRef.update({'OrderId': orderId});

      cartSnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your order has been placed.'),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ConfirmationScreen()),
      );

    } catch (error) {
      print('Error placing order: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Payment',style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Please Select a Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Cash on Delivery'),
              leading: Radio(
                value: 'Cash on Delivery',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value.toString();
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Online Payment'),
              leading: Radio(
                value: 'Online Payment',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value.toString();
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Subtotal: ${_formatCurrency(_subtotal)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_paymentMethod == 'Online Payment') {
                    _openRazorpay();
                  } else {
                    await _placeOrder('Cash on Delivery');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Place Order',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class ConfirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Your order has been successfully placed!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OrderListScreen()));
              },
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white : Colors.black,
              ),
              child: Text(
                'View Orders',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BottomNavigationHome()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white : Colors.black,
              ),
              child: Text(
                'Continue Shopping',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}