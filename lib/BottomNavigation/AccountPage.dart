// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Auth/LoginScreen.dart';
import '../Orders/Orders.dart';
import '../User/AccountUser.dart';
import '../User/SettingScreen.dart';
import 'BottomNavigation.dart';
import 'FavPage.dart';


class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BottomNavigationHome(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Text(
                      'Account Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.person)
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Column(
                  children: [
                    // Your Account
                    SizedBox(
                      height: 70,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccountUser(),
                            ),
                          );
                        },
                        child: const Card(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("My Account", style: TextStyle(fontSize: 20)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.account_box),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Your Order
                    SizedBox(
                      height: 70,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => OrderListScreen()));
                        },
                        child: const Card(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("My Order", style: TextStyle(fontSize: 20)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.shopping_cart),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Your Wish List
                    SizedBox(
                      height: 70,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const FavPage()));
                        },
                        child: const Card(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("My WishList", style: TextStyle(fontSize: 20)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.favorite),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Setting
                    SizedBox(
                      height: 70,
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => const Settingpage()));
                        },
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingScreen()));
                          },
                          child: const Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Setting", style: TextStyle(fontSize: 20)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.settings),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 70,
                      child: GestureDetector(
                        onTap: () {
                          // FirebaseAuth.instance.signOut();
                          // {
                          //   Navigator.of(context).pushAndRemoveUntil(
                          //     MaterialPageRoute(
                          //       builder: (context) => const LoginPage(),
                          //     ),
                          //         (route) => false,
                          //   );
                          // }
                        },
                        child: GestureDetector(
                          onTap: () {
                            FirebaseAuth.instance.signOut();
                            {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                      (route) => false);
                            }
                          },
                          child: const Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Logout", style: TextStyle(fontSize: 20)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.logout),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(
                    //   height: 100,
                    // ),
                    // const Column(
                    //   children: [
                    //     Text("Contact Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    //     SizedBox(
                    //       height: 30,
                    //     ),
                    //     Text("Contact No:  123456789"),
                    //     SizedBox(
                    //       height: 30,
                    //     ),
                    //     Text("E-mail Id:  mailto:xyz@gmail.com")
                    //   ],
                    // )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}