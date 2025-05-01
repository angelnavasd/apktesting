import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'dart:typed_data';

import '../utils/app_theme.dart';
import '../utils/app_localizations.dart';
import '../utils/ad_manager.dart';
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
  BannerAd? _bannerAd;
  
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
    
    _loadBannerAd();
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
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Configurar opciones de la cámara
      await _cameraController!.initialize();
      
      // Desactivar el flash
      await _cameraController!.setFlashMode(FlashMode.off);
      
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
    _bannerAd?.dispose();
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
        _uploadStatus = AppLocalizations.of(context).get('capturing');
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
        _uploadStatus = AppLocalizations.of(context).get('uploadingImage');
      });
      
      // Intentar subir con reintentos
      await _uploadWithRetry(safeFileName, bytes);
    } catch (e) {
      setState(() {
        _uploadStatus = '${AppLocalizations.of(context).get('errorCapturing')}: $e';
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
            _uploadStatus = '${AppLocalizations.of(context).get('noInternet')}. Reintentando (${_retryCount + 1}/$maxRetries)...';
          });
          await Future.delayed(Duration(seconds: 2));
          _retryCount++;
          continue;
        }
        
        setState(() {
          _uploadStatus = '${AppLocalizations.of(context).get('uploading')}. Intento ${_retryCount + 1}/$maxRetries';
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
          _uploadStatus = '${AppLocalizations.of(context).get('uploadedCorrectly')}. Analizando imagen...';
        });
        
        // Llamar a la Edge Function para analizar la imagen
        await _analyzeImage(imageId, fileName);
        
        return; // Éxito, salir del bucle
      } catch (e) {
        _retryCount++;
        if (_retryCount >= maxRetries) {
          setState(() {
            _uploadStatus = '${AppLocalizations.of(context).get('errorAfterRetries')}: $e';
          });
        } else {
          setState(() {
            _uploadStatus = '${AppLocalizations.of(context).get('errorUploading')}. Reintentando (${_retryCount}/$maxRetries): $e';
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
        _uploadStatus = '${AppLocalizations.of(context).get('analyzing')}.';
      });
      final currentLanguage = Localizations.localeOf(context).languageCode;
      final res = await Supabase.instance.client.functions.invoke(
        'backend', 
        body: {
          'name': 'Functions',
          'image_id': imageId,
          'language': currentLanguage, // Enviar el idioma detectado
        }
      );
      final data = res.data;
      
      if (res.status == 200) {
        // Actualizar el estado ANTES de navegar para limpiar el loader y habilitar el botón
        setState(() {
          _machineAnalysis = data['analysis'];
          _uploadStatus = null;
          _capturedFileName = null;
          _capturedFileSize = null;
          _retryCount = 0;
        });
        
        // Navegar a la pantalla de análisis y esperar el resultado
        if (mounted && _machineAnalysis != null) {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => MachineAnalysisScreen(
                analysisResult: _machineAnalysis!,
              ),
            ),
          );
          
          // Al volver de la pantalla de análisis, siempre limpiar el estado
          if (mounted) {
            setState(() {
              // Forzar un rebuild completo y establecer todo a null
              _uploadStatus = null;
              _capturedFileName = null;
              _capturedFileSize = null;
              _retryCount = 0;
              _machineAnalysis = null;
            });
          }
        }
      } else {
        setState(() {
          _uploadStatus = '${AppLocalizations.of(context).get('errorAnalyzing')}: Código ${res.status}';
        });
        
        // Después de un error, esperar 3 segundos y limpiar el estado
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          setState(() {
            _uploadStatus = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _uploadStatus = '${AppLocalizations.of(context).get('errorAnalyzing')}: $e';
      });
      
      // Después de un error, esperar 3 segundos y limpiar el estado
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _uploadStatus = null;
        });
      }
    }
  }

  Color _getStatusColor() {
    if (_uploadStatus == null || _uploadStatus!.isEmpty) return Colors.grey;
    if (_uploadStatus!.startsWith('${AppLocalizations.of(context).get('error')}')) return Colors.redAccent;
    if (_uploadStatus!.startsWith('${AppLocalizations.of(context).get('uploadedCorrectly')}')) return Colors.green;
    return Colors.blueAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true, // Permite que el cuerpo se extienda detrás del AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppLogo(size: 30.h, showText: false),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.circleInfo, size: 24.r, color: Colors.white),
            tooltip: 'Info',
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: _InfoDialog(),
                ),
              );
            },
          ),
        ],
      ),
      
      // El cuerpo ahora es simplemente el visor de la cámara a pantalla completa
      body: Stack(
        children: [
          // Visor de cámara a pantalla completa
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: _buildCameraPreview(),
          ),
          
          // Loader centrado (solo visible durante el proceso de análisis, NO cuando está completo)
          if (_uploadStatus != null)
            Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 50,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      AppLocalizations.of(context)!.analyzing,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          // Botón de captura flotante en la parte inferior
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: CaptureButton(
                onPressed: (_isCameraInitialized && _uploadStatus == null) 
                  ? _captureImage 
                  : null,
                isEnabled: _isCameraInitialized && _uploadStatus == null,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _bannerAd != null ? _bannerAd!.size.height.toDouble() : 50,
              color: Colors.transparent,
              child: _bannerAd != null 
                ? AdWidget(ad: _bannerAd!) 
                : const Center(
                    child: SizedBox(
                      height: 50,
                      child: Text('', 
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
            ),
          ),
        ],
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
              AppLocalizations.of(context)!.cameraPermissionRequired,
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
              child: Text(AppLocalizations.of(context)!.grantPermission),
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
    
    // Vista previa de la cámara a pantalla completa
    return Container(
      color: Colors.black,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _cameraController!.value.previewSize!.height,
            height: _cameraController!.value.previewSize!.width,
            child: CameraPreview(_cameraController!),
          ),
        ),
      ),
    );
  }

  void _loadBannerAd() {
    debugPrint('Intentando cargar banner ad con ID: ${AdManager.bannerAdUnitId}');
    
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad cargado exitosamente');
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Error al cargar banner ad: ${error.message}, código: ${error.code}');
          ad.dispose();
          _bannerAd = null;
          
          // Reintentar cargar el anuncio después de un tiempo
          Future.delayed(const Duration(minutes: 1), () {
            if (mounted) {
              _loadBannerAd();
            }
          });
        },
        onAdOpened: (ad) => debugPrint('Banner ad abierto'),
        onAdClosed: (ad) => debugPrint('Banner ad cerrado'),
        onAdImpression: (ad) => debugPrint('Banner ad impresión registrada'),
      ),
    );
    _bannerAd!.load();
  }
}

