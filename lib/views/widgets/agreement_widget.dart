import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class AgreementWidget extends StatelessWidget {
  final bool value;
  final Function(bool) onTap;

  final String text;
  final VoidCallback? onLinkTap;

  const AgreementWidget({
    super.key,
    required this.value,
    required this.onTap,
    required this.text,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔵 Circle
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? const Color(0xFF3B82F6) : Colors.transparent,
              border: Border.all(
                color: value
                    ? const Color(0xFF3B82F6)
                    : Colors.grey.shade400,
                width: 1.2,
              ),
            ),
            child: value
                ? const Center(
                    child: Icon(
                      Icons.check,
                      size: 10, // kecil biar proporsional
                      color: Colors.white,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade800,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: text,
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = onLinkTap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}