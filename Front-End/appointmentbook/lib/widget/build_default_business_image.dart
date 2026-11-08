import 'package:flutter/material.dart';

class BuildDefaultBusinessImage extends StatelessWidget {
  const BuildDefaultBusinessImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEAF2FF),

      child: const Center(
        child: Icon(Icons.business_rounded, size: 60, color: Color(0xFF1264E8)),
      ),
    );
  }
}