class _InfoDialog extends StatefulWidget {
  @override
  State<_InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<_InfoDialog> {
  int _step = 0; // 0: botones, 1: Politicas, 2: Terminos

  Widget _buildArrowButton({required String text, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward, size: 28, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _step == 0
            ? Container(
                width: 340,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black, size: 28),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: loc.locale.languageCode == 'es' ? 'Cerrar' : 'Close',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildArrowButton(
                      text: loc.locale.languageCode == 'es' ? 'Políticas y privacidad' : 'Privacy Policy',
                      onTap: () => setState(() => _step = 1),
                    ),
                    _buildArrowButton(
                      text: loc.locale.languageCode == 'es' ? 'Términos y condiciones' : 'Terms and Conditions',
                      onTap: () => setState(() => _step = 2),
                    ),
                  ],
                ),
              )
            : Container(
                width: 440,
                height: 620,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              _step == 1 ? loc.infoDialog_privacyTitle : loc.infoDialog_termsTitle,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.left,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              maxLines: null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black, size: 28),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: loc.locale.languageCode == 'es' ? 'Cerrar' : 'Close',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _step == 1 ? loc.infoDialog_privacyText : loc.infoDialog_termsText,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => setState(() => _step = 0),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          loc.locale.languageCode == 'es' ? 'Volver' : 'Back',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
