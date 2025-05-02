import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static String get bannerAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111'; 
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716'; 
      }
    } else {
      if (Platform.isAndroid) {
        return 'ca-app-pub-7069024149133209/7168631273'; 
      } else if (Platform.isIOS) {
        return 'ca-app-pub-7069024149133209/7168631273'; 
      }
    }
    throw UnsupportedError('Plataforma no soportada');
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712'; 
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910'; 
      }
    } else {
      if (Platform.isAndroid) {
        return 'ca-app-pub-7069024149133209/2546859980';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-7069024149133209/2546859980'; 
      }
    }
    
    throw UnsupportedError('Plataforma no soportada');
  }

  static String get interstitialAdUnitId2 {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910'; 
      }
    } else {
      if (Platform.isAndroid) {
        return 'ca-app-pub-7069024149133209/4071662827'; 
      } else if (Platform.isIOS) {
        return 'ca-app-pub-7069024149133209/4071662827'; 
      }
    }
    throw UnsupportedError('Plataforma no soportada');
  }

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
  
  static InterstitialAd? _interstitialAd;
  
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
          preloadInterstitialAd(); 
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Error al mostrar anuncio intersticial: ${error.message}, código: ${error.code}');
          ad.dispose();
          _interstitialAd = null;
          preloadInterstitialAd(); 
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
