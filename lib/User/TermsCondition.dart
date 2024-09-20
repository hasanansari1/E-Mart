import 'package:e_mart_user/color.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Introduction'),
            _buildParagraph(
              [
                'Welcome to Emart! These terms and conditions outline the rules and regulations for the use of Emart\'s Website and App, located at https://www.shopperstore.com and Emart App.',
                'By accessing this Website and App, we assume you accept these terms and conditions.',
                'Do not continue to use Emart if you do not agree to take all of the terms and conditions stated on this page.',
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Intellectual Property Rights'),
            _buildParagraph(
              [
                'All content included as part of the Service, such as text, graphics, logos, images, as well as the compilation thereof, and any software used on the App, is the property of Emart or its suppliers and protected by copyright and other laws that protect intellectual property and proprietary rights.',
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Limitation of Liability'),
            _buildParagraph(
              [
                'In no event shall Emart, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from:',
                'Your access to or use of or inability to access or use the Service',
                'Any conduct or content of any third party on the Service',
                'Any content obtained from the Service',
                'Unauthorized access, use or alteration of your transmissions or content, whether based on warranty, contract, tort (including negligence) or any other legal theory, whether or not we have been informed of the possibility of such damage, and even if a remedy set forth herein is found to have failed of its essential purpose.',
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Governing Law'),
            _buildParagraph(
              [
                'These Terms shall be governed and construed in accordance with the laws of California, United States, without regard to its conflict of law provisions.',
                'Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights.',
                'If any provision of these Terms is held to be invalid or unenforceable by a court, the remaining provisions of these Terms will remain in effect.',
                'These Terms constitute the entire agreement between us regarding our Service, and supersede and replace any prior agreements we might have between us regarding the Service.',
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph(List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points.map((point) => _buildBulletPoint(point)).toList(),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
