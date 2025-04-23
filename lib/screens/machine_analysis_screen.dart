import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import '../utils/app_theme.dart';

class MachineAnalysisScreen extends StatelessWidget {
  final Map<String, dynamic> analysisResult;

  const MachineAnalysisScreen({
    Key? key, 
    required this.analysisResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido principal con scroll
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con ilustración y título
                  _buildHeader(context),
                  
                  // Contenido principal
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        
                        // Nombre de la máquina
                        _buildInfoSection(
                          title: 'Nombre de la máquina',
                          content: '${analysisResult['nombre_de_la_máquina']}',
                          icon: FontAwesomeIcons.dumbbell,
                        ),
                        
                        if(analysisResult['músculos_principales'] != null 
                        && analysisResult['músculos_principales'].length > 0
                        && analysisResult['músculos_secundarios'] != null 
                        && analysisResult['músculos_secundarios'].length > 0
                        && analysisResult['instrucciones_básicas_de_uso'] != null
                        && analysisResult['instrucciones_básicas_de_uso'].length > 0) ...[
                          
                          // Músculos principales
                          _buildInfoSection(
                            title: 'Músculos principales',
                            content: _formatListContent(analysisResult['músculos_principales']),
                            icon: FontAwesomeIcons.personRunning,
                            iconColor: AppTheme.accentColor,
                          ),
                          
                          // Músculos secundarios
                          _buildInfoSection(
                            title: 'Músculos secundarios',
                            content: _formatListContent(analysisResult['músculos_secundarios']),
                            icon: FontAwesomeIcons.personWalking,
                            iconColor: AppTheme.secondaryColor,
                          ),
                          
                          // Instrucciones
                          _buildInfoSection(
                            title: 'Instrucciones básicas de uso',
                            content: _formatListContent(analysisResult['instrucciones_básicas_de_uso']),
                            icon: FontAwesomeIcons.listCheck,
                            iconColor: AppTheme.primaryColor,
                          ),
                        ],
                        
                        // Espacio para el botón fijo en la parte inferior
                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Botón fijo en la parte inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomButton(context),
            ),
            
            // Botón de retroceso en la esquina superior izquierda
            Positioned(
              top: 16.h,
              left: 16.w,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppTheme.darkColor,
                    size: 24.r,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Header con ilustración y título
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 60.h, bottom: 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Ilustración de gráfico de barras para músculos/gimnasio
          Container(
            height: 180.h,
            width: 180.w,
            child: CustomPaint(
              painter: GymChartPainter(),
              size: Size(180.w, 180.h),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Análisis de máquina',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkColor,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 250.w,
            child: Text(
              'Información detallada sobre la máquina y su uso correcto',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.greyColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Secciones de información
  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
    Color? iconColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de la sección
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20.r,
                  color: iconColor ?? AppTheme.primaryColor,
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido de la sección
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppTheme.darkColor.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Botón inferior de ancho completo
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(true),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono en círculo
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.arrowLeft,
                  color: Colors.white,
                  size: 16.r,
                ),
              ),
              SizedBox(width: 12.w),
              // Texto
              Text(
                'Volver',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Método para formatear el contenido de listas eliminando los corchetes
  String _formatListContent(dynamic content) {
    if (content == null) return '';
    
    String contentStr = content.toString();
    // Eliminar los corchetes al inicio y al final si existen
    if (contentStr.startsWith('[') && contentStr.endsWith(']')) {
      contentStr = contentStr.substring(1, contentStr.length - 1);
    }
    return contentStr;
  }
}

// Painter personalizado para crear una ilustración de gráfico de barras para gimnasio
class GymChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Definir colores
    final Color barColor1 = AppTheme.primaryColor;
    final Color barColor2 = AppTheme.accentColor;
    final Color barColor3 = AppTheme.secondaryColor;
    final Color shadowColor = Colors.black.withOpacity(0.2);
    
    // Dibujar base/plataforma
    paint.color = Colors.grey.shade200;
    final basePath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..lineTo(size.width * 0.9, size.height * 0.9)
      ..lineTo(size.width * 0.1, size.height * 0.9)
      ..close();
    canvas.drawPath(basePath, paint);
    
    // Dibujar sombras de las barras
    paint.color = shadowColor;
    
    // Sombra barra 1
    final shadowPath1 = Path()
      ..moveTo(size.width * 0.25, size.height * 0.7)
      ..lineTo(size.width * 0.35, size.height * 0.7)
      ..lineTo(size.width * 0.35, size.height * 0.8)
      ..lineTo(size.width * 0.25, size.height * 0.8)
      ..close();
    canvas.drawPath(shadowPath1, paint);
    
    // Sombra barra 2
    final shadowPath2 = Path()
      ..moveTo(size.width * 0.45, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.8)
      ..lineTo(size.width * 0.45, size.height * 0.8)
      ..close();
    canvas.drawPath(shadowPath2, paint);
    
    // Sombra barra 3
    final shadowPath3 = Path()
      ..moveTo(size.width * 0.65, size.height * 0.3)
      ..lineTo(size.width * 0.75, size.height * 0.3)
      ..lineTo(size.width * 0.75, size.height * 0.8)
      ..lineTo(size.width * 0.65, size.height * 0.8)
      ..close();
    canvas.drawPath(shadowPath3, paint);
    
    // Dibujar barras con gradientes
    
    // Barra 1
    final rect1 = Rect.fromLTRB(
      size.width * 0.25, size.height * 0.65,
      size.width * 0.35, size.height * 0.8
    );
    final gradient1 = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [barColor1.withOpacity(0.7), barColor1],
    ).createShader(rect1);
    
    paint.shader = gradient1;
    canvas.drawRect(rect1, paint);
    
    // Barra 2
    final rect2 = Rect.fromLTRB(
      size.width * 0.45, size.height * 0.45,
      size.width * 0.55, size.height * 0.8
    );
    final gradient2 = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [barColor2.withOpacity(0.7), barColor2],
    ).createShader(rect2);
    
    paint.shader = gradient2;
    canvas.drawRect(rect2, paint);
    
    // Barra 3
    final rect3 = Rect.fromLTRB(
      size.width * 0.65, size.height * 0.25,
      size.width * 0.75, size.height * 0.8
    );
    final gradient3 = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [barColor3.withOpacity(0.7), barColor3],
    ).createShader(rect3);
    
