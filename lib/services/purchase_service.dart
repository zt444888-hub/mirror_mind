import 'dart:async';
import 'dart:convert';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._();
  factory PurchaseService() => _instance;
  PurchaseService._();

  static const String _productId = 'mirror_mind_pro';
  static const String _keyIsPro = 'is_pro';
  static const String _keyPendingPurchase = 'pending_purchase';

  final InAppPurchase _iap = InAppPurchase.instance;

  bool _isAvailable = false;
  bool _isPro = false;
  ProductDetails? _productDetails;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  final StreamController<bool> _proStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get proStatusStream => _proStatusController.stream;

  bool get isAvailable => _isAvailable;
  bool get isPro => _isPro;
  ProductDetails? get productDetails => _productDetails;

  static Future<bool> isProStatic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPro) ?? false;
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool(_keyIsPro) ?? false;

    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    final ProductDetailsResponse response =
        await _iap.queryProductDetails({_productId});
    if (response.productDetails.isNotEmpty) {
      _productDetails = response.productDetails.first;
    }

    _purchaseSubscription =
        _iap.purchaseStream.listen(_onPurchaseUpdate);

    // 检查是否有待处理的购买（延迟支付如家长审批）
    await _retryPendingPurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID == _productId) {
        _handlePurchase(purchase);
      }
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        if (!_isPro) {
          await _setPro(true);
          _proStatusController.add(true);
        }
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        // 清除待处理记录
        await _clearPendingPurchase();
        break;
      case PurchaseStatus.pending:
        // 持久化待处理购买信息，下次启动或 Stream 触发时重试
        await _savePendingPurchase(purchase);
        break;
      case PurchaseStatus.error:
        // 购买出错时也清除 pending（不会自动恢复）
        await _clearPendingPurchase();
        break;
      case PurchaseStatus.canceled:
        await _clearPendingPurchase();
        break;
    }
  }

  /// 持久化待处理购买的产品 ID 和时间戳
  Future<void> _savePendingPurchase(PurchaseDetails purchase) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({
      'productId': purchase.productID,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_keyPendingPurchase, data);
  }

  /// 清除待处理购买记录
  Future<void> _clearPendingPurchase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPendingPurchase);
  }

  /// 检查并重试待处理的购买
  Future<void> _retryPendingPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingJson = prefs.getString(_keyPendingPurchase);
    if (pendingJson == null) return;

    try {
      final data = jsonDecode(pendingJson) as Map<String, dynamic>;
      final productId = data['productId'] as String?;
      if (productId == _productId) {
        // 待处理购买存在但未完成，尝试重新发起
        await _iap.restorePurchases();
      }
    } catch (_) {
      await _clearPendingPurchase();
    }
  }

  Future<void> _setPro(bool value) async {
    _isPro = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPro, value);
  }

  /// 发起购买。返回 null 表示成功发起，返回 String 表示具体错误信息。
  Future<String?> buyPro() async {
    if (_productDetails == null) {
      return '产品信息未加载，请检查网络后重试';
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: _productDetails!,
    );

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return null; // 购买请求已发出，结果通过 purchaseStream 异步返回
    } catch (e) {
      return '购买失败：$e';
    }
  }

  /// 恢复购买。最多等待 5 秒，每 500ms 轮询一次 isPro 状态。
  Future<bool> restorePurchases() async {
    if (!_isAvailable) return false;
    try {
      await _iap.restorePurchases();

      // 轮询检查 Pro 状态（Store 回调可能延迟到达）
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getBool(_keyIsPro) ?? false) {
          _isPro = true;
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _purchaseSubscription?.cancel();
    _proStatusController.close();
  }
}
