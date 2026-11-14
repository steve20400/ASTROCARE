import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _statsOpacity;
  late Animation<double> _pulseRadius;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _titleSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    _statsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );

    _pulseRadius = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    _pulseController.repeat();

    await Future.delayed(const Duration(milliseconds: 600));
    _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _progressController.forward();

    await Future.delayed(const Duration(milliseconds: 2600));
    widget.onComplete();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstroTheme.bgDark,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoController,
          _contentController,
          _pulseController,
          _progressController,
        ]),
        builder: (context, _) {
          return Stack(
            children: [
              // Animated starfield background
              CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _StarfieldPainter(
                  progress: _contentController.value,
                ),
              ),

              // Central glow pulse
              Center(
                child: Transform.translate(
                  offset: const Offset(0, -80),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, _) {
                      return Container(
                        width: 200 + (_pulseRadius.value * 60),
                        height: 200 + (_pulseRadius.value * 60),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AstroTheme.spaceCyan.withValues(
                                alpha: 0.06 * (1 - _pulseRadius.value),
                              ),
                              blurRadius: 80,
                              spreadRadius: 40,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Animated Logo
                    Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AstroTheme.surfaceElevated,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AstroTheme.spaceCyan.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AstroTheme.spaceCyan.withValues(alpha: 0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.satellite_alt,
                            color: AstroTheme.spaceCyan,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Title
                    Transform.translate(
                      offset: Offset(0, _titleSlide.value),
                      child: Opacity(
                        opacity: _titleOpacity.value,
                        child: Column(
                          children: [
                            const Text(
                              'ASTROCARE',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 6.0,
                                color: AstroTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  AstroTheme.spaceCyan,
                                  AstroTheme.laserViolet,
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'AUTONOMOUS CREW HEALTH SYSTEM',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Subtitle
                    Opacity(
                      opacity: _subtitleOpacity.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Text(
                          'Offline-first multi-hazard synergy detection engine\nfor deep-space human exploration missions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AstroTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Stats badges
                    Opacity(
                      opacity: _statsOpacity.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatBadge('R.I.D.G.E.', 'NASA HRP'),
                          const SizedBox(width: 12),
                          _buildStatBadge('100%', 'OFFLINE'),
                          const SizedBox(width: 12),
                          _buildStatBadge('5', 'HAZARDS'),
                          const SizedBox(width: 12),
                          _buildStatBadge('EN/FR', 'BILINGUAL'),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _progressValue.value,
                              backgroundColor: AstroTheme.surfaceElevated,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AstroTheme.spaceCyan,
                              ),
                              minHeight: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _progressValue.value < 0.3
                                ? 'INITIALIZING TELEMETRY BUFFERS...'
                                : _progressValue.value < 0.6
                                    ? 'LOADING SYNERGY ENGINE...'
                                    : _progressValue.value < 0.9
                                        ? 'CALIBRATING DIGITAL TWIN...'
                                        : 'SYSTEMS NOMINAL ✓',
                            style: TextStyle(
                              fontSize: 9,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: _progressValue.value >= 0.9
                                  ? AstroTheme.nominalEmerald
                                  : AstroTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Footer
                    Opacity(
                      opacity: _statsOpacity.value,
                      child: Column(
                        children: [
                          Text(
                            'NASA SPACE APPS CHALLENGE 2026',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                              color: AstroTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Built with NASA HRP R.I.D.G.E. Framework & GeneLab OSD-288',
                            style: TextStyle(
                              fontSize: 8,
                              letterSpacing: 0.5,
                              color: AstroTheme.textMuted.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatBadge(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AstroTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AstroTheme.borderCard),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
              color: AstroTheme.spaceCyan,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: AstroTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  final double progress;

  _StarfieldPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final starPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.3;
      final alpha = (random.nextDouble() * 0.6 + 0.1) * progress;

      starPaint.color = Color.fromRGBO(255, 255, 255, alpha.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // Subtle nebula glow at top
    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.3, -0.5),
        radius: 0.8,
        colors: [
          AstroTheme.spaceCyan.withValues(alpha: 0.03 * progress),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebulaPaint);
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
