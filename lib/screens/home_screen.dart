import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../utils/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/camera_frame.dart';
import '../widgets/capture_button.dart';

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
      // Mostrar efecto de flash
      setState(() {});
      
      final XFile image = await _cameraController!.takePicture();
      
      // Aquí puedes procesar la imagen capturada
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Imagen capturada correctamente',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(12),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error al capturar imagen: $e');
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
          SizedBox(height: 20.h),
          
          // Área de la cámara (cuadrada)
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculamos el tamaño para que sea cuadrado
              final size = constraints.maxWidth * 0.85;
              return Center(
                child: CameraFrame(
                  size: size,
                  isInitialized: _isCameraInitialized,
                  onPermissionRequest: _requestCameraPermission,
                  child: _buildCameraPreview(),
                ),
              );
            }
          ),
          
          // Espacio entre la cámara y el texto
          SizedBox(height: 32.h),
          
          // Texto instructivo con diseño moderno
          GlassmorphicContainer(
            width: 0.9.sw,
            height: 80.h,
            borderRadius: 20,
            blur: 10,
            alignment: Alignment.center,
            border: 1.5,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.3),
                AppTheme.secondaryColor.withOpacity(0.3),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.circleInfo,
                      color: AppTheme.primaryColor,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      'Escanea cualquier equipamento de tu gimnasio para identificar qué músculo trabajas.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.darkColor.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
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
