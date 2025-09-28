import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_page.dart';
import 'terms_page.dart';
import 'privacy_page.dart';
import '../services/att_service.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _hasAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/welcome_bg.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              // Enter App 按钮
              Container(
                width: 280,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF80FED6),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: _hasAgreed ? _enterApp : null,
                    child: Center(
                      child: Text(
                        'Enter App',
                        style: TextStyle(
                          color: _hasAgreed ? Colors.black : Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 协议同意文本
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _hasAgreed = !_hasAgreed;
                        });
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _hasAgreed ? const Color(0xFF80FED6) : Colors.transparent,
                          border: Border.all(
                            color: _hasAgreed ? const Color(0xFF80FED6) : Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _hasAgreed
                            ? const Icon(
                                Icons.check,
                                color: Colors.black,
                                size: 14,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(text: 'I have read and agree '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TermsPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Terms of Service',
                                  style: TextStyle(
                                    color: Color(0xFF80FED6),
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFF80FED6),
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PrivacyPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xFF80FED6),
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFF80FED6),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _enterApp() async {
    // 先直接进入主应用，不等待 ATT 权限
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
    }
    
    // 在后台请求 ATT 权限，不影响应用使用
    _requestTrackingPermissionInBackground();
  }

  /// 在后台请求 ATT 权限，不影响应用使用
  Future<void> _requestTrackingPermissionInBackground() async {
    try {
      debugPrint('Requesting ATT permission in background...');
      final isAuthorized = await ATTService.requestTrackingPermission();
      debugPrint('ATT permission result: $isAuthorized');
      
      // 不显示任何提示，静默处理
      // 用户可以在设置中随时更改权限
    } catch (e, stackTrace) {
      debugPrint('Background ATT request failed: $e');
      debugPrint('Stack trace: $stackTrace');
      // 静默失败，不影响应用使用
    }
  }
}
