import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final Function(String?) onSaved;
  final String? Function(String?)? validator;
  final IconData? icon;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.onSaved,
    this.keyboardType,
    this.validator,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 🔹 LABEL
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 8),

          // 🔹 TEXT FIELD
          TextFormField(
            keyboardType: keyboardType,
            onSaved: onSaved,
            validator: validator ??
                (value) =>
                    value == null || value.isEmpty
                        ? "Field ini wajib diisi"
                        : null,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey.shade100,
              hintStyle: TextStyle(color: Colors.grey.shade400),

              // 🔥 ICON OPSIONAL
              prefixIcon: icon != null ? Icon(icon) : null,

              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15, vertical: 15),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}