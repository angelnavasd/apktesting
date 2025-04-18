import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../utils/app_theme.dart';
import '../widgets/app_logo.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navegar a la pantalla principal después de 3 segundos
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightColor,
              Colors.white,
              AppTheme.lightColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animado
                AppLogo(size: 120.r)
                  .animate()
                  .scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                  )
                  .then(delay: 1500.ms)
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 1200.ms,
                    color: Colors.white.withOpacity(0.8),
                  ),
                
                SizedBox(height: 60.h),
                
                // Texto de eslogan
                Text(
                  'Identifica los músculos que trabajas',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppTheme.greyColor,
                    letterSpacing: 0.5,
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 800.ms)
                .slide(
                  begin: const Offset(0, 20),
                  end: const Offset(0, 0),
                  curve: Curves.easeOutQuad,
                ),
                
                SizedBox(height: 16.h),
                
                // Texto de carga
                Text(
                  'Preparando cámara...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.greyColor.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                )
                .animate()
                .fadeIn(delay: 800.ms, duration: 800.ms)
                .slide(
                  begin: const Offset(0, 10),
                  end: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
