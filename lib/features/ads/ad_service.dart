import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  int _adLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;
  bool _isAdLoaded = false;

  // IDs de anuncios - distinción entre desarrollo y producción
  static final String interstitialAdUnitId = _getAdUnitId();

  static String _getAdUnitId() {
    if (kDebugMode) {
      // IDs de PRUEBA de Google AdMob
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Android Test
          : 'ca-app-pub-3940256099942544/4411468910'; // iOS Test
    } else {
      // ID de PRODUCCIÓN - Interstitial Ad
      return 'ca-app-pub-6292269650358396/4481436641';
    }
  }

  final Random _random = Random();

  bool shouldShowAd() {
    // 1 de cada 2 veces (50%) - pero siempre mostrar en debug para testing
    final shouldShow = kDebugMode ? true : (_random.nextInt(2) == 0);
    print(
        'AdService: shouldShowAd() called, result: $shouldShow (Debug mode: $kDebugMode)');
    return shouldShow;
  }

  void loadInterstitialAd() {
    final environment = kDebugMode ? 'DESARROLLO (PRUEBA)' : 'PRODUCCIÓN';
    print('AdService: 🔄 Loading interstitial ad...');
    print('AdService: Environment: $environment');
    print('AdService: Using ad unit ID: $interstitialAdUnitId');
    print('AdService: Platform: ${Platform.isAndroid ? 'Android' : 'iOS'}');
    print('AdService: kDebugMode: $kDebugMode');

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('AdService: ✅ Interstitial ad loaded successfully');
          print('AdService: Ad unit ID: $interstitialAdUnitId');
          _interstitialAd = ad;
          _adLoadAttempts = 0; // Resetear intentos en carga exitosa
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print(
              'AdService: ❌ Failed to load interstitial ad: ${error.message}');
          print('AdService: Error code: ${error.code}');
          print('AdService: Error domain: ${error.domain}');
          print('AdService: Ad unit ID: $interstitialAdUnitId');
          _adLoadAttempts++;
          _interstitialAd = null;
          _isAdLoaded = false;
          if (_adLoadAttempts <= maxFailedLoadAttempts) {
            print(
                'AdService: 🔄 Retrying to load ad (attempt $_adLoadAttempts/$maxFailedLoadAttempts)');
            loadInterstitialAd(); // Reintentar
          } else {
            print('AdService: ⛔ Max load attempts reached, giving up');
          }
        },
      ),
    );
  }

  void showInterstitialAd({required Function onAdDismissed}) {
    print('AdService: 🎯 showInterstitialAd() called');
    print('AdService: _interstitialAd is null: ${_interstitialAd == null}');
    print('AdService: _isAdLoaded: $_isAdLoaded');
    print(
        'AdService: Environment: ${kDebugMode ? 'DESARROLLO' : 'PRODUCCIÓN'}');

    if (_interstitialAd == null) {
      print('AdService: ⚠️ No ad available, calling onAdDismissed directly');
      onAdDismissed();
      loadInterstitialAd(); // Cargar para la proxima vez
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('AdService: Ad dismissed by user');
        ad.dispose();
        onAdDismissed();
        loadInterstitialAd(); // Pre-cargar el siguiente
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('AdService: Failed to show ad: ${error.message}');
        print('AdService: Error code: ${error.code}');
        print('AdService: Error domain: ${error.domain}');
        ad.dispose();
        onAdDismissed();
        loadInterstitialAd(); // Pre-cargar el siguiente
      },
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        print('AdService: Ad showed successfully');
      },
    );

    print('AdService: Showing interstitial ad');
    _interstitialAd!.show();
    _interstitialAd = null; // El anuncio solo se puede usar una vez
    _isAdLoaded = false;
  }

  bool get isAdLoaded => _isAdLoaded;
}
