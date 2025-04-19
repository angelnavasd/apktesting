import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/app_theme.dart';
import '../widgets/muscle_icon.dart';

class MachineAnalysisScreen extends StatelessWidget {
  final Map<String, dynamic> analysisResult;

  const MachineAnalysisScreen({
    Key? key, 
    required this.analysisResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final machineName = analysisResult['nombre_de_la_máquina'] ?? 'Máquina desconocida';
    final primaryMuscles = analysisResult['músculos_principales'] ?? 'No identificado';
    final secondaryMuscles = analysisResult['músculos_secundarios'] ?? 'No identificado';
    final instructions = analysisResult['instrucciones_básicas_de_uso'] ?? 'No hay instrucciones disponibles';

    // Convertir a lista si es string
    List<String> primaryMusclesList = [];
    if (primaryMuscles is String) {
      if (primaryMuscles != 'No identificado' && primaryMuscles != 'No se puede identificar') {
        primaryMusclesList = [primaryMuscles];
      }
    } else if (primaryMuscles is List) {
      primaryMusclesList = List<String>.from(primaryMuscles);
    }

    List<String> secondaryMusclesList = [];
    if (secondaryMuscles is String) {
      if (secondaryMuscles != 'No identificado' && secondaryMuscles != 'No se puede identificar') {
        secondaryMusclesList = [secondaryMuscles];
      }
    } else if (secondaryMuscles is List) {
      secondaryMusclesList = List<String>.from(secondaryMuscles);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Análisis de máquina'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Contenido principal con scroll
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 80.h), // Espacio para el botón
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre de la máquina con icono grande
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          FontAwesomeIcons.dumbbell,
                          color: AppTheme.primaryColor,
                          size: 48.r,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          machineName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Músculos principales
                  _buildSectionTitle('Músculos principales', FontAwesomeIcons.personRunning),
                  SizedBox(height: 8.h),
                  _buildMusclesList(primaryMusclesList, true),
                  
                  SizedBox(height: 24.h),
                  
                  // Músculos secundarios
                  _buildSectionTitle('Músculos secundarios', FontAwesomeIcons.personWalking),
                  SizedBox(height: 8.h),
                  _buildMusclesList(secondaryMusclesList, false),
                  
                  SizedBox(height: 24.h),
                  
                  // Instrucciones
                  _buildSectionTitle('Instrucciones de uso', FontAwesomeIcons.circleInfo),
                  SizedBox(height: 8.h),
                  _buildInstructions(instructions),
                  
                  // Espacio adicional al final para asegurar que el contenido no quede detrás del botón
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
          
          // Botón sticky en la parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Volver a la pantalla anterior
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FontAwesomeIcons.camera),
                    SizedBox(width: 8.w),
                    Text(
                      'Volver a Escanear',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20.r,
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMusclesList(List<String> muscles, bool isPrimary) {
    if (muscles.isEmpty) {
      return Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              FontAwesomeIcons.circleQuestion,
              color: Colors.grey,
              size: 16.r,
            ),
            SizedBox(width: 8.w),
            Text(
              'No se pudieron identificar los músculos',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: muscles.map((muscle) {
        return MuscleIcon(
          muscleName: muscle,
          isPrimary: isPrimary,
        );
      }).toList(),
    );
  }

  Widget _buildInstructions(String instructions) {
    if (instructions == 'No hay instrucciones disponibles' || 
        instructions == 'No identificado' || 
        instructions == 'No se puede identificar') {
      return Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              FontAwesomeIcons.circleQuestion,
              color: Colors.grey,
              size: 16.r,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'No se pudieron identificar las instrucciones de uso',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Dividir las instrucciones en pasos si es posible
    final steps = instructions.split('. ')
      .where((step) => step.trim().isNotEmpty)
      .toList();
    
    if (steps.length <= 1) {
      // Si no hay múltiples pasos, mostrar como texto normal
      return Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          instructions,
          style: TextStyle(
            fontSize: 14.sp,
            height: 1.5,
          ),
        ),
      );
    }
    
    // Si hay múltiples pasos, mostrar como lista numerada
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  steps[index].trim() + (steps[index].endsWith('.') ? '' : '.'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
