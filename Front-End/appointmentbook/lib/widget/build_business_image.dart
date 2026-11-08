import 'package:appointmentbook/widget/build_default_business_image.dart';
import 'package:flutter/material.dart';

class BuildBusinessImage extends StatelessWidget {
  const BuildBusinessImage({super.key, required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const BuildDefaultBusinessImage();
    }

    return Image.network(
      imageUrl!,

      fit: BoxFit.cover,

      width: double.infinity,

      errorBuilder: (context, error, stackTrace) {
        return const BuildDefaultBusinessImage();
      },

      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: const Color(0xFFEAF2FF),

          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
