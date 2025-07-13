import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';

class AdService {
  InterstitialAd? _interstitialAd;
  int _adLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;
  bool _isAdLoaded = false;

  // Usar IDs de prueba de AdMob
  static final String interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-6292269650358396/7247054686'
      : 'ca-app-pub-3940256099942544/4411468910';

  final Random _random = Random();
  int _callCount = 0;

  bool shouldShowAd() {
    // 1 de cada 2 veces (50%)
    final shouldShow = _random.nextInt(2) == 0;
    print('AdService: shouldShowAd() called, result: $shouldShow');
    return shouldShow;
  }

  void loadInterstitialAd() {
    print('AdService: Loading interstitial ad...');
    print('AdService: Using ad unit ID: $interstitialAdUnitId');

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('AdService: Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _adLoadAttempts = 0; // Resetear intentos en carga exitosa
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('AdService: Failed to load interstitial ad: ${error.message}');
          print('AdService: Error code: ${error.code}');
          print('AdService: Error domain: ${error.domain}');
          _adLoadAttempts++;
          _interstitialAd = null;
          _isAdLoaded = false;
          if (_adLoadAttempts <= maxFailedLoadAttempts) {
            print(
                'AdService: Retrying to load ad (attempt $_adLoadAttempts/$maxFailedLoadAttempts)');
            loadInterstitialAd(); // Reintentar
          } else {
            print('AdService: Max load attempts reached, giving up');
          }
        },
      ),
    );
  }

  void showInterstitialAd({required Function onAdDismissed}) {
    print('AdService: showInterstitialAd() called');
    print('AdService: _interstitialAd is null: ${_interstitialAd == null}');
    print('AdService: _isAdLoaded: $_isAdLoaded');

    if (_interstitialAd == null) {
      print('AdService: No ad available, calling onAdDismissed directly');
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
