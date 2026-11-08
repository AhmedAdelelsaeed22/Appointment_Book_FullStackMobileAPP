import 'package:appointmentbook/widget/clipper.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        children: [
          // --------------------------------------------------------------
          // BLUE BACKGROUND
          // --------------------------------------------------------------
          Container(
            width: double.infinity,
            height: 220,
            decoration: const BoxDecoration(color: Color(0xFF1264E8)),
          ),

          // --------------------------------------------------------------
          // LEFT DECORATION
          // --------------------------------------------------------------
          Positioned(
            left: -55,
            top: 20,
            child: Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // --------------------------------------------------------------
          // RIGHT DECORATION
          // --------------------------------------------------------------
          Positioned(
            right: -45,
            top: 60,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF0B55C9),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // --------------------------------------------------------------
          // LOGO
          // --------------------------------------------------------------
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),

          // --------------------------------------------------------------
          // APP NAME
          // --------------------------------------------------------------
          const Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Appointment Book',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // --------------------------------------------------------------
          // CURVED WHITE SECTION
          // --------------------------------------------------------------
          Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: Clipper(),
              child: Container(height: 55, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
