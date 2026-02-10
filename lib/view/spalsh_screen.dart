import 'package:flutter/material.dart';
import '../config/theam_data.dart';
import '../constants/app_constants.dart';
import '../utils/navigation_utils.dart';

/// Splash screen with River Buzz branding
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
    _simulateProgress();
    _navigateToHome();
  }

  void _simulateProgress() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _progress = 0.25;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _progress = 0.5;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _progress = 0.75;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _progress = 1.0;
        });
      }
    });
  }

  void _navigateToHome() {
    Future.delayed(AppConstants.splashDuration, () {
      if (mounted) {
        NavigationUtils.pushReplacementNamed(context, AppConstants.loginRoute);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F4F8), // Light blue-grey at top
              Color(0xFFF5F5F5), // Light grey
              Color(0xFFE8F4F8), // Light blue-grey at bottom
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Top wave decoration
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(size.width, 180),
                painter: WavePainter(
                  color: const Color(0xFFB3D9E8),
                  amplitude: 40,
                  frequency: 1.5,
                ),
              ),
            ),
            
            // Bottom wave decoration
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(size.width, 180),
                painter: WavePainter(
                  color: const Color(0xFFB3D9E8),
                  amplitude: 40,
                  frequency: 1.5,
                  inverted: true,
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Icon with shadow
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF2196F3),
                                  Color(0xFF1976D2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.sailing,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // App Name
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 42,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            children: [
                              TextSpan(
                                text: 'River ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              TextSpan(
                                text: 'Buzz',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2196F3),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Partner App Label
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF2196F3).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'PARTNER APP',
                            style: TextStyle(
                              color: Color(0xFF1976D2),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 80),

                        // Progress Section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'INITIALIZING TERMINAL',
                                    style: TextStyle(
                                      color: Color(0xFF757575),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '${(_progress * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: Color(0xFF2196F3),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _progress,
                                  backgroundColor: const Color(0xFFE0E0E0),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF2196F3),
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Tagline
                        Text(
                          AppConstants.appTagline,
                          style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF9E9E9E),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for wave decoration
class WavePainter extends CustomPainter {
  final Color color;
  final double amplitude;
  final double frequency;
  final bool inverted;

  WavePainter({
    required this.color,
    this.amplitude = 30,
    this.frequency = 1.0,
    this.inverted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (inverted) {
      path.moveTo(0, size.height);
      
      for (double i = 0; i <= size.width; i++) {
        final y = size.height - 
            amplitude * 
            (1 + 
                0.5 * (i / size.width).clamp(0.0, 1.0) * 
                (1 - (i / size.width).clamp(0.0, 1.0)));
        path.lineTo(i, y);
      }
      
      path.lineTo(size.width, size.height);
      path.close();
    } else {
      path.moveTo(0, 0);
      
      for (double i = 0; i <= size.width; i++) {
        final y = amplitude * 
            (1 + 
                0.5 * (i / size.width).clamp(0.0, 1.0) * 
                (1 - (i / size.width).clamp(0.0, 1.0)));
        path.lineTo(i, y);
      }
      
      path.lineTo(size.width, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => false;
}