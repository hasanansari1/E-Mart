import 'package:e_mart_user/color.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class NeedHelpScreen extends StatelessWidget {
  const NeedHelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Need Help',style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const FAQItem(
              question: 'How do I place an order?',
              answer:
              'To place an order, simply browse through our collection, select the items you want to purchase, and proceed to the checkout page. Follow the prompts to complete your order.',
            ),
            const FAQItem(
              question: 'What payment methods do you accept?',
              answer:
              'We accept various payment methods, including credit/debit cards, PayPal, and cash on delivery (COD). You can choose your preferred payment option during checkout.',
            ),
            const FAQItem(
              question: 'How can I track my order?',
              answer:
              'Once your order is shipped, you will receive a tracking number via email or SMS. You can use this tracking number to track the status of your delivery on our website or through our delivery partner’s website.',
            ),
            const FAQItem(
              question: 'Do you offer international shipping?',
              answer:
              'Yes, we offer international shipping to select countries. Shipping fees and delivery times may vary depending on the destination. Please refer to our shipping policy for more information.',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Contact Us',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ContactItem(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'mailto:support@emart.com',
              onTap: () {
                launchEmail('support@emart.com');
              },
            ),
            ContactItem(
              icon: Icons.phone,
              title: 'Phone',
              subtitle: '+91 9639639633',
              onTap: () {
                launchPhone('+919639639633');
              },
            ),
            ContactItem(
              icon: Icons.location_on,
              title: 'Address',
              subtitle: 'Silver Oak University, Ahmedabad ',
              onTap: () {
                launchMap('Silver+Oak+University,+Ahmedabad,+Gujarat');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    final url = emailLaunchUri.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> launchPhone(String phoneNumber) async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    final url = phoneLaunchUri.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> launchMap(String query) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({
    Key? key,
    required this.question,
    required this.answer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(answer),
        const Divider(),
        const SizedBox(height: 20),
      ],
    );
  }
}

class ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? mapQuery;
  final VoidCallback? onTap;

  const ContactItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.mapQuery,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
