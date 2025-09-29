import 'package:shared_preferences/shared_preferences.dart';

class VipService {
  static const String _vipActiveKey = 'vip_active';
  static const String _vipExpiryKey = 'vip_expiry';
  static const String _vipProductIdKey = 'vip_product_id';
  static const String _vipPurchaseDateKey = 'vip_purchase_date';

  /// 激活 VIP
  static Future<void> activateVip({
    required String productId,
    required String purchaseDate,
    int? durationDays,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      
      // 根据产品ID确定VIP时长
      int vipDays = 7; // 默认7天
      if (productId.contains('Week') || productId.contains('week')) {
        vipDays = 7;
      } else if (productId.contains('Month') || productId.contains('month')) {
        vipDays = 30;
      }
      
      // 如果传入了自定义时长，使用自定义时长
      if (durationDays != null) {
        vipDays = durationDays;
      }
      
      final expiryDate = now.add(Duration(days: vipDays));
      
      await prefs.setBool(_vipActiveKey, true);
      await prefs.setString(_vipExpiryKey, expiryDate.toIso8601String());
      await prefs.setString(_vipProductIdKey, productId);
      await prefs.setString(_vipPurchaseDateKey, purchaseDate);
      
      print('VipService - VIP activated: $productId, expires: ${expiryDate.toIso8601String()}');
    } catch (e) {
      print('VipService - Error activating VIP: $e');
      rethrow;
    }
  }

  /// 停用 VIP
  static Future<void> deactivateVip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_vipActiveKey, false);
      await prefs.remove(_vipExpiryKey);
      await prefs.remove(_vipProductIdKey);
      await prefs.remove(_vipPurchaseDateKey);
      
      print('VipService - VIP deactivated');
    } catch (e) {
      print('VipService - Error deactivating VIP: $e');
      rethrow;
    }
  }

  /// 检查 VIP 是否激活
  static Future<bool> isVipActive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_vipActiveKey) ?? false;
    } catch (e) {
      print('VipService - Error checking VIP status: $e');
      return false;
    }
  }

  /// 检查 VIP 是否过期
  static Future<bool> isVipExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString(_vipExpiryKey);
      
      if (expiryString == null) {
        return true; // 没有过期时间，认为已过期
      }
      
      final expiryDate = DateTime.parse(expiryString);
      final now = DateTime.now();
      
      return now.isAfter(expiryDate);
    } catch (e) {
      print('VipService - Error checking VIP expiry: $e');
      return true; // 出错时认为已过期
    }
  }

  /// 获取 VIP 过期时间
  static Future<DateTime?> getVipExpiryDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString(_vipExpiryKey);
      
      if (expiryString == null) {
        return null;
      }
      
      return DateTime.parse(expiryString);
    } catch (e) {
      print('VipService - Error getting VIP expiry date: $e');
      return null;
    }
  }

  /// 获取 VIP 产品 ID
  static Future<String?> getVipProductId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_vipProductIdKey);
    } catch (e) {
      print('VipService - Error getting VIP product ID: $e');
      return null;
    }
  }

  /// 获取 VIP 购买日期
  static Future<String?> getVipPurchaseDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_vipPurchaseDateKey);
    } catch (e) {
      print('VipService - Error getting VIP purchase date: $e');
      return null;
    }
  }

  /// 获取 VIP 剩余天数
  static Future<int> getVipRemainingDays() async {
    try {
      final expiryDate = await getVipExpiryDate();
      if (expiryDate == null) {
        return 0;
      }
      
      final now = DateTime.now();
      final difference = expiryDate.difference(now).inDays;
      
      return difference > 0 ? difference : 0;
    } catch (e) {
      print('VipService - Error getting VIP remaining days: $e');
      return 0;
    }
  }

  /// 检查 VIP 是否有效（激活且未过期）
  static Future<bool> isVipValid() async {
    try {
      final isActive = await isVipActive();
      final isExpired = await isVipExpired();
      
      return isActive && !isExpired;
    } catch (e) {
      print('VipService - Error checking VIP validity: $e');
      return false;
    }
  }
}
