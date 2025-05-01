import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static String get bannerAdUnitId {
    // Usar IDs de prueba solo para desarrollo (debug mode)
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111'; // ID de prueba para Android
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716'; // ID de prueba para iOS
      }
    } else {
      // IDs reales para producción (release mode)
      if (Platform.isAndroid) {
        return 'ca-app-pub-7069024149133209/7168631273'; // ID real del banner
      } else if (Platform.isIOS) {
        return 'ca-app-pub-7069024149133209/7168631273'; // Usando el mismo ID para iOS por ahora
      }
    }
    
    throw UnsupportedError('Plataforma no soportada');
  }

  static String get interstitialAdUnitId {
    // Usar IDs de prueba solo para desarrollo (debug mode)
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712'; // ID de prueba para Android
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910'; // ID de prueba para iOS
      }
    } else {
      // IDs reales para producción (release mode)
      if (Platform.isAndroid) {
        return 'ca-app-pub-7069024149133209/2546859980'; // ID real del intersticial
      } else if (Platform.isIOS) {
        return 'ca-app-pub-7069024149133209/2546859980'; // Usando el mismo ID para iOS por ahora
      }
    }
    
    throw UnsupportedError('Plataforma no soportada');
  }

  // Cargar un banner
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded: ${ad.adUnitId}');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: ${ad.adUnitId}, $error');
          ad.dispose();
        },
        onAdOpened: (ad) => debugPrint('Banner ad opened: ${ad.adUnitId}'),
        onAdClosed: (ad) => debugPrint('Banner ad closed: ${ad.adUnitId}'),
      ),
    );
  }

  // Cargar un anuncio intersticial
  static Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? interstitialAd;
    
    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('Interstitial ad loaded');
            interstitialAd = ad;
          },
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial ad failed to load: $error');
            interstitialAd = null;
          },
        ),
      );
      
      return interstitialAd;
    } catch (e) {
      debugPrint('Error loading interstitial ad: $e');
      return null;
    }
  }
  
  // Variable estática para mantener una referencia al anuncio intersticial
  static InterstitialAd? _interstitialAd;
  
  // Precargar un anuncio intersticial
  static Future<void> preloadInterstitialAd() async {
    debugPrint('Precargando anuncio intersticial con ID: $interstitialAdUnitId');
    
    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('Anuncio intersticial precargado exitosamente');
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (error) {
            debugPrint('Error al precargar anuncio intersticial: ${error.message}, código: ${error.code}');
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('Excepción al precargar anuncio intersticial: $e');
      _interstitialAd = null;
    }
  }
  
  // Mostrar un anuncio intersticial
  static Future<void> showInterstitialAd() async {
    debugPrint('Intentando mostrar anuncio intersticial');
    
    if (_interstitialAd == null) {
      debugPrint('No hay anuncio intersticial precargado, intentando cargar uno nuevo');
      await preloadInterstitialAd();
    }
    
    if (_interstitialAd != null) {
      debugPrint('Anuncio intersticial disponible, mostrando...');
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Anuncio intersticial mostrado completamente');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Anuncio intersticial cerrado por el usuario');
          ad.dispose();
          _interstitialAd = null;
          preloadInterstitialAd(); // Precargar el siguiente anuncio
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Error al mostrar anuncio intersticial: ${error.message}, código: ${error.code}');
          ad.dispose();
          _interstitialAd = null;
          preloadInterstitialAd(); // Intentar precargar otro anuncio
        },
        onAdImpression: (ad) {
          debugPrint('Impresión de anuncio intersticial registrada');
        },
      );
      
      try {
        await _interstitialAd!.show();
      } catch (e) {
        debugPrint('Excepción al mostrar anuncio intersticial: $e');
        _interstitialAd?.dispose();
        _interstitialAd = null;
        preloadInterstitialAd();
      }
    } else {
      debugPrint('No se pudo cargar un anuncio intersticial');
    }
  }
}
