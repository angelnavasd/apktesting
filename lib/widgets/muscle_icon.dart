import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/app_theme.dart';

class MuscleIcon extends StatelessWidget {
  final String muscleName;
  final bool isPrimary;

  const MuscleIcon({
    Key? key,
    required this.muscleName,
    this.isPrimary = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isPrimary 
            ? AppTheme.primaryColor.withOpacity(0.1)
            : AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isPrimary 
              ? AppTheme.primaryColor.withOpacity(0.3)
              : AppTheme.accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconForMuscle(muscleName),
            color: isPrimary ? AppTheme.primaryColor : AppTheme.accentColor,
            size: isPrimary ? 18.r : 16.r,
          ),
          SizedBox(width: 6.w),
          Text(
            muscleName,
            style: TextStyle(
              fontSize: isPrimary ? 14.sp : 12.sp,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
              color: isPrimary ? AppTheme.primaryColor : AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForMuscle(String muscle) {
    final lowerMuscle = muscle.toLowerCase();
    
    if (lowerMuscle.contains('cuádriceps') || lowerMuscle.contains('cuadriceps')) {
      return FontAwesomeIcons.personWalking;
    } else if (lowerMuscle.contains('glúteos') || lowerMuscle.contains('gluteos')) {
      return FontAwesomeIcons.personWalking;
    } else if (lowerMuscle.contains('pecho') || lowerMuscle.contains('pectoral')) {
      return FontAwesomeIcons.dumbbell;
    } else if (lowerMuscle.contains('espalda') || lowerMuscle.contains('dorsal')) {
      return FontAwesomeIcons.personSwimming;
    } else if (lowerMuscle.contains('hombro') || lowerMuscle.contains('deltoides')) {
      return FontAwesomeIcons.handFist;
    } else if (lowerMuscle.contains('bíceps') || lowerMuscle.contains('biceps')) {
      return FontAwesomeIcons.handFist;
    } else if (lowerMuscle.contains('tríceps') || lowerMuscle.contains('triceps')) {
      return FontAwesomeIcons.handFist;
    } else if (lowerMuscle.contains('abdominal')) {
      return FontAwesomeIcons.personRunning;
    } else if (lowerMuscle.contains('pantorrilla') || lowerMuscle.contains('gemelos')) {
      return FontAwesomeIcons.personWalking;
    } else if (lowerMuscle.contains('isquiotibiales') || lowerMuscle.contains('femoral')) {
      return FontAwesomeIcons.personWalking;
    }
    
    // Icono por defecto
    return FontAwesomeIcons.dumbbell;
  }
}
