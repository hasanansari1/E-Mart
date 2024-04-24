// ignore_for_file: file_names

import 'package:e_mart_user/color.dart';
import 'package:flutter/material.dart';

class ReturnPolicyScreen extends StatelessWidget {
  const ReturnPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Return Policy', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                'Return Policy for Emart',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('1. Eligibility Criteria'),
            _buildParagraph(
              'Items must be unused and in the same condition that you received them. It must also be in the original packaging.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('2. Timeframe'),
            _buildParagraph(
              'You have 30 calendar days to return an item from the date you received it.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('3. Refund Process'),
            _buildParagraph(
              'Once we receive your item, we will inspect it and notify you that we have received your returned item. We will immediately notify you on the status of your refund after inspecting the item.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }
}
