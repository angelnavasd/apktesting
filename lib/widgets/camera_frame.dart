import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/app_theme.dart';

class CameraFrame extends StatelessWidget {
  final Widget child;
  final double size;
  final bool isInitialized;
  final VoidCallback? onPermissionRequest;
  
  const CameraFrame({
    super.key,
    required this.child,
    required this.size,
    required this.isInitialized,
    this.onPermissionRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Camera preview or placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: child,
          ),
          
          // Scanning effect overlay
          if (isInitialized)
            Positioned.fill(
              child: _buildScanOverlay(),
            ),
          
          // Corner decorations
          ..._buildCornerDecorations(),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Horizontal scan line animation
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.secondaryColor.withOpacity(0.8),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            
            // Target crosshair in center
            Center(
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.center_focus_strong_outlined,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerDecorations() {
    return [
      // Top left corner
      Positioned(
        top: 10,
        left: 10,
        child: _buildCorner(Alignment.topLeft),
      ),
      // Top right corner
      Positioned(
        top: 10,
        right: 10,
        child: _buildCorner(Alignment.topRight),
      ),
      // Bottom left corner
      Positioned(
        bottom: 10,
        left: 10,
        child: _buildCorner(Alignment.bottomLeft),
      ),
      // Bottom right corner
      Positioned(
        bottom: 10,
        right: 10,
        child: _buildCorner(Alignment.bottomRight),
      ),
    ];
  }

  Widget _buildCorner(Alignment alignment) {
    // Determine rotation based on corner position
    double rotationAngle = 0;
    if (alignment == Alignment.topRight) rotationAngle = 90 * (3.14159 / 180);
    if (alignment == Alignment.bottomRight) rotationAngle = 180 * (3.14159 / 180);
    if (alignment == Alignment.bottomLeft) rotationAngle = 270 * (3.14159 / 180);

    return Transform.rotate(
      angle: rotationAngle,
      child: SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(
          painter: CornerPainter(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}

class CornerPainter extends CustomPainter {
  final Color color;
  
  CornerPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw L shape
    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..lineTo(0, 0)
      ..lineTo(size.width * 0.4, 0);
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(CornerPainter oldDelegate) => color != oldDelegate.color;
}
