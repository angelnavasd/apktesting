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
      appBar: AppBar(
        title: Text('Análisis de máquina'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.circleCheck,
              color: Colors.green,
              size: 60.r,
            ),
            SizedBox(height: 16.h),
            Text(
              'Respuesta recibida correctamente',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mostrar la estructura del JSON para depuración
                  Text(
                    'Estructura del JSON:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _prettyPrintJson(analysisResult),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  // Nombre de la máquina
                  Text(
                    'Nombre de la máquina',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    // Acceder directamente al valor exacto como está en el JSON
                    '${analysisResult['nombre_de_la_máquina']}',
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  if(analysisResult['músculos_principales'] != null 
                  && analysisResult['músculos_principales'].length > 0
                  && analysisResult['músculos_secundarios'] != null 
                  && analysisResult['músculos_secundarios'].length > 0
                  && analysisResult['instrucciones_básicas_de_uso'] != null
                  && analysisResult['instrucciones_básicas_de_uso'].length > 0) ...[
                    // Músculos principales
                    Text(
                      'Músculos principales',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      // Acceder directamente al valor exacto como está en el JSON
                      '${analysisResult['músculos_principales']}',
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    
                    // Músculos secundarios
                    Text(
                      'Músculos secundarios',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      // Acceder directamente al valor exacto como está en el JSON
                      '${analysisResult['músculos_secundarios']}',
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    
                    // Instrucciones básicas de uso
                    Text(
                      'Instrucciones básicas de uso',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${analysisResult['instrucciones_básicas_de_uso']}',
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                // Devolver true para indicar que se debe limpiar el estado
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _prettyPrintJson(Map<String, dynamic> json) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return this.length > 0 ? this[0].toUpperCase() + this.substring(1) : '';
  }
}
