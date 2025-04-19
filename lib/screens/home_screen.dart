import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import '../utils/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/camera_frame.dart';
import '../widgets/capture_button.dart';
import 'machine_analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> cameras = [];
  bool _isCameraPermissionGranted = false;
  bool _isCameraInitialized = false;
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  // Variables de estado para debug visual
  String? _capturedFileName;
  int? _capturedFileSize;
  String? _uploadStatus;
  int _retryCount = 0;
  Map<String, dynamic>? _machineAnalysis;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
    
    // Configurar animación de escaneo
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isCameraPermissionGranted = status.isGranted;
    });
    
    if (status.isGranted) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _isCameraInitialized = false;
        });
        return;
      }

      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error al inicializar la cámara: $e');
      setState(() {
        _isCameraInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scanAnimationController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _capturedFileName = null;
        _capturedFileSize = null;
        _uploadStatus = 'Capturando...';
        _retryCount = 0;
      });

      final XFile image = await _cameraController!.takePicture();
      if (!mounted) return;
      final bytes = await image.readAsBytes();
      final fileName = image.name;
      final safeFileName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      setState(() {
        _capturedFileName = safeFileName;
        _capturedFileSize = bytes.length;
        _uploadStatus = 'Subiendo...';
      });
      
      // Intentar subir con reintentos
      await _uploadWithRetry(safeFileName, bytes);
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error capturando imagen: $e';
      });
    }
  }
  
  // Método para subir con reintentos
  Future<void> _uploadWithRetry(String fileName, Uint8List bytes) async {
    const maxRetries = 3;
    _retryCount = 0;
    
    while (_retryCount < maxRetries) {
      try {
        // Verificar conectividad antes de intentar subir
        bool hasConnection = await _checkInternetConnection();
        if (!hasConnection) {
          setState(() {
            _uploadStatus = 'Sin conexión a Internet. Reintentando (${_retryCount + 1}/$maxRetries)...';
          });
          await Future.delayed(Duration(seconds: 2));
          _retryCount++;
          continue;
        }
        
        setState(() {
          _uploadStatus = 'Subiendo... Intento ${_retryCount + 1}/$maxRetries';
        });
        
        final String fullPath = await Supabase.instance.client.storage
            .from('gym-images')
            .uploadBinary(fileName, bytes);
        
        // Insertar en la tabla gym_images
        final response = await Supabase.instance.client
            .from('gym_images')
            .insert({
              'image_url': fullPath,
              'file_name': fileName,
              'device_info': 'Flutter App',
            })
            .select()
            .single();
            
        final String imageId = response['id'];
        
        setState(() {
          _uploadStatus = 'Subido correctamente. Analizando imagen...';
        });
        
        // Llamar a la Edge Function para analizar la imagen
        await _analyzeImage(imageId, fileName);
        
        setState(() {
          _uploadStatus = 'Subido correctamente: $fullPath';
        });
        return; // Éxito, salir del bucle
      } catch (e) {
        _retryCount++;
        if (_retryCount >= maxRetries) {
          setState(() {
            _uploadStatus = 'Error después de $maxRetries intentos: $e';
          });
        } else {
          setState(() {
            _uploadStatus = 'Error subiendo imagen. Reintentando (${_retryCount}/$maxRetries): $e';
          });
          await Future.delayed(Duration(seconds: 2)); // Esperar antes de reintentar
        }
      }
    }
  }
  
  // Verificar conexión a Internet
  Future<bool> _checkInternetConnection() async {
    try {
      // Intentar una conexión a un servidor conocido
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Método para analizar la imagen con la Edge Function
  Future<void> _analyzeImage(String imageId, String fileName) async {
    try {
      setState(() {
        _uploadStatus = 'Analizando imagen...';
      });
      
      final response = await Supabase.instance.client
          .functions
          .invoke('identify_machine', 
            body: {
              'image_id': imageId,
            }
          );
      
      if (response.status == 200) {
        setState(() {
          _machineAnalysis = response.data['analysis'];
          _uploadStatus = 'Imagen analizada correctamente';
        });
        
        // Navegar a la pantalla de análisis
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MachineAnalysisScreen(
                analysisResult: _machineAnalysis!,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _uploadStatus = 'Error al analizar la imagen: Código ${response.status}';
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error al analizar la imagen: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightColor,
      // AppBar con diseño moderno
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 36.r, showText: false),
            SizedBox(width: 8.w),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Gym',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'Scan',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: AppTheme.primaryColor),
            onPressed: () {
              // Mostrar información de la app
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Acerca de GymScan'),
                  content: Text('GymScan te ayuda a identificar qué músculos trabajas con cada equipo de gimnasio.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      
      body: Column(
        children: [
          SizedBox(height: 16),
          Expanded(
            child: _buildCameraPreview(),
          ),
          // DEBUG: Mostrar info del archivo capturado/subido
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Archivo capturado:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Nombre: ${_capturedFileName ?? "-"}'),
                Text('Tamaño: ${_capturedFileSize != null ? _capturedFileSize.toString() + ' bytes' : "-"}'),
                Text('Estado: ${_uploadStatus ?? "-"}'),
                
                // Mostrar análisis de la máquina si está disponible
                if (_machineAnalysis != null) ...[
                  SizedBox(height: 10),
                  Text('Máquina identificada:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Nombre: ${_machineAnalysis!['machine_name'] ?? "Desconocido"}'),
                  Text('Músculos principales: ${_machineAnalysis!['primary_muscles']?.join(", ") ?? "-"}'),
                  Text('Músculos secundarios: ${_machineAnalysis!['secondary_muscles']?.join(", ") ?? "-"}'),
                ],
              ],
            ),
          ),
          // Espacio expandible para empujar la barra inferior hacia abajo
          const Spacer(),
        ],
      ),
      
      // Barra inferior con el botón de captura
      bottomNavigationBar: Container(
        height: 100.h,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CaptureButton(
              onPressed: _isCameraInitialized ? _captureImage : null,
              isEnabled: _isCameraInitialized,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraPermissionGranted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.camera,
              color: Colors.white.withOpacity(0.7),
              size: 30.r,
            ),
            SizedBox(height: 16.h),
            Text(
              'Se requiere permiso para la cámara',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _requestCameraPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
              ),
              child: Text('Conceder permiso'),
            ),
          ],
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.white,
          size: 40.r,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Vista previa de la cámara
        CameraPreview(_cameraController!),
        
        // Animación de escaneo
        AnimatedBuilder(
          animation: _scanAnimation,
          builder: (context, child) {
            return Positioned(
              top: _scanAnimation.value * 300.h - 2.h,
              left: 0,
              right: 0,
              child: Container(
                height: 2.h,
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
            );
          },
        ),
      ],
    );
  }
}
