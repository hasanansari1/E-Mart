import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart_user/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SavedAddressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title: const Text(
          "Saved Address",
          style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        actions: [
          DeleteAllAddressesButton(), // Add delete all button
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .collection('Address')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final addresses = snapshot.data!.docs;
            return ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final doc = addresses[index];
                final addressData = doc.data() as Map<String, dynamic>;

                return AddressCard(
                  name: addressData['name'],
                  address: addressData['address'],
                  docId: doc.id,
                );
              },
            );
          } else {
            return const Text('No addresses found.');
          }
        },
      ),
    );
  }
}


class AddressCard extends StatelessWidget {
  final String name;
  final String address;
  final String docId;

  AddressCard({required this.name, required this.address, required this.docId});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(address),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAddressScreen(docId: docId),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Delete Address"),
                      content: const Text("Are you sure you want to delete this address?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the alert dialog
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            // Delete the address from Firebase
                            FirebaseFirestore.instance
                                .collection('User')
                                .doc(FirebaseAuth.instance.currentUser!.email)
                                .collection('Address')
                                .doc(docId)
                                .delete();
                            Navigator.of(context).pop(); // Close the alert dialog
                          },
                          child: const Text("Confirm"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteAllAddressesButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete,color: Colors.red,),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Delete All Addresses"),
              content:
              const Text("Are you sure you want to delete all addresses?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the alert dialog
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    // Delete all addresses from Firebase
                    FirebaseFirestore.instance
                        .collection('User')
                        .doc(FirebaseAuth.instance.currentUser!.email)
                        .collection('Address')
                        .get()
                        .then((querySnapshot) {
                      querySnapshot.docs.forEach((doc) {
                        doc.reference.delete();
                      });
                    });
                    Navigator.of(context).pop(); // Close the alert dialog
                  },
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class EditAddressScreen extends StatefulWidget {
  final String docId;

  EditAddressScreen({required this.docId});

  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch the address details from Firestore and set the text controllers
    FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('Address')
        .doc(widget.docId)
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        setState(() {
          _nameController.text = docSnapshot.data()!['name'];
          _addressController.text = docSnapshot.data()!['address'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title: const Text("Edit Address",style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18.0,
                  horizontal: 16.0,
                ),
              ),
              cursorColor: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _addressController,
              maxLines: null, // Allows the field to expand vertically
              decoration: InputDecoration(
                labelText: 'Address',
                hintText: 'Enter your address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
              cursorColor: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Update the address details in Firestore
                FirebaseFirestore.instance
                    .collection('User')
                    .doc(FirebaseAuth.instance.currentUser!.email)
                    .collection('Address')
                    .doc(widget.docId)
                    .update({
                  'name': _nameController.text,
                  'address': _addressController.text,
                }).then((value) {
                  // Show a Snackbar message when the address is edited
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Address Changed'),
                    ),
                  );
                  // Navigate back to the previous screen after updating
                  Navigator.pop(context);
                }).catchError((error) {
                  // Handle errors if any
                  print("Failed to update address: $error");
                });
              },
              style: ElevatedButton.styleFrom(
                // Dynamically set button color based on theme
                primary: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                onPrimary: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Colors.black,
              ),
              child: Container(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}