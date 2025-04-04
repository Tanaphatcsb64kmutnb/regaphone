import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class LoginSuccessWidget extends StatefulWidget {
  final VoidCallback onContinue;
  final String username;

  const LoginSuccessWidget({
    Key? key,
    required this.onContinue,
    required this.username,
  }) : super(key: key);

  @override
  State<LoginSuccessWidget> createState() => _LoginSuccessWidgetState();
}

class _LoginSuccessWidgetState extends State<LoginSuccessWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Timer _timer;
  bool _showContinueButton = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Show continue button after a short delay
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showContinueButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success checkmark animation
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Welcome text
            FadeTransition(
              opacity: _opacityAnimation,
              child: Column(
                children: [
                  Text(
                    'สวัสดี, ${widget.username}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'เข้าสู่ระบบสำเร็จ!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'ยินดีต้อนรับกลับมาสู่ REGA',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF888888),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Continue button with animation
            AnimatedOpacity(
              opacity: _showContinueButton ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: _showContinueButton
                  ? ElevatedButton(
                      onPressed: widget.onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'เริ่มต้นใช้งาน',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    )
                  : const SizedBox(height: 48),
            ),
          ],
        ),
      ),
    );
  }
}

// You can also add this animated background effect
class SuccessScreen extends StatefulWidget {
  final String username;
  final VoidCallback onContinue;

  const SuccessScreen({
    Key? key,
    required this.username,
    required this.onContinue,
  }) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background particles
          Positioned.fill(
            child: SuccessBackgroundParticles(),
          ),

          // Content
          Center(
            child: LoginSuccessWidget(
              username: widget.username,
              onContinue: widget.onContinue,
            ),
          ),
        ],
      ),
    );
  }
}

class SuccessBackgroundParticles extends StatefulWidget {
  @override
  State<SuccessBackgroundParticles> createState() =>
      _SuccessBackgroundParticlesState();
}

class _SuccessBackgroundParticlesState extends State<SuccessBackgroundParticles>
    with TickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize particles
    particles = List.generate(20, (index) => Particle());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(particles, _controller.value),
          child: Container(),
        );
      },
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late Color color;
  late double speed;

  // Random angle in radians
  late double angle;

  Particle() {
    reset();
  }

  void reset() {
    final random = math.Random();
    x = random.nextDouble();
    y = random.nextDouble();
    size = 3 + random.nextDouble() * 6; // 3-9px

    // Green color palette with varying opacity
    final opacity = 0.2 + random.nextDouble() * 0.3;
    color = Color.fromRGBO(
      76,
      175 + random.nextInt(80),
      80 + random.nextInt(100),
      opacity,
    );

    speed = 0.001 + random.nextDouble() * 0.003;
    angle = random.nextDouble() * math.pi * 2;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter(this.particles, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update position
      final x =
          (particle.x + math.cos(particle.angle) * particle.speed * animation) %
              1.0;
      final y =
          (particle.y + math.sin(particle.angle) * particle.speed * animation) %
              1.0;

      // Draw
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
