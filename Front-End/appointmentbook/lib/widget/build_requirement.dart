import 'package:flutter/material.dart';

class BuildRequirement extends StatelessWidget {
  const BuildRequirement({
    super.key,
    required this.text,
    required this.isValid,
  });

  final String text;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isValid
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFF1F5F9),
            ),
            child: Icon(
              isValid ? Icons.check_rounded : Icons.circle_outlined,
              size: isValid ? 14 : 11,
              color: isValid ? Colors.white : const Color(0xFF94A3B8),
            ),
          ),

          const SizedBox(width: 10),

          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isValid
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF64748B),
              fontWeight: isValid ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
