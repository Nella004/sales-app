import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'theme.dart';
import 'main.dart' show VendorListScreen;

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Offset> _leftSlide;
  late Animation<Offset> _rightSlide;
  late Animation<double> _leftRotate;
  late Animation<double> _rightRotate;

  late Animation<double> _sparkOpacity;
  late Animation<double> _sparkScale;

  late Animation<double> _markScale;

  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

    _leftSlide = Tween<Offset>(begin: const Offset(-1.6, -0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack)),
    );

    _rightSlide = Tween<Offset>(begin: const Offset(1.6, -0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack)),
    );

    _leftRotate = Tween<double>(begin: -0.9, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.55, curve: Curves.easeOut)),
    );

    _rightRotate = Tween<double>(begin: 0.9, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.55, curve: Curves.easeOut)),
    );

    _sparkOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.48, 0.7, curve: Curves.easeOut)));

    _sparkScale = Tween<double>(begin: 0.3, end: 2.2).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.48, 0.7, curve: Curves.easeOut)),
    );

     _markScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.52, 0.75, curve: Curves.easeOut)));

     _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack)),
    );


    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => VendorListScreen()),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: AnimatedBuilder(
      animation: _controller, 
      builder: (context, child) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: _sparkOpacity.value,
                    child: Transform.scale(
                      scale: _sparkScale.value,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [Colors.white.withOpacity(0.9), AppTheme.accent.withOpacity(0.0)],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Transform.scale(
                    scale: _markScale.value,
                    child: SizedBox(
                      width: 140,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.translate(
                            offset: _leftSlide.value * 70,
                            child: Transform.rotate(
                              angle: _leftRotate.value,
                              child: CustomPaint(
                                size: const Size(140, 120),
                                painter: _WireStrokePainter(side: _WireSide.left),
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: _rightSlide.value * 70,
                            child: Transform.rotate(
                              angle: _rightRotate.value,
                              child: CustomPaint(
                                size: const Size(140, 120),
                                painter: _WireStrokePainter(side: _WireSide.left),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 22),
              Opacity(
                opacity: _textOpacity.value,
                child: Transform.translate(
                  offset: _textSlide.value * 20,
                  child: const Text(
                    'WIRELY',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                    ),
                  ),
                ),
              ),
          ],
        ),
      )
    ),
  );
}

enum _WireSide { left, right }

class _WireStrokePainter extends CustomPainter {
  final _WireSide side;
  _WireStrokePainter({ required this.side});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    if (side == _WireSide.left) {
      path.moveTo(w * 0.08, h * 0.18);
      path.lineTo(w * 0.28, h * 0.82);
      path.lineTo(w * 0.48, h * 0.38);
    } else {
      path.moveTo(w * 0.92, h * 0.18);
      path.lineTo(w * 0.72, h * 0.82);
      path.lineTo(w * 0.52, h * 0.38);
    }

    final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..shader = AppTheme.accentGradient.createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(
      path, 
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppTheme.accent.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WireStrokePainter oldDelegate) => false;

}