import 'package:e_mart_user/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider.dart';
import 'NeedHelp.dart';
import 'PrivacyPolicy.dart';
import 'ReturnPolicy.dart';
import 'SavedAddress.dart';
import 'TermsCondition.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title: const Text('Settings',style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 80,
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Change Your Theme color",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                        },
                        icon: const Icon(Icons.brightness_4_outlined),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Account Settings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              buildSettingsItem(context, "Manage Notifications", Icons.notifications, () {
                // Action for Manage Notifications
              }),
              const SizedBox(height: 10,),
              buildSettingsItem(context, "Saved Addresses", Icons.location_on, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SavedAddressScreen()));
              }),
              const SizedBox(height: 20),
              const Text(
                "Feedback & Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              buildSettingsItem(context, "Terms of Use", Icons.description, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsAndConditionsPage()));
              }),
              const SizedBox(height: 10,),
              buildSettingsItem(context, "Privacy Policy", Icons.privacy_tip, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  const PrivacyPolicyPage()));
              }),
              const SizedBox(height: 10,),
              buildSettingsItem(context, "Return Policy", Icons.keyboard_return, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  const ReturnPolicyScreen()));
              }),
              const SizedBox(height: 10,),
              buildSettingsItem(context, "Help Center", Icons.help, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  const NeedHelpScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSettingsItem(BuildContext context, String title, IconData icon, Function() onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
