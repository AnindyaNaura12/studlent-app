import 'package:flutter/material.dart';

class FreelancerAgreementPage  extends StatelessWidget {
  const FreelancerAgreementPage ({super.key});

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
                          'Freelancer Agreement',
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
                                  _buildSectionTitle('7. Freelancer Agreement'),

                                  _buildParagraph(
                                    'This Freelancer Agreement applies specifically to users who register as freelancers on Studlent.',
                                  ),

                                  const SizedBox(height: 12),

                                  _buildSectionTitle('1. Role of Freelancer'),

                                  _buildBoldText('Freelancers agree to:'),
                                  _buildBullet('Provide services professionally and responsibly'),
                                  _buildBullet('Deliver work according to agreed specifications'),
                                  _buildBullet('Communicate clearly with clients'),

                                  const SizedBox(height: 16),

                                  _buildSectionTitle('2. Commission Fee'),

                                  _buildParagraph(
                                    'Studlent charges a commission fee for each successful transaction. '
                                    'The platform will deduct a commission of [X%] from each completed transaction.',
                                  ),

                                  const SizedBox(height: 16),

                                  _buildSectionTitle('3. Payment Terms'),

                                  _buildBullet('Payments are processed through the platform'),
                                  _buildBullet('Funds will be transferred after completion and confirmation'),
                                  _buildBullet('Withdrawal timelines may vary (e.g., within 3–7 business days)'),

                                  const SizedBox(height: 16),

                                  _buildSectionTitle('4. Responsibilities'),

                                  _buildBullet('Maintain professionalism in all interactions'),
                                  _buildBullet('Ensure the quality of delivered work'),
                                  _buildBullet('Respect deadlines and agreements'),

                                  const SizedBox(height: 16),

                                  _buildSectionTitle('5. Violations'),

                                  _buildParagraph(
                                    'Studlent reserves the right to suspend or terminate freelancer accounts '
                                    'that violate platform rules, engage in fraud, or provide poor service quality.',
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