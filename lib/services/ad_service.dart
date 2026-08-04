import 'dart:async' show Completer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  RewardedAd? _rewardedAd;
  bool _isLoaded = false;

  // ── Ad Unit IDs ────────────────────────────────────────────────────────────
  // Google's test IDs — always fill during development / internal testing.
  // Replace _realRewardedId* with your actual AdMob rewarded ad unit IDs
  // (create them in AdMob console → your app → Ad units → Rewarded).
  static const _testRewardedIdAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const _testRewardedIdIOS     = 'ca-app-pub-3940256099942544/1712485313';
  // TODO: replace with your real rewarded ad unit IDs from AdMob console
  static const _realRewardedIdAndroid = 'ca-app-pub-4594124599183133/6798234837';
  static const _realRewardedIdIOS     = 'ca-app-pub-4594124599183133/REPLACE_ME';

  String get _adUnitId {
    final real = Platform.isAndroid ? _realRewardedIdAndroid : _realRewardedIdIOS;
    // Fall back to test IDs when real IDs haven't been configured yet
    if (kDebugMode || real.contains('REPLACE_ME')) {
      return Platform.isAndroid ? _testRewardedIdAndroid : _testRewardedIdIOS;
    }
    return real;
  }

  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get isLoaded => _isLoaded;

  static Future<void> initialize() async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    // Gather UMP (GDPR/EEA) consent BEFORE initialising ads. Required by
    // AdMob policy; without it EEA/UK users get no consent prompt and ads may
    // be withheld. Best-effort — any failure falls through to ad init so
    // non-EEA users are never blocked from ads.
    await _gatherConsent();
    await MobileAds.instance.initialize();
    instance.loadRewardedAd();
  }

  /// Request the latest consent info and show the consent form if the user's
  /// region (EEA/UK) requires it. Safe to call on every launch — the SDK only
  /// shows the form when needed.
  static Future<void> _gatherConsent() async {
    try {
      final params = ConsentRequestParameters();
      final completer = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          } catch (_) {}
          if (!completer.isCompleted) completer.complete();
        },
        (_) { if (!completer.isCompleted) completer.complete(); },
      );
      await completer.future;
    } catch (_) {
      // Never block ad init on a consent failure.
    }
  }

  void loadRewardedAd() {
    if (!isSupported) return;
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoaded = false;
          // Retry after a short delay
          Future.delayed(const Duration(seconds: 30), loadRewardedAd);
        },
      ),
    );
  }

  Future<void> showRewardedAd({
    required void Function() onRewarded,
    required void Function() onFailed,
  }) async {
    if (!isSupported) {
      // Windows/desktop: simulate a 3-second ad for testing
      await Future.delayed(const Duration(seconds: 3));
      onRewarded();
      return;
    }

    if (_rewardedAd == null) {
      onFailed();
      loadRewardedAd(); // try to load for next time
      return;
    }

    bool rewarded = false;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isLoaded = false;
        loadRewardedAd();
        // Check reward only after the ad closes — onUserEarnedReward fires
        // just before dismiss, so rewarded is already true by this point.
        if (rewarded) onRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isLoaded = false;
        onFailed();
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (_, __) => rewarded = true,
    );
  }
}
