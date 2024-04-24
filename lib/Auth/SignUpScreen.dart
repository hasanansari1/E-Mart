import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../color.dart';
import 'LoginScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _isLoading = false;
  final String _uniqueFilename =
      DateTime.now().millisecondsSinceEpoch.toString();
  XFile? _selectedImage;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.only(top: 100, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to E-Mart',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Let's Sign Up to E-Mart",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _selectedImage != null
                            ? FileImage(File(_selectedImage!.path))
                            : null,
                        child: _selectedImage == null
                            ? IconButton(
                                onPressed: () async {
                                  final ImagePicker picker = ImagePicker();
                                  _selectedImage = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.add_a_photo),
                              )
                            : null,
                      ),
                    ),
                    _selectedImage != null
                        ? IconButton(
                            onPressed: () {
                              _selectedImage = null;
                              setState(() {});
                            },
                            icon: const Icon(Icons.cancel),
                          )
                        : const SizedBox(),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Your Username",
                    labelText: "Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    prefixIcon: const Icon(Icons.account_box_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    } else if (!value.contains("@") || !value.contains(".")) {
                      return "Please enter valid email";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: "Enter your email",
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      prefixIcon: const Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Password";
                    }
                    return null;
                  },
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _mobileController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Mobile Number";
                    } else if (value.length != 10) {
                      return "Mobile Number should be 10 digits";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  maxLength: 10, // Restrict input to 10 digits
                  decoration: InputDecoration(
                    hintText: "Please Enter Your Mobile No.",
                    labelText: "Mobile No.",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    prefixIcon: const Icon(Icons.phone),
                    counterText: "", // Remove the counter text
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        side: const BorderSide(color: Colors.black),
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an Account?"),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()));
                      },
                      child: const Text("Login",
                          style: TextStyle(color: Colors.lightGreen)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        if (_selectedImage != null) {
          final File imageFile = File(_selectedImage!.path);

          Reference referenceRoot = FirebaseStorage.instance.ref();
          Reference referenceDirImage = referenceRoot.child('User_images');
          Reference referenceImageToUpload =
              referenceDirImage.child(_uniqueFilename);
          await referenceImageToUpload.putFile(imageFile);
          String imageUrl = await referenceImageToUpload.getDownloadURL();

          UserCredential userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          await FirebaseFirestore.instance
              .collection("User")
              .doc(userCredential.user!.uid)
              .set({
            "Name": _usernameController.text,
            "Email": _emailController.text,
            "Password": _passwordController.text,
            "Mobile": _mobileController.text,
            "UID": FirebaseAuth.instance.currentUser!.uid,
            "DocumentID": userCredential.user!.uid,
            'Address': addressController.text,
            "ProfileImage": imageUrl,
          });

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registered Successfully")));

          // Clear text fields and reset selected image
          _usernameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _mobileController.clear();
          _selectedImage = null;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please select an image")));
        }
      } catch (e) {
        print("Error registering user: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to register user")));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}