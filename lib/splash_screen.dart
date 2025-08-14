import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.1, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutQuart)),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 0.9)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.05,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.05,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 20.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.2,
      ),
    ]).animate(_controller);

    _bounceAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -30.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -30.0, end: 15.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 0.15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 15.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.05,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.0),
        weight: 0.5,
      ),
    ]).animate(_controller);

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1600), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_scaleAnimation.value > 5.0) {
            return Container(color: Colors.black);
          }

          return Center(
            child: Transform.translate(
              offset: Offset(0, _bounceAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _controller.value < 0.8 ? 1.0 : 1.0 - (_controller.value - 0.8) * 5,
                  child: Image.asset(
                    'assets/escudo.png',
                    width: 200,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}