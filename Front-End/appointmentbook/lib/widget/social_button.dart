import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.icon, required this.onPressed});

  final IconData icon;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF8FAFC),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, color: const Color(0xFF1264E8), size: 26),
      ),
    );
  }
}
