// ignore_for_file: file_names

import 'package:e_mart_user/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../BottomNavigation/BottomNavigation.dart';
import 'SignUpScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(top: 100, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome to E-Mart",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Let's User Login to the E-Mart",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter email";
                        } else if (!value.contains("@") || !value.contains(".")) {
                          return "Please Enter A Valid Email";
                        }
                        return null;
                      },
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Enter Your Email",
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please Enter Password";
                        }
                        return null;
                      },
                      controller: passwordController,
                      obscureText: passwordVisible,
                      decoration: InputDecoration(
                        hintText: "Enter Your Password",
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                          icon: passwordVisible
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => BottomNavigationHome()),
                              );
                              setState(() {
                                emailController.clear();
                                passwordController.clear();
                              });
                            } on FirebaseAuthException catch (e) {
                              print("Firebase Auth Exception: ${e.code}");
                              if (e.code == "user-not-found" || e.code == "wrong-password") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Invalid Email or Password"),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Invalid Email or Password"),
                                  ),
                                );
                              }
                            } catch (e) {
                              print("Error: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Invalid Email or Password"),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(70),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Center(
                            child: Icon(Icons.arrow_forward_outlined, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an Account ?"),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                        },
                        child: const Text("Sign Up", style: TextStyle(color: Colors.blueGrey)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}