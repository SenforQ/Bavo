import 'package:flutter/material.dart';
import 'dart:io';
import '../services/user_info_service.dart';
import '../services/vip_service.dart';
import 'privacy_page.dart';
import 'terms_page.dart';
import 'about_us_page.dart';
import 'setting_page.dart';
import 'voice_sumbit_page.dart';
import 'vip_sub_page.dart';
import 'wallet_detail_page.dart';

class Tab4MinePage extends StatefulWidget {
  const Tab4MinePage({super.key});

  @override
  State<Tab4MinePage> createState() => _Tab4MinePageState();
}

class _Tab4MinePageState extends State<Tab4MinePage> {
  String _userName = 'Bavo';
  String _userSignature = 'No signature';
  String _userGender = '';
  String _avatarPath = 'assets/user_defalut_icon.webp';
  String _backgroundPath = 'assets/mine_top_bg.webp';
  
  // VIP 状态
  bool _isVipActive = false;
  int _vipRemainingDays = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadVipStatus();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await UserInfoService.getUserInfo();
      setState(() {
        _userName = userInfo.name;
        _userSignature = userInfo.signature;
        _userGender = userInfo.gender;
        _avatarPath = userInfo.avatarPath;
        _backgroundPath = userInfo.backgroundPath;
      });
    } catch (e) {
      // 如果加载失败，使用默认值
    }
  }

  Future<void> _loadVipStatus() async {
    try {
      final isActive = await VipService.isVipActive();
      final isExpired = await VipService.isVipExpired();
      final remainingDays = await VipService.getVipRemainingDays();
      
      setState(() {
        _isVipActive = isActive && !isExpired;
        _vipRemainingDays = remainingDays;
      });
      
      // 如果VIP已过期，自动停用
      if (isActive && isExpired) {
        await VipService.deactivateVip();
        setState(() {
          _isVipActive = false;
          _vipRemainingDays = 0;
        });
      }
    } catch (e) {
      print('Tab4MinePage - Error loading VIP status: $e');
    }
  }

  void _updateUserInfo(String name, String signature, String gender, String avatarPath, String backgroundPath) {
    setState(() {
      _userName = name;
      _userSignature = signature;
      _userGender = gender;
      _avatarPath = avatarPath;
      _backgroundPath = backgroundPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // 背景图片
          Positioned.fill(
            child: Image.asset(
              'assets/base_bg.webp',
              fit: BoxFit.cover,
            ),
          ),
          // 内容区域
          SingleChildScrollView(
            child: Column(
              children: [
                // 顶部背景和用户信息区域
                _buildTopSection(context),
                // 菜单列表区域
                _buildMenuSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return SizedBox(
      height: 320, // 增加高度以容纳 VIP 状态显示
      child: Stack(
        children: [
          // 背景图片
          Positioned.fill(
            child: _backgroundPath.startsWith('assets/')
                ? Image.asset(
                    _backgroundPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/mine_top_bg.webp',
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : FutureBuilder<String?>(
                    future: UserInfoService.getFullImagePath(_backgroundPath),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Image.file(
                          File(snapshot.data!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/mine_top_bg.webp',
                              fit: BoxFit.cover,
                            );
                          },
                        );
                      }
                      return Image.asset(
                        'assets/mine_top_bg.webp',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
          ),
          // 渐变图片层
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 132,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/mine_person_mask.webp'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // 用户头像和信息
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // 使用 min 避免溢出
              children: [
                const SizedBox(height: 50), // 减少顶部间距
                // 用户头像
                Container(
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
                    child: _avatarPath.startsWith('assets/')
                        ? Image.asset(
                            _avatarPath,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/user_defalut_icon.webp',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : FutureBuilder<String?>(
                            future: UserInfoService.getFullImagePath(_avatarPath),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Image.file(
                                  File(snapshot.data!),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/user_defalut_icon.webp',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                );
                              }
                              return Image.asset(
                                'assets/user_defalut_icon.webp',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 12), // 减少间距
                // 用户名和性别图标
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // 性别图标（如果用户选择了性别）
                    if (_userGender.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _userGender == 'male' ? const Color(0xFF4FC3F7) : const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _userGender == 'male' ? Icons.male : Icons.female,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6), // 减少间距
                // 用户描述
                Text(
                  _userSignature,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8), // 减少间距
                // VIP 状态显示
                if (_isVipActive) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _vipRemainingDays > 0 
                            ? 'VIP Active - $_vipRemainingDays days left'
                            : 'VIP Active',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Upgrade to VIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          // 横幅图片区域
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // me_banner_sumbit.webp 横幅
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const VoiceSubmitPage()),
                    );
                  },
                  child: Container(
                    width: 335,
                    height: 95,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Image.asset(
                      'assets/me_banner_sumbit.webp',
                      width: 335,
                      height: 95,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 335,
                          height: 95,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // me_sub_vip.webp 横幅
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const VipSubPage()),
                    );
                    
                    // 如果购买成功，重新加载VIP状态
                    if (result != null && result['vip_activated'] == true) {
                      _loadVipStatus();
                    }
                  },
                  child: Container(
                    width: 335,
                    height: 68,
                    child: Image.asset(
                      'assets/me_sub_vip.webp',
                      width: 335,
                      height: 68,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 335,
                          height: 68,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 菜单列表容器
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildMenuItem('assets/me_wallet.webp', 'Wallet', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const WalletDetailPage()),
                  );
                }),
                _buildDivider(),
                _buildMenuItem('assets/me_privacy_policy.webp', 'Privacy Policy', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const PrivacyPage()),
                  );
                }),
                _buildDivider(),
                _buildMenuItem('assets/me_setting.webp', 'Settings', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SettingPage(
                        onUserInfoUpdated: _updateUserInfo,
                      ),
                    ),
                  );
                }),
                _buildDivider(),
                _buildMenuItem('assets/me_about_us.webp', 'About Us', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AboutUsPage()),
                  );
                }),
                _buildDivider(),
                _buildMenuItem('assets/me_user_agreement.webp', 'User Agreement', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const TermsPage()),
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String iconPath, String title, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 60),
      height: 1,
      color: Colors.grey[200],
    );
  }
}
