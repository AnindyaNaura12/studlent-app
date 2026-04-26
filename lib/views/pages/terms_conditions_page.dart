import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD59E), Color(0xFFFFF8EE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Logo
              Image.asset('assets/images/logo_studlent.png', height: 70),
              const SizedBox(height: 24),

              // White card content
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(24, 28, 8, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Center(
                        child: Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Scrollable content inside a bordered box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildParagraph(
                                    'Welcome to Studlent, a platform that connects clients with freelancers for various services. By accessing or using the Studlent application, you agree to be bound by these Terms & Conditions.',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSectionTitle('1. Definitions'),
                                  _buildBullet(
                                    'Platform refers to Studlent application.',
                                  ),
                                  _buildBullet(
                                    'User refers to anyone who accesses or uses the platform.',
                                  ),
                                  _buildBullet(
                                    'Client refers to users who request services.',
                                  ),
                                  _buildBullet(
                                    'Freelancer refers to users who provide services.',
                                  ),
                                  _buildBullet(
                                    'Services refer to tasks or jobs offered through the platform.',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSectionTitle('2. Use of the Platform'),
                                  _buildBoldText('Users agree to:'),
                                  _buildBullet(
                                    'Provide accurate and complete information',
                                  ),
                                  _buildBullet(
                                    'Use the platform only for lawful purposes',
                                  ),
                                  _buildBullet(
                                    'Not misuse or exploit the platform',
                                  ),
                                  _buildParagraph(
                                    'Studlent reserves the right to restrict or terminate access if violations occur.',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSectionTitle('3. Privacy'),
                                  _buildParagraph(
                                    'We collect and process personal data in accordance with our Privacy Policy. By using the platform, you consent to such processing and you warrant that all data provided by you is accurate.',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSectionTitle('4. Payments'),
                                  _buildParagraph(
                                    'All payments are processed securely through the platform. Studlent charges a service fee for each transaction completed. Refunds are subject to our Refund Policy.',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSectionTitle(
                                    '5. Intellectual Property',
                                  ),
                                  _buildParagraph(
                                    'All content on the platform, including logos, text, and design, is the property of Studlent and may not be used without permission.',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSectionTitle('6. Changes to Terms'),
                                  _buildParagraph(
                                    'Studlent reserves the right to modify these Terms & Conditions at any time. Continued use of the platform after changes constitutes acceptance of the new terms.',
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, right: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildBoldText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, right: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}