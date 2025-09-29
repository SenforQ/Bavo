import 'package:shared_preferences/shared_preferences.dart';

class CoinService {
  static const String _coinsKey = 'user_coins';
  static const String _isNewUserKey = 'is_new_user';
  static const int welcomeBonus = 100; // 新用户欢迎金币数量

  /// 获取当前金币数量
  static Future<int> getCurrentCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coins = prefs.getInt(_coinsKey);
      
      // 如果金币为 null，说明是首次使用，给用户 100 金币
      if (coins == null) {
        await prefs.setInt(_coinsKey, 100);
        return 100;
      }
      
      return coins;
    } catch (e) {
      print('Error getting current coins: $e');
      return 100; // 出错时也返回 100 金币
    }
  }

  /// 添加金币
  static Future<bool> addCoins(int coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCoins = await getCurrentCoins();
      final newTotal = currentCoins + coins;
      await prefs.setInt(_coinsKey, newTotal);
      return true;
    } catch (e) {
      print('Error adding coins: $e');
      return false;
    }
  }

  /// 消费金币
  static Future<bool> spendCoins(int coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCoins = await getCurrentCoins();
      
      if (currentCoins < coins) {
        return false; // 金币不足
      }
      
      final newTotal = currentCoins - coins;
      await prefs.setInt(_coinsKey, newTotal);
      return true;
    } catch (e) {
      print('Error spending coins: $e');
      return false;
    }
  }

  /// 设置金币数量
  static Future<bool> setCoins(int coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_coinsKey, coins);
      return true;
    } catch (e) {
      print('Error setting coins: $e');
      return false;
    }
  }

  /// 检查是否为新用户
  static Future<bool> isNewUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !prefs.containsKey(_isNewUserKey);
    } catch (e) {
      print('Error checking if new user: $e');
      return false;
    }
  }

  /// 标记用户已不是新用户
  static Future<bool> markUserAsExisting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isNewUserKey, false);
      return true;
    } catch (e) {
      print('Error marking user as existing: $e');
      return false;
    }
  }

  /// 为新用户初始化金币
  static Future<bool> initializeNewUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 检查是否已经初始化过
      if (prefs.containsKey(_isNewUserKey)) {
        return false; // 已经初始化过了
      }
      
      // 给新用户发放欢迎金币
      await prefs.setInt(_coinsKey, welcomeBonus);
      await prefs.setBool(_isNewUserKey, false);
      
      return true;
    } catch (e) {
      print('Error initializing new user: $e');
      return false;
    }
  }

  /// 重置用户数据（用于测试）
  static Future<bool> resetUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_coinsKey);
      await prefs.remove(_isNewUserKey);
      return true;
    } catch (e) {
      print('Error resetting user data: $e');
      return false;
    }
  }

  /// 获取欢迎金币数量
  static int get welcomeBonusAmount => welcomeBonus;
}
