import 'package:flutter/material.dart';
import 'package:nsmvision_odovinrecog/camera_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    Future.delayed(Duration(seconds: 3), () {
Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CameraScreen()
                              ),
                            );    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCE5F9),
      body: Container(
        alignment: Alignment.centerRight,
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset('assets/SplashScreen.png'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
