import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  
  const AppLogo({
    super.key,
    this.size = 60.0,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo icon with gradient background
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Muscle icon
                FaIcon(
                  FontAwesomeIcons.dumbbell,
                  color: Colors.white.withOpacity(0.9),
                  size: size * 0.5,
                ),
                // Scanning effect
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.secondaryColor.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // App name text
        if (showText) ...[
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Gym',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                TextSpan(
                  text: 'Scan',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