    paint.shader = gradient3;
    canvas.drawRect(rect3, paint);
    
    // Dibujar detalles de las barras (líneas de medición)
    paint.shader = null;
    paint.color = Colors.white;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    
    // Líneas barra 1
    for (var i = 1; i < 3; i++) {
      final y = size.height * (0.65 + i * 0.05);
      canvas.drawLine(
        Offset(size.width * 0.25, y),
        Offset(size.width * 0.35, y),
        paint
      );
    }
    
    // Líneas barra 2
    for (var i = 1; i < 7; i++) {
      final y = size.height * (0.45 + i * 0.05);
      canvas.drawLine(
        Offset(size.width * 0.45, y),
        Offset(size.width * 0.55, y),
        paint
      );
    }
    
    // Líneas barra 3
    for (var i = 1; i < 11; i++) {
      final y = size.height * (0.25 + i * 0.05);
      canvas.drawLine(
        Offset(size.width * 0.65, y),
        Offset(size.width * 0.75, y),
        paint
      );
    }
    
    // Dibujar contornos de las barras
    paint.color = Colors.black.withOpacity(0.3);
    paint.strokeWidth = 1.5;
    
    canvas.drawRect(rect1, paint);
    canvas.drawRect(rect2, paint);
    canvas.drawRect(rect3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension StringExtension on String {
  String capitalize() {
    return this.length > 0 ? this[0].toUpperCase() + this.substring(1) : '';
  }
}
