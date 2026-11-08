import 'package:flutter/material.dart';

class BuildLogo extends StatelessWidget {
  const BuildLogo({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 105,
        height: 105,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1264E8).withOpacity(0.20),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1264E8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1264E8).withOpacity(0.25),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            size: 52,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
