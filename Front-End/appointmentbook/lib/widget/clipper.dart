import 'package:flutter/rendering.dart';

class Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 15);

    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.50, 25);

    path.quadraticBezierTo(size.width * 0.75, 50, size.width, 5);

    path.lineTo(size.width, size.height);

    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
