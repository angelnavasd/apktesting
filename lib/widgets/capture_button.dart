import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/app_theme.dart';

class CaptureButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  
  const CaptureButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: isEnabled ? AppTheme.primaryGradient : null,
          color: isEnabled ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Camera icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                FontAwesomeIcons.camera,
                color: Colors.white,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Text
            Text(
              'Capturar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
