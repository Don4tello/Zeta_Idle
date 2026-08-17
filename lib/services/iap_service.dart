import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'analytics_service.dart';

class CrystalPackage {
  const CrystalPackage({
    required this.productId,
    required this.zcoins,
    required this.fallbackPrice,
    required this.label,
  });
  final String productId;
  final int zcoins;
  final String fallbackPrice;
  final String label;
}

typedef PurchaseCallback = void Function(String productId, int zcoins);

class IapService {
  IapService(this._onCrystalsGranted,
      {this.onPackPurchased, this.onSubscriptionActivated, this.onPremiumSkinPurchased,
       this.onCosmeticPurchased});

  final void Function(int) _onCrystalsGranted;
  final void Function(String)? onPackPurchased;
  final void Function(String, int)? onSubscriptionActivated;
  final void Function(String)? onPremiumSkinPurchased;
  final void Function(String)? onCosmeticPurchased; // real-money cosmetics
  StreamSubscription<List<PurchaseDetails>>? _sub;
  final Map<String, ProductDetails> _products = {};
  bool _storeAvailable = false;

  static const packages = [
    CrystalPackage(productId: 'crystals_100',  zcoins: 100,  fallbackPrice: '\$0.99',  label: '100 ZCoins'),
    CrystalPackage(productId: 'crystals_550',  zcoins: 550,  fallbackPrice: '\$3.99',  label: '550 ZCoins  (+10%)'),
    CrystalPackage(productId: 'crystals_1200', zcoins: 1200, fallbackPrice: '\$7.99',  label: '1,200 ZCoins  (+20%)'),
    CrystalPackage(productId: 'crystals_3000', zcoins: 3000, fallbackPrice: '\$14.99', label: '3,000 ZCoins  (+50%)'),
  ];

  static const _allProductIds = {
    // Consumables (zcoins)
    'crystals_100', 'crystals_550', 'crystals_1200', 'crystals_3000',
    // Non-consumables (packs)
    'pack_starter', 'pack_hero', 'pack_legend',
    // Premium class skins ($4.99 each, non-consumable)
    'skin_premium_barbarian', 'skin_premium_bard', 'skin_premium_cleric',
    'skin_premium_druid', 'skin_premium_fighter', 'skin_premium_monk',
    'skin_premium_ranger', 'skin_premium_rogue', 'skin_premium_sorcerer',
    'skin_premium_warlock', 'skin_premium_wizard', 'skin_premium_paladin',
    // Real-money exclusive cosmetics (non-consumable)
    'cosmetic_frame_eclipse', 'cosmetic_name_prismatic', 'cosmetic_title_eternal',
    // Subscriptions
    'sub_speed_monthly', 'sub_premium_monthly',
  };

  static bool get platformSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  bool get storeAvailable => _storeAvailable;

  String priceFor(String productId) =>
      _products[productId]?.price ?? '';

  Future<void> init() async {
    if (!platformSupported) return;
    try {
      _storeAvailable = await InAppPurchase.instance.isAvailable();
      if (!_storeAvailable) return;

      _sub = InAppPurchase.instance.purchaseStream.listen(
        _handlePurchases,
        onError: (_) {},
      );

      final result = await InAppPurchase.instance.queryProductDetails(_allProductIds);
      for (final pd in result.productDetails) {
        _products[pd.id] = pd;
      }
    } catch (_) {
      _storeAvailable = false;
    }
  }

  void _handlePurchases(List<PurchaseDetails> list) {
    for (final p in list) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        _fulfillPurchase(p.productID);
        if (p.pendingCompletePurchase) {
          InAppPurchase.instance.completePurchase(p);
        }
      }
    }
  }

  void _fulfillPurchase(String productId) {
    // Visible in `adb logcat | grep flutter` — confirms fulfillment fired.
    debugPrint('[IAP] fulfill: $productId');
    AnalyticsService.instance.iapPurchase(productId);
    // Crystal consumables
    final pkg = packages.where((p) => p.productId == productId).firstOrNull;
    if (pkg != null) {
      _onCrystalsGranted(pkg.zcoins);
      return;
    }

    // Starter packs
    if (productId.startsWith('pack_')) {
      onPackPurchased?.call(productId);
      return;
    }

    // Premium class skins — productId 'skin_<skinId>' → skinId 'premium_<class>'
    if (productId.startsWith('skin_')) {
      onPremiumSkinPurchased?.call(productId.substring('skin_'.length));
      return;
    }

    // Real-money exclusive cosmetics (frame / name colour / title)
    if (productId.startsWith('cosmetic_')) {
      onCosmeticPurchased?.call(productId);
      return;
    }

    // Subscriptions
    if (productId == 'sub_speed_monthly') {
      onSubscriptionActivated?.call(productId, 30);
      return;
    }
    if (productId == 'sub_premium_monthly') {
      onSubscriptionActivated?.call(productId, 30);
      return;
    }
  }

  Future<void> buyConsumable(String productId) async {
    if (!_storeAvailable) return;
    final pd = _products[productId];
    if (pd == null) {
      if (kDebugMode) _fulfillPurchase(productId);
      return;
    }
    await InAppPurchase.instance
        .buyConsumable(purchaseParam: PurchaseParam(productDetails: pd));
  }

  Future<void> buyNonConsumable(String productId) async {
    if (!_storeAvailable) return;
    final pd = _products[productId];
    if (pd == null) {
      if (kDebugMode) _fulfillPurchase(productId);
      return;
    }
    await InAppPurchase.instance
        .buyNonConsumable(purchaseParam: PurchaseParam(productDetails: pd));
  }

  Future<void> restorePurchases() async {
    if (!_storeAvailable) return;
    await InAppPurchase.instance.restorePurchases();
  }

  void dispose() {
    _sub?.cancel();
  }
}
