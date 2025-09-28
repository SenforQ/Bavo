import 'package:shared_preferences/shared_preferences.dart';

class CharacterFilterService {
  static const String _blockedKey = 'blocked_characters';
  static const String _blacklistedKey = 'blacklisted_characters';
  static const String _reportedKey = 'reported_characters';

  // 屏蔽角色
  static Future<void> blockCharacter(String characterName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockedList = prefs.getStringList(_blockedKey) ?? [];
      if (!blockedList.contains(characterName)) {
        blockedList.add(characterName);
        await prefs.setStringList(_blockedKey, blockedList);
      }
    } catch (e) {
      // 处理错误
    }
  }

  // 拉黑角色
  static Future<void> blacklistCharacter(String characterName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blacklistedList = prefs.getStringList(_blacklistedKey) ?? [];
      if (!blacklistedList.contains(characterName)) {
        blacklistedList.add(characterName);
        await prefs.setStringList(_blacklistedKey, blacklistedList);
      }
    } catch (e) {
      // 处理错误
    }
  }

  // 举报角色
  static Future<void> reportCharacter(String characterName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportedList = prefs.getStringList(_reportedKey) ?? [];
      if (!reportedList.contains(characterName)) {
        reportedList.add(characterName);
        await prefs.setStringList(_reportedKey, reportedList);
      }
    } catch (e) {
      // 处理错误
    }
  }

  // 获取被屏蔽的角色列表
  static Future<List<String>> getBlockedCharacters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_blockedKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  // 获取被拉黑的角色列表
  static Future<List<String>> getBlacklistedCharacters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_blacklistedKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  // 获取被举报的角色列表
  static Future<List<String>> getReportedCharacters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_reportedKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  // 检查角色是否被屏蔽
  static Future<bool> isCharacterBlocked(String characterName) async {
    final blockedList = await getBlockedCharacters();
    return blockedList.contains(characterName);
  }

  // 检查角色是否被拉黑
  static Future<bool> isCharacterBlacklisted(String characterName) async {
    final blacklistedList = await getBlacklistedCharacters();
    return blacklistedList.contains(characterName);
  }

  // 检查角色是否被举报
  static Future<bool> isCharacterReported(String characterName) async {
    final reportedList = await getReportedCharacters();
    return reportedList.contains(characterName);
  }

  // 取消屏蔽角色
  static Future<void> unblockCharacter(String characterName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockedList = prefs.getStringList(_blockedKey) ?? [];
      blockedList.remove(characterName);
      await prefs.setStringList(_blockedKey, blockedList);
    } catch (e) {
      // 处理错误
    }
  }

  // 取消拉黑角色
  static Future<void> unblacklistCharacter(String characterName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blacklistedList = prefs.getStringList(_blacklistedKey) ?? [];
      blacklistedList.remove(characterName);
      await prefs.setStringList(_blacklistedKey, blacklistedList);
    } catch (e) {
      // 处理错误
    }
  }

  // 过滤角色列表，移除被屏蔽和拉黑的角色
  static Future<List<Map<String, dynamic>>> filterCharacters(List<Map<String, dynamic>> characters) async {
    try {
      final blockedList = await getBlockedCharacters();
      final blacklistedList = await getBlacklistedCharacters();
      
      return characters.where((character) {
        final characterName = character['RavoNickName'] ?? '';
        return !blockedList.contains(characterName) && !blacklistedList.contains(characterName);
      }).toList();
    } catch (e) {
      // 如果过滤失败，返回原始列表
      return characters;
    }
  }
}

