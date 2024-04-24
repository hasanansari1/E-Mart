import 'dart:async';

import 'package:e_mart_user/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late Stream<QuerySnapshot> _ordersStream;
  late String _currentUserUID;

  @override
  void initState() {
    super.initState();
    _getCurrentUserUID();
    _ordersStream = FirebaseFirestore.instance
        .collection('Orders')
        .where('UID', isEqualTo: _currentUserUID)
        .snapshots();
  }
  void _getCurrentUserUID() {
    _currentUserUID = FirebaseAuth.instance.currentUser!.uid;
  }



  Future<void> _cancelOrder(BuildContext context, String orderId, String paymentMethod) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Cancel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to cancel this order?',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                try {
                  if (paymentMethod == 'Online Payment' || paymentMethod == 'Cash on Delivery') {
                    await FirebaseFirestore.instance.collection('Orders').doc(orderId).update({
                      'Status': 'Cancelled'
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Order $orderId cancelled successfully!',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Show refund message if payment method is 'Online Payment'
                    if (paymentMethod == 'Online Payment') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Refund will be processed in 2-3 days.',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          duration: Duration(seconds: 5),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    // Navigate to the home screen after cancelling the order
                    Navigator.of(context).popUntil(ModalRoute.withName('/')); // Navigate to the home screen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Invalid payment method.',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (error) {
                  print('Error cancelling order: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Failed to cancel order. Please try again.',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title: const Text('All Orders',style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data == null ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No orders available."),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var orderData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              var orderId = snapshot.data!.docs[index].id;
              var products = orderData['Items'] as List<dynamic>; // Assuming 'Items' field contains the list of products
              var amount = orderData['Amount']; // Fetching total amount directly
              var deliveryStatus = orderData['Status'];
              var paymentMethod = orderData['PaymentMethod'];

              return GestureDetector(
                onTap: (){
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => TrackingScreen())); // Uncomment if needed
                },
                child: Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order ID: $orderId",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: products.map<Widget>((product) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                title: Text(
                                  product['Product'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "Quantity: ${product['SelectedQuantity']}",
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                trailing: Text(
                                  "\₹ ${product['Price']}",
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Subtotal:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "₹ $amount",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Payment Method: $paymentMethod",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Delivery Status: $deliveryStatus",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: deliveryStatus == 'Cancelled' ? Colors.red : Colors.orange,
                          ),
                        ),
                        if (deliveryStatus == 'Cancelled')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              paymentMethod == 'Cash on Delivery'
                                  ? "Order cancelled successfully."
                                  : "Refund will be processed in 2-3 days.",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Conditionally build cancel button based on delivery status
                        if (deliveryStatus != 'Cancelled')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  _cancelOrder(context, orderId, paymentMethod);
                                },
                                icon: const Icon(Icons.cancel, color: Colors.white),
                                label: const Text('Cancel Order', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}