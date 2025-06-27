import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';

class AdService {
  InterstitialAd? _interstitialAd;
  int _adLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;

  // Usar IDs de prueba de AdMob
  static final String interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  final Random _random = Random();
  int _callCount = 0;

  bool shouldShowAd() {
    // 2 de cada 5 veces (40%)
    return _random.nextInt(5) < 2;
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _adLoadAttempts = 0; // Resetear intentos en carga exitosa
        },
        onAdFailedToLoad: (LoadAdError error) {
          _adLoadAttempts++;
          _interstitialAd = null;
          if (_adLoadAttempts <= maxFailedLoadAttempts) {
            loadInterstitialAd(); // Reintentar
          }
        },
      ),
    );
  }

  void showInterstitialAd({required Function onAdDismissed}) {
    if (_interstitialAd == null) {
      onAdDismissed();
      loadInterstitialAd(); // Cargar para la proxima vez
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        onAdDismissed();
        loadInterstitialAd(); // Pre-cargar el siguiente
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        onAdDismissed();
        loadInterstitialAd(); // Pre-cargar el siguiente
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null; // El anuncio solo se puede usar una vez
  }
}
