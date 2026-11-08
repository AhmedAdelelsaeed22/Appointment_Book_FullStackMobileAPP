import 'dart:async';

import 'package:appointmentbook/screens/login_screen.dart';
import 'package:appointmentbook/widget/build_logo.dart';
import 'package:appointmentbook/widget/circle.dart';
import 'package:appointmentbook/widget/clipper.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // Animation Controllers
  // ============================================================

  late AnimationController _circlesController;
  late AnimationController _waveController;
  late AnimationController _logoController;
  late AnimationController _textController;

  // ============================================================
  // Circle Animations
  // ============================================================

  late Animation<double> _circle1Scale;
  late Animation<double> _circle2Scale;
  late Animation<double> _circle3Scale;
  late Animation<double> _circle4Scale;

  late Animation<double> _circle1Opacity;
  late Animation<double> _circle2Opacity;
  late Animation<double> _circle3Opacity;
  late Animation<double> _circle4Opacity;

  // ============================================================
  // Wave Animation
  // ============================================================

  late Animation<double> _waveAnimation;

  // ============================================================
  // Logo Animation
  // ============================================================

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> logoRotation;

  // ============================================================
  // Text Animation
  // ============================================================

  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _createAnimations();

    // Start animation sequence after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSplashAnimation();
    });
  }

  // ============================================================
  // CREATE ANIMATIONS
  // ============================================================

  void _createAnimations() {
    // ------------------------------------------------------------
    // Circles
    // ------------------------------------------------------------

    _circlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _circle1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _circlesController,
        curve: const Interval(0.00, 0.35, curve: Curves.easeOutBack),
      ),
    );

    _circle2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _circlesController,
        curve: const Interval(0.18, 0.53, curve: Curves.easeOutBack),
      ),
    );

    _circle3Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _circlesController,
        curve: const Interval(0.36, 0.71, curve: Curves.easeOutBack),
      ),
    );

    _circle4Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _circlesController,
        curve: const Interval(0.54, 0.89, curve: Curves.easeOutBack),
      ),
    );

    _circle1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _circlesController,
        curve: const Interval(0.00, 0.20, curve: Curves.easeIn),
      ),
    );

    _circle2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _circlesController,
        curve: const Interval(0.18, 0.38, curve: Curves.easeIn),
      ),
    );

    _circle3Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _circlesController,
        curve: const Interval(0.36, 0.56, curve: Curves.easeIn),
      ),
    );

    _circle4Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _circlesController,
        curve: const Interval(0.54, 0.74, curve: Curves.easeIn),
      ),
    );

    // ------------------------------------------------------------
    // Wave
    // ------------------------------------------------------------

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _waveAnimation = CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOutCubic,
    );

    // ------------------------------------------------------------
    // Logo
    // ------------------------------------------------------------

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
      ),
    );

    logoRotation = Tween<double>(begin: -0.12, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // ------------------------------------------------------------
    // Text
    // ------------------------------------------------------------

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );
  }

  // ============================================================
  // SPLASH SEQUENCE
  // ============================================================

  Future<void> _startSplashAnimation() async {
    // ------------------------------------------------------------
    // STEP 1
    // Paint the circles
    // ------------------------------------------------------------

    await _circlesController.forward();

    // Small pause before wave.
    await Future.delayed(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // STEP 2
    // Paint / reveal the white wave
    // ------------------------------------------------------------

    await _waveController.forward();

    // Small pause before logo.
    await Future.delayed(const Duration(milliseconds: 150));

    // ------------------------------------------------------------
    // STEP 3
    // Show logo
    // ------------------------------------------------------------

    await _logoController.forward();

    // ------------------------------------------------------------
    // STEP 4
    // Show title
    // ------------------------------------------------------------

    await Future.delayed(const Duration(milliseconds: 100));

    await _textController.forward();

    // ------------------------------------------------------------
    // STEP 5
    // Wait
    // ------------------------------------------------------------

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    // ------------------------------------------------------------
    // STEP 6
    // Navigate
    // ------------------------------------------------------------

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const LoginScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // CIRCLE BUILDER
  // ============================================================

  Widget _animatedCircle({
    required Animation<double> scale,
    required Animation<double> opacity,
    required Widget circle,
  }) {
    return FadeTransition(
      opacity: opacity,
      child: ScaleTransition(scale: scale, child: circle),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1264E8),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _circlesController,
          _waveController,
          _logoController,
          _textController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // ==================================================
              // BLUE BACKGROUND
              // ==================================================
              Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF1264E8),
              ),

              // ==================================================
              // CIRCLE 1
              // ==================================================
              Positioned(
                top: -80,
                left: -70,
                child: _animatedCircle(
                  scale: _circle1Scale,
                  opacity: _circle1Opacity,
                  circle: const Circle(size: 230, color: Color(0xFF3B82F6)),
                ),
              ),

              // ==================================================
              // CIRCLE 2
              // ==================================================
              Positioned(
                top: 100,
                right: -100,
                child: _animatedCircle(
                  scale: _circle2Scale,
                  opacity: _circle2Opacity,
                  circle: const Circle(size: 260, color: Color(0xFF0D56D6)),
                ),
              ),

              // ==================================================
              // CIRCLE 3
              // ==================================================
              Positioned(
                top: size.height * 0.22,
                left: -90,
                child: _animatedCircle(
                  scale: _circle3Scale,
                  opacity: _circle3Opacity,
                  circle: const Circle(size: 190, color: Color(0xFF2878EF)),
                ),
              ),

              // ==================================================
              // CIRCLE 4
              // ==================================================
              Positioned(
                top: size.height * 0.12,
                right: -50,
                child: _animatedCircle(
                  scale: _circle4Scale,
                  opacity: _circle4Opacity,
                  circle: const Circle(size: 120, color: Color(0xFF4A90F5)),
                ),
              ),

              // ==================================================
              // YELLOW CIRCLE
              // ==================================================
              Positioned(
                top: size.height * 0.28,
                right: 35,
                child: FadeTransition(
                  opacity: _circle4Opacity,
                  child: ScaleTransition(
                    scale: _circle4Scale,
                    child: const Circle(size: 75, color: Color(0xFFFFD54F)),
                  ),
                ),
              ),

              // ==================================================
              // WHITE PAINT / WAVE
              // ==================================================
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipPath(
                    clipper: Clipper(),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: _waveAnimation.value,
                      child: Container(
                        width: double.infinity,
                        height: size.height * 0.62,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 20,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // LOGO
              // ==================================================
              Positioned(
                top: size.height * 0.48,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: RotationTransition(
                      turns: Tween<double>(
                        begin: -0.02,
                        end: 0.0,
                      ).animate(_logoController),
                      child: const BuildLogo(),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // APP NAME
              // ==================================================
              Positioned(
                top: size.height * 0.64,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textSlide,
                    child: const Column(
                      children: [
                        Text(
                          'Appointment Book',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Manage your appointments easily',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // BOTTOM SMALL TEXT
              // ==================================================
              Positioned(
                bottom: 35,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: const Text(
                    'Your time. Your schedule. Your way.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _circlesController.dispose();
    _waveController.dispose();
    _logoController.dispose();
    _textController.dispose();

    super.dispose();
  }
}
