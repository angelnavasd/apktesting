import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? 
           AppLocalizations(const Locale('es'));
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = AppLocalizationsDelegate();
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Textos generales
      'appTitle': 'GymScan',
      
      // Home Screen
      'scanButton': 'Scan Machine',
      'analyzing': 'Analyzing...',
      'uploadingImage': 'Uploading image...',
      'retrying': 'Retrying...',
      'errorCapturing': 'Error capturing image',
      'errorUploading': 'Error uploading image',
      'errorAnalyzing': 'Error analyzing image',
      'noConnection': 'No internet connection',
      'uploadingAttempt': 'Uploading... Attempt',
      'uploadSuccess': 'Successfully uploaded. Analyzing image...',
      'errorAfterAttempts': 'Error after attempts',
      'of': 'of',
      'capturing': 'Capturing...',
      'cameraPermissionRequired': 'Camera permission is required',
      'grantPermission': 'Grant permission',
      'cameraInitializing': 'Initializing camera...',
      'noInternet': 'No internet connection',
      'uploading': 'Uploading',
      'uploadedCorrectly': 'Successfully uploaded',
      'errorAfterRetries': 'Error after retries',
      'error': 'Error',
      'capture': 'Capture',
      
      // Machine Analysis Screen
      'mainMuscles': 'Main Muscles',
      'secondaryMuscles': 'Secondary Muscles',
      'instructions': 'Instructions',
      'backButton': 'Back to Camera',
      'noResults': 'No results available',
      'machineAnalysis': 'Machine Analysis',
      'machineName': 'Machine Name',
      'basicInstructions': 'Basic Usage Instructions',
      'detailedMachineInfo': 'Detailed information about the machine and its correct usage',
      'back': 'Back',
      
      // Splash Screen
      'loading': 'Loading...',
      'welcomeMessage': 'Welcome to GymScan',
      'appDescription': 'Identify gym machines and get exercise instructions',
      'identify_muscles': 'Identify the muscles you work',
      'loading_camera': 'Preparing camera...',
    },
    'es': {
      // Textos generales
      'appTitle': 'GymScan',
      
      // Home Screen
      'scanButton': 'Escanear Máquina',
      'analyzing': 'Analizando...',
      'uploadingImage': 'Subiendo imagen...',
      'retrying': 'Reintentando...',
      'errorCapturing': 'Error capturando imagen',
      'errorUploading': 'Error subiendo imagen',
      'errorAnalyzing': 'Error analizando imagen',
      'noConnection': 'Sin conexión a Internet',
      'uploadingAttempt': 'Subiendo... Intento',
      'uploadSuccess': 'Subido correctamente. Analizando imagen...',
      'errorAfterAttempts': 'Error después de intentos',
      'of': 'de',
      'capturing': 'Capturando...',
      'cameraPermissionRequired': 'Se requiere permiso de cámara',
      'grantPermission': 'Otorgar permiso',
      'cameraInitializing': 'Inicializando cámara...',
      'noInternet': 'Sin conexión a Internet',
      'uploading': 'Subiendo',
      'uploadedCorrectly': 'Subido correctamente',
      'errorAfterRetries': 'Error después de reintentos',
      'error': 'Error',
      'capture': 'Capturar',
      
      // Machine Analysis Screen
      'mainMuscles': 'Músculos principales',
      'secondaryMuscles': 'Músculos secundarios',
      'instructions': 'Instrucciones',
      'backButton': 'Volver a la Cámara',
      'noResults': 'No hay resultados disponibles',
      'machineAnalysis': 'Análisis de Máquina',
      'machineName': 'Nombre de la Máquina',
      'basicInstructions': 'Instrucciones básicas de uso',
      'detailedMachineInfo': 'Información detallada sobre la máquina y su uso correcto',
      'back': 'Volver',
      
      // Splash Screen
      'loading': 'Cargando...',
      'welcomeMessage': 'Bienvenido a GymScan',
      'appDescription': 'Identifica máquinas de gimnasio y obtén instrucciones de ejercicios',
      'identify_muscles': 'Identifica los músculos que trabajas',
      'loading_camera': 'Preparando cámara...',
    },
  };
  
  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['es']?[key] ?? 
           key;
  }
  
  // Getters para acceder directamente a las traducciones
  String get analyzing => get('analyzing');
  String get cameraPermissionRequired => get('cameraPermissionRequired');
  String get grantPermission => get('grantPermission');
  String get machineName => get('machineName');
  String get mainMuscles => get('mainMuscles');
  String get secondaryMuscles => get('secondaryMuscles');
  String get basicInstructions => get('basicInstructions');
  String get machineAnalysis => get('machineAnalysis');
  String get detailedMachineInfo => get('detailedMachineInfo');
  String get back => get('back');
  String get noInternet => get('noInternet');
  String get uploading => get('uploading');
  String get uploadedCorrectly => get('uploadedCorrectly');
  String get errorAfterRetries => get('errorAfterRetries');
  String get error => get('error');
  String get capture => get('capture');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }
  
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
