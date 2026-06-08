import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:in_app_purchase/in_app_purchase.dart';

class CrystalPackage {
  const CrystalPackage({
    required this.productId,
    required this.crystals,
    required this.fallbackPrice,
    required this.label,
  });
  final String productId;
  final int crystals;
  final String fallbackPrice; // shown when store query fails
  final String label;         // e.g. "100 Crystals"
}

class IapService {
  IapService(this._onCrystalsGranted);

  final void Function(int) _onCrystalsGranted;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  final Map<String, ProductDetails> _products = {};
  bool _storeAvailable = false;

  static const packages = [
    CrystalPackage(
      productId: 'crystals_100',
      crystals: 100,
      fallbackPrice: '\$0.99',
      label: '100 Crystals',
    ),
    CrystalPackage(
      productId: 'crystals_550',
      crystals: 550,
      fallbackPrice: '\$4.99',
      label: '550 Crystals  (+10%)',
    ),
    CrystalPackage(
      productId: 'crystals_1200',
      crystals: 1200,
      fallbackPrice: '\$9.99',
      label: '1200 Crystals  (+20%)',
    ),
  ];

  // IAP is only available on App Store / Google Play, not Windows.
  static bool get platformSupported =>
      !kIsWeb &&
      (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  bool get storeAvailable => _storeAvailable;

  Future<void> init() async {
    if (!platformSupported) return;
    _storeAvailable = await InAppPurchase.instance.isAvailable();
    if (!_storeAvailable) return;

    _sub = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchases,
      onError: (_) {},
    );

    final result = await InAppPurchase.instance.queryProductDetails(
      packages.map((p) => p.productId).toSet(),
    );
    for (final pd in result.productDetails) {
      _products[pd.id] = pd;
    }
  }

  void _handlePurchases(List<PurchaseDetails> list) {
    for (final p in list) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        final pkg = packages.firstWhere(
          (pkg) => pkg.productId == p.productID,
          orElse: () => const CrystalPackage(
              productId: '', crystals: 0, fallbackPrice: '', label: ''),
        );
        if (pkg.crystals > 0) _onCrystalsGranted(pkg.crystals);
        if (p.pendingCompletePurchase) {
          InAppPurchase.instance.completePurchase(p);
        }
      }
    }
  }

  Future<void> buy(String productId) async {
    if (!_storeAvailable) return;
    final pd = _products[productId];
    if (pd == null) return;
    await InAppPurchase.instance
        .buyConsumable(purchaseParam: PurchaseParam(productDetails: pd));
  }

  // Dev-mode only: grant crystals without a real purchase.
  void devGrant(int amount) {
    if (!kDebugMode) return;
    _onCrystalsGranted(amount);
  }

  void dispose() => _sub?.cancel();
}
