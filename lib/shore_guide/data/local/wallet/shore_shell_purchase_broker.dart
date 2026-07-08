import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'shore_shell_wallet_store.dart';

class ShoreShellPurchaseBroker {
  ShoreShellPurchaseBroker({InAppPurchase? inAppPurchase})
    : _iap = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _iap;
  final ShoreShellWalletStore _walletStore = const ShoreShellWalletStore();
  final Set<String> _pendingProductIds = {};

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  Future<ShoreShellPurchaseStart> startPurchase(ShoreShellParcel parcel) async {
    final available = await _iap.isAvailable();
    if (!available) {
      return const ShoreShellPurchaseStart.storeUnavailable();
    }

    final response = await _iap.queryProductDetails({parcel.productId});
    if (response.notFoundIDs.contains(parcel.productId) ||
        response.productDetails.isEmpty) {
      return ShoreShellPurchaseStart.productMissing(parcel.productId);
    }

    final productDetails = response.productDetails.first;
    _pendingProductIds.add(productDetails.id);
    final param = PurchaseParam(productDetails: productDetails);
    final started = await _iap.buyConsumable(
      purchaseParam: param,
      autoConsume: true,
    );
    if (!started) {
      _pendingProductIds.remove(productDetails.id);
      return ShoreShellPurchaseStart.notStarted(productDetails.price);
    }
    return ShoreShellPurchaseStart.started(productDetails.price);
  }

  Future<ShoreShellPurchaseReceipt?> handlePurchase(
    PurchaseDetails purchase,
  ) async {
    if (purchase.status == PurchaseStatus.error) {
      _pendingProductIds.remove(purchase.productID);
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return ShoreShellPurchaseReceipt.failed(
        message: purchase.error?.message ?? 'Purchase could not be completed.',
      );
    }

    if (purchase.status == PurchaseStatus.canceled) {
      _pendingProductIds.remove(purchase.productID);
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return const ShoreShellPurchaseReceipt.cancelled();
    }

    if (purchase.status != PurchaseStatus.purchased &&
        purchase.status != PurchaseStatus.restored) {
      return null;
    }

    final parcel = _parcelForProduct(purchase.productID);
    if (parcel == null) {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return null;
    }

    final token = _purchaseToken(purchase);
    final isFresh = await _walletStore.markPurchaseIfFresh(token);
    if (isFresh) {
      await _walletStore.creditShells(parcel.shellCount);
    }
    _pendingProductIds.remove(purchase.productID);
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
    return ShoreShellPurchaseReceipt.completed(
      shells: isFresh ? parcel.shellCount : 0,
    );
  }

  ShoreShellParcel? _parcelForProduct(String productId) {
    for (final parcel in ShoreShellWalletStore.parcels) {
      if (parcel.productId == productId) {
        return parcel;
      }
    }
    return null;
  }

  String _purchaseToken(PurchaseDetails purchase) {
    final purchaseId = purchase.purchaseID;
    if (purchaseId != null && purchaseId.isNotEmpty) {
      return '${purchase.productID}:$purchaseId';
    }
    final verification = purchase.verificationData.serverVerificationData;
    return '${purchase.productID}:${verification.hashCode}';
  }
}

class ShoreShellPurchaseStart {
  const ShoreShellPurchaseStart._({
    required this.status,
    required this.priceText,
    required this.message,
  });

  const ShoreShellPurchaseStart.started(String priceText)
    : this._(
        status: ShoreShellPurchaseStartStatus.started,
        priceText: priceText,
        message: '',
      );

  const ShoreShellPurchaseStart.storeUnavailable()
    : this._(
        status: ShoreShellPurchaseStartStatus.storeUnavailable,
        priceText: '',
        message: 'Store is not available right now.',
      );

  const ShoreShellPurchaseStart.productMissing(String productId)
    : this._(
        status: ShoreShellPurchaseStartStatus.productMissing,
        priceText: '',
        message: 'Product $productId is not available in App Store Connect.',
      );

  const ShoreShellPurchaseStart.notStarted(String priceText)
    : this._(
        status: ShoreShellPurchaseStartStatus.notStarted,
        priceText: priceText,
        message: 'Purchase was not started. Please try again.',
      );

  final ShoreShellPurchaseStartStatus status;
  final String priceText;
  final String message;
}

enum ShoreShellPurchaseStartStatus {
  started,
  storeUnavailable,
  productMissing,
  notStarted,
}

class ShoreShellPurchaseReceipt {
  const ShoreShellPurchaseReceipt._({
    required this.status,
    required this.shells,
    required this.message,
  });

  const ShoreShellPurchaseReceipt.completed({required int shells})
    : this._(
        status: ShoreShellPurchaseReceiptStatus.completed,
        shells: shells,
        message: '',
      );

  const ShoreShellPurchaseReceipt.cancelled()
    : this._(
        status: ShoreShellPurchaseReceiptStatus.cancelled,
        shells: 0,
        message: 'Purchase was cancelled.',
      );

  const ShoreShellPurchaseReceipt.failed({required String message})
    : this._(
        status: ShoreShellPurchaseReceiptStatus.failed,
        shells: 0,
        message: message,
      );

  final ShoreShellPurchaseReceiptStatus status;
  final int shells;
  final String message;
}

enum ShoreShellPurchaseReceiptStatus { completed, cancelled, failed }
