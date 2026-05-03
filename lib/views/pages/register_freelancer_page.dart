import 'package:flutter/material.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_text_field.dart';
import '../../controllers/freelancer_registration_controller.dart';

class RegisterFreelancerPage extends StatefulWidget {
  const RegisterFreelancerPage({super.key});

  @override
  State<RegisterFreelancerPage> createState() =>
      _RegisterFreelancerPageState();
}

class _RegisterFreelancerPageState
  extends State<RegisterFreelancerPage> {

  final RegistrationController _controller = RegistrationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD59E), Color(0xFFFFF8EE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Form(
                  key: _controller.formKeyStep1,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Back button kiri
                            Align(
                              alignment: Alignment.centerLeft,
                              child: CustomBackButton(
                                onTap: () => Navigator.pop(context),
                              ),
                            ),

                            // Title tengah
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Freelancer Register',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Step 1 of 2',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      _buildFormCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildSectionTitle("Personal Information"),

          CustomTextField(
            label: "Full Name",
            hint: "Enter your full name",
            onSaved: (v) => _controller.model.fullName = v!,
          ),

          CustomTextField(
            label: "University",
            hint: "e.g. Politeknik Negeri Malang",
            onSaved: (v) => _controller.model.university = v!,
          ),

          CustomTextField(
            label: "Major",
            hint: "e.g. Informatics Engineering",
            onSaved: (v) => _controller.model.major = v!,
          ),

          CustomTextField(
            label: "Phone Number",
            hint: "+621234567890",
            keyboardType: TextInputType.phone,
            onSaved: (v) => _controller.model.phoneNumber = v!,
          ),

          _buildSectionTitle("Payment Information"),

          const SizedBox(height: 15),

          const Text(
            "Bank",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: _controller.selectedBank,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
            items: _controller.bankList
                .map((bank) => DropdownMenuItem(
                      value: bank,
                      child: Text(bank),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _controller.selectedBank = value;
                _controller.model.bankName = value!;
              });
            },
            validator: (value) => value == null ? "Pilih bank" : null,
          ),

          CustomTextField(
            label: "Nomor Rekening",
            hint: "Masukkan nomor rekening",
            keyboardType: TextInputType.number,
            onSaved: (v) => _controller.model.accountNumber = v!,
          ),

          CustomTextField(
            label: "Nama Pemilik Rekening",
            hint: "Sesuai buku tabungan",
            keyboardType: TextInputType.number,
            onSaved: (v) => _controller.model.accountHolder = v!,
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () =>
                  _controller.handleNextStep(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Next",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF3B82F6),
      ),
    ),
  );
}
}