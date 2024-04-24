import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart_user/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountUser extends StatefulWidget {
  const AccountUser({Key? key}) : super(key: key);

  @override
  State<AccountUser> createState() => _AccountUserState();
}

class _AccountUserState extends State<AccountUser> {
  late User? _currentUser;
  late Map<String, dynamic> _userData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
      await FirebaseFirestore.instance
          .collection("User")
          .doc(_currentUser!.uid)
          .get();
      setState(() {
        _userData = userDataSnapshot.data() ?? {};
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text('Account Details',style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditUserInfoScreen(
                    onUserInfoUpdated: _updateUserInfo,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
           child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
           child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
             child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                   radius: 60,
                    backgroundImage: _userData["ProfileImage"] != null
                      ? NetworkImage(_userData["ProfileImage"])
                      : const AssetImage("assets/default_avatar.jpg") as ImageProvider,
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  readOnly: true,
                  initialValue: _userData["Name"] ?? "",
                  decoration: const InputDecoration(
                    labelText: "Username",
                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  readOnly: true,
                  initialValue: _userData["Email"] ?? "",
                  decoration: const InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  readOnly: true,
                  initialValue: _userData["Mobile"] ?? "",
                  decoration: const InputDecoration(
                    labelText: "Mobile Number",
                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  readOnly: true,
                  initialValue: _userData["Password"] ?? "",
                  decoration: const InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateUserInfo() {
    _fetchUserData();
  }
}

class EditUserInfoScreen extends StatefulWidget {
  final VoidCallback onUserInfoUpdated;

  const EditUserInfoScreen({Key? key, required this.onUserInfoUpdated})
      : super(key: key);

  @override
  _EditUserInfoScreenState createState() => _EditUserInfoScreenState();
}

class _EditUserInfoScreenState extends State<EditUserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _passwordController;
  late User? _currentUser;
  File? _selectedImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _passwordController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userData = await FirebaseFirestore.instance.collection("User").doc(_currentUser!.uid).get();

    setState(() {
      _usernameController.text = userData["Name"];
      _emailController.text = userData["Email"];
      _mobileController.text = userData["Mobile"];
      _passwordController.text = userData["Password"];
      _profileImageUrl = userData["ProfileImage"];
    });
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update user data in Firestore
        await FirebaseFirestore.instance.collection("User").doc(_currentUser!.uid).update({
          "Name": _usernameController.text,
          "Mobile": _mobileController.text,
        });

        // Update profile image if selected
        if (_selectedImage != null) {
          String imageUrl = await _uploadImageToStorage(_selectedImage!);
          setState(() {
            _profileImageUrl = imageUrl;
          });
          await FirebaseFirestore.instance.collection("User").doc(_currentUser!.uid).update({
            "ProfileImage": imageUrl,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User information updated successfully")),
        );
        widget.onUserInfoUpdated();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update user information")),
        );
      }
    }
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    try {
      // Upload image file to Firebase Storage
      String fileName = _currentUser!.uid + "_profile_image.jpg";
      Reference reference = FirebaseStorage.instance.ref().child("profile_images").child(fileName);
      await reference.putFile(imageFile);
      String imageUrl = await reference.getDownloadURL();
      return imageUrl;
    } catch (error) {
      print("Error uploading image: $error");
      rethrow; // Throw the error again to handle it in the calling function
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
      // Upload the selected image and update the profile image URL
      String imageUrl = await _uploadImageToStorage(_selectedImage!);
      setState(() {
        _profileImageUrl = imageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text('Edit User',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                      child: _profileImageUrl == null ? const Icon(Icons.add_a_photo) : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  enabled: false, // Set enabled to false to make it unchangeable
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  enabled: false, // Set enabled to false to make it unchangeable
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateUserData,
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                  child: Center(
                    child: Container(
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
        
              ],
            ),
          ),
        ),
      ),
    );
  }
}