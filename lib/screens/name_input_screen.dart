import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _controller = TextEditingController();

  // Color Palette matching CSS variables
  static const Color colorWhite = Color(0xFFFBFCFE);
  static const Color colorOffWhite = Color(0xFFF4F7FC);
  static const Color colorBluePale = Color(0xFFE5EEFB);
  static const Color colorCyanPale = Color(0xFFE2F5F6);
  static const Color colorLavender = Color(0xFFECE7FB);
  static const Color colorNavy = Color(0xFF1B2340);
  static const Color colorNavySoft = Color(0xFF4A527A);
  static const Color colorAccentA = Color(0xFF6C8EF5);
  static const Color colorAccentB = Color(0xFFB18AF8);

  Future<void> _saveNameAndContinue() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(userName: name)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient Stage
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colorWhite, colorOffWhite],
              ),
            ),
          ),
          // Radial Glows simulating your CSS radial-gradients
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: colorCyanPale,
              ),
            ).blurred(blur: 80),
          ),
          Positioned(
            top: -50,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: colorLavender,
              ),
            ).blurred(blur: 80),
          ),
          Positioned(
            bottom: -150,
            left: MediaQuery.of(context).size.width / 2 - 200,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: colorBluePale,
              ),
            ).blurred(blur: 100),
          ),

          // 2. Main Glassmorphism Panel
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22.0, sigmaY: 22.0),
                  child: Container(
  constraints: const BoxConstraints(
    maxWidth: 460, // ✅ Fixed
  ),
  padding: const EdgeInsets.symmetric(
    horizontal: 36.0,
    vertical: 48.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.46),
                      borderRadius: BorderRadius.circular(28.0),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.7),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF465AA0).withValues(alpha: 0.18),
                          blurRadius: 60,
                          offset: const Offset(0, 30),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Icon Mark
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            gradient: const LinearGradient(
                              colors: [colorAccentA, colorAccentB],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7882F0).withValues(alpha: 0.55),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.compare_arrows_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Title Text
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: colorNavy,
                              fontFamily: 'Space Grotesk',
                              height: 1.25,
                            ),
                            children: [
                              const TextSpan(text: 'Welcome to '),
                              WidgetSpan(
                                child: ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      colorAccentA,
                                      Color(0xFF9A7FF2),
                                      colorAccentB
                                    ],
                                  ).createShader(bounds),
                                  child: const Text(
                                    'Contrast',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontFamily: 'Space Grotesk',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Subtitle
                        const Text(
                          "Let's personalize your comparison experience.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colorNavySoft,
                          ),
                        ),
                        const SizedBox(height: 34),

                        // Name Input Textfield
                        TextField(
                          controller: _controller,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colorNavy,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your name',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9AA2BD),
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.75),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 17,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorNavy.withValues(alpha: 0.10),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorNavy.withValues(alpha: 0.10),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0x8C6C8EF5),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Gradient Submit Button
                        GestureDetector(
                          onTap: _saveNameAndContinue,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6C8EF5),
                                  Color(0xFF8F7CF5),
                                  Color(0xFFB18AF8)
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7882F0).withValues(alpha: 0.55),
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Fineprint
                        const Text(
                          'Your picks stay private. Change your name anytime.',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9AA2BD),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to easily blur background radial glows
extension BlurExtension on Widget {
  Widget blurred({double blur = 50}) {
    return ImageFilterWidget(blur: blur, child: this);
  }
}

class ImageFilterWidget extends StatelessWidget {
  final double blur;
  final Widget child;
  const ImageFilterWidget({super.key, required this.blur, required this.child});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: child,
    );
  }
}