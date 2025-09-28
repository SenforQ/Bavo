import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_info.dart';
import '../services/user_info_service.dart';
import '../widgets/ios_alert.dart';

class SettingPage extends StatefulWidget {
  final Function(String name, String signature, String gender, String avatarPath, String backgroundPath)? onUserInfoUpdated;
  
  const SettingPage({super.key, this.onUserInfoUpdated});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController _nameController = TextEditingController(text: 'Bavo');
  final TextEditingController _signatureController = TextEditingController(text: 'No signature');
  String _selectedGender = '';
  String _avatarPath = 'assets/user_defalut_icon.webp';
  String _backgroundPath = 'assets/mine_top_bg.webp';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await UserInfoService.getUserInfo();
      if (mounted) {
        setState(() {
          _nameController.text = userInfo.name;
          _signatureController.text = userInfo.signature;
          _selectedGender = userInfo.gender;
          _avatarPath = userInfo.avatarPath;
          _backgroundPath = userInfo.backgroundPath;
        });
      }
    } catch (e) {
      if (mounted) {
        IOSAlert.showError(context, 'Error loading user info: $e');
      }
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/base_bg.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // AppBar
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // 平衡左侧按钮
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Avatar Section
                    const Text(
                      'Avatar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF80FED6),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _buildAvatarImage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Background Section
                    const Text(
                      'Background',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickBackground,
                      child: Container(
                        width: 200,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF80FED6),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _buildBackgroundImage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Name Section
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(_nameController, 'Enter your name'),
                    const SizedBox(height: 24),
                    // Gender Section
                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildGenderSelection(),
                    const SizedBox(height: 24),
                    // Signature Section
                    const Text(
                      'Signature',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(_signatureController, 'Enter your signature', maxLines: 3),
                    const SizedBox(height: 40), // 底部间距
                  ],
                ),
              ),
            ),
            // 底部 Save 按钮
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80FED6),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF80FED6).withValues(alpha: 0.3),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF80FED6), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: const TextStyle(color: Color(0xFF333333)),
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildGenderOption('Male', 'male'),
        _buildGenderOption('Female', 'female'),
        _buildGenderOption('None', ''),
      ],
    );
  }

  Widget _buildGenderOption(String label, String value) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF80FED6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFCCCCCC),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : const Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (_avatarPath.startsWith('assets/')) {
      return Image.asset(
        _avatarPath,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      return FutureBuilder<String?>(
        future: UserInfoService.getFullImagePath(_avatarPath),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(
              File(snapshot.data!),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultAvatar();
              },
            );
          }
          return _buildDefaultAvatar();
        },
      );
    }
  }

  Widget _buildBackgroundImage() {
    if (_backgroundPath.startsWith('assets/')) {
      return Image.asset(
        _backgroundPath,
        width: 200,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultBackground();
        },
      );
    } else {
      return FutureBuilder<String?>(
        future: UserInfoService.getFullImagePath(_backgroundPath),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(
              File(snapshot.data!),
              width: 200,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultBackground();
              },
            );
          }
          return _buildDefaultBackground();
        },
      );
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        size: 50,
        color: Color(0xFFCCCCCC),
      ),
    );
  }

  Widget _buildDefaultBackground() {
    return Container(
      width: 200,
      height: 120,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
      ),
      child: const Icon(
        Icons.image,
        size: 50,
        color: Color(0xFFCCCCCC),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );
      
      if (image != null) {
        final relativePath = await UserInfoService.saveImageToSandbox(
          File(image.path),
          image.name,
        );
        setState(() {
          _avatarPath = relativePath;
        });
      }
    } catch (e) {
      if (mounted) {
        IOSAlert.showError(context, 'Error picking image: $e');
      }
    }
  }

  Future<void> _pickBackground() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      if (image != null) {
        final relativePath = await UserInfoService.saveImageToSandbox(
          File(image.path),
          image.name,
        );
        setState(() {
          _backgroundPath = relativePath;
        });
      }
    } catch (e) {
      if (mounted) {
        IOSAlert.showError(context, 'Error picking image: $e');
      }
    }
  }

  Future<void> _saveChanges() async {
    try {
      // 获取当前输入的数据
      final name = _nameController.text.trim();
      final signature = _signatureController.text.trim();
      final gender = _selectedGender;
      final avatarPath = _avatarPath;
      final backgroundPath = _backgroundPath;
      
      // 验证输入
      if (name.isEmpty) {
        IOSAlert.showError(context, 'Please enter your name');
        return;
      }
      
      // 创建用户信息对象
      final userInfo = UserInfo(
        name: name,
        gender: gender,
        signature: signature,
        avatarPath: avatarPath,
        backgroundPath: backgroundPath,
      );
      
      // 保存到本地存储
      await UserInfoService.saveUserInfo(userInfo);
      
      // 通知父页面更新用户数据
      if (widget.onUserInfoUpdated != null) {
        widget.onUserInfoUpdated!(name, signature, gender, avatarPath, backgroundPath);
      }
      
      if (mounted) {
        IOSAlert.showSuccess(context, 'Settings saved successfully');
      }
      
      // 延迟返回上一页，让用户看到成功提示
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      if (mounted) {
        IOSAlert.showError(context, 'Error saving settings: $e');
      }
    }
  }


}
