import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_info.dart';

class UserInfoService {
  static const String _userInfoKey = 'user_info';

  // 保存用户信息
  static Future<void> saveUserInfo(UserInfo userInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoJson = jsonEncode(userInfo.toJson());
      await prefs.setString(_userInfoKey, userInfoJson);
    } catch (e) {
      throw Exception('Failed to save user info: $e');
    }
  }

  // 获取用户信息
  static Future<UserInfo> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoJson = prefs.getString(_userInfoKey);
      
      if (userInfoJson != null) {
        final userInfoMap = jsonDecode(userInfoJson) as Map<String, dynamic>;
        return UserInfo.fromJson(userInfoMap);
      } else {
        // 返回默认用户信息
        return UserInfo(
          name: 'Bavo',
          gender: '',
          signature: 'No signature',
          avatarPath: 'assets/user_defalut_icon.webp',
          backgroundPath: 'assets/mine_top_bg.webp',
        );
      }
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  // 保存图片到沙盒
  static Future<String> saveImageToSandbox(File imageFile, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final newFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final newFile = File('${imagesDir.path}/$newFileName');
      await imageFile.copy(newFile.path);
      
      // 返回相对路径：images/filename
      return 'images/$newFileName';
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  // 获取完整图片路径
  static Future<String?> getFullImagePath(String imagePath) async {
    if (imagePath.startsWith('assets/')) {
      return imagePath;
    }
    
    // 如果是相对路径（images/xxx），转换为完整路径
    if (imagePath.startsWith('images/')) {
      final directory = await getApplicationDocumentsDirectory();
      final fullPath = '${directory.path}/$imagePath';
      final file = File(fullPath);
      if (await file.exists()) {
        return fullPath;
      }
    }
    
    // 如果是绝对路径，直接检查
    final file = File(imagePath);
    if (await file.exists()) {
      return imagePath;
    }
    
    return null;
  }
}
