import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../models/vip_subscription.dart';
import '../services/vip_service.dart';

class VipSubPage extends StatefulWidget {
  const VipSubPage({super.key});

  @override
  State<VipSubPage> createState() => _VipSubPageState();
}

class _VipSubPageState extends State<VipSubPage> {
  VipSubscription? _selectedSubscription;
  List<VipSubscription> _subscriptions = VipSubscriptionService.getSubscriptions();
  final List<VipPrivilege> _privileges = VipSubscriptionService.getPrivileges();
  
  // VIP 状态
  bool _isVipActive = false;
  bool _isPriceLoading = false;
  int _retryCount = 0;
  static const int maxRetries = 3;
  static const int timeoutDuration = 30;
  
  // 内购相关
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  Map<String, ProductDetails> _products = {};
  final Map<String, bool> _loadingStates = {};
  final Map<String, Timer> _timeoutTimers = {};

  @override
  void initState() {
    super.initState();
    // 默认选择最受欢迎的选项
    _selectedSubscription = _subscriptions.firstWhere(
      (sub) => sub.isMostPopular,
      orElse: () => _subscriptions.first,
    );
    _loadVipStatus();
    _checkConnectivityAndInit();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    for (final timer in _timeoutTimers.values) {
      timer.cancel();
    }
    _timeoutTimers.clear();
    super.dispose();
  }

  void _selectSubscription(VipSubscription subscription) {
    setState(() {
      _selectedSubscription = subscription;
    });
  }

  Future<void> _loadVipStatus() async {
    try {
      final isActive = await VipService.isVipActive();
      final isExpired = await VipService.isVipExpired();
      
      setState(() {
        _isVipActive = isActive && !isExpired;
      });
      
      // 如果VIP已过期，自动停用
      if (isActive && isExpired) {
        await VipService.deactivateVip();
        setState(() {
          _isVipActive = false;
        });
      }
    } catch (e) {
      print('VipSubPage - Error loading VIP status: $e');
    }
  }

  Future<void> _checkConnectivityAndInit() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showToast('No internet connection. Please check your network settings.');
      return;
    }
    await _initIAP();
  }

  Future<void> _initIAP() async {
    try {
      // 立即显示默认价格，不显示加载状态
      _updateProductPrices();
      
      final available = await _inAppPurchase.isAvailable();
      if (!mounted) return;
      setState(() {
        _isAvailable = available;
      });
      if (!available) {
        if (mounted) {
          _showToast('In-App Purchase not available');
        }
        return;
      }
      
      final Set<String> kIds = _subscriptions.map((e) => e.productId).toSet();
      final response = await _inAppPurchase.queryProductDetails(kIds);
      if (response.error != null) {
        if (_retryCount < maxRetries) {
          _retryCount++;
          await Future.delayed(const Duration(seconds: 2));
          await _initIAP();
          return;
        }
        _showToast('Failed to load products: ${response.error!.message}');
        return;
      }
      
      setState(() {
        _products = {for (var p in response.productDetails) p.id: p};
      });
      
      // 更新产品价格（如果有从商店获取的价格）
      _updateProductPrices();
      
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () {
          _subscription?.cancel();
        },
        onError: (e) {
          if (mounted) {
            _showToast('Purchase error: ${e.toString()}');
          }
        },
      );
    } catch (e) {
      if (_retryCount < maxRetries) {
        _retryCount++;
        await Future.delayed(const Duration(seconds: 2));
        await _initIAP();
      } else {
        if (mounted) {
          _showToast('Failed to initialize in-app purchases. Please try again later.');
        }
      }
    }
  }

  void _updateProductPrices() {
    // 只标记所有产品为已加载，保持默认价格不变
    setState(() {
      _subscriptions = _subscriptions.map((product) => product.copyWith(isPriceLoaded: true)).toList();
    });
    
    // 不更新价格，始终保持默认价格
    // 即使获取到真实价格也不覆盖默认价格
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      // 只有在购买成功或恢复购买时才激活VIP
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        // 先完成购买确认
        await _inAppPurchase.completePurchase(purchase);
        
        // 验证购买是否真的成功
        if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
          // 验证产品ID是否有效
          final validProductIds = _subscriptions.map((s) => s.productId).toSet();
          if (validProductIds.contains(purchase.productID)) {
            try {
              // 只有在购买成功且产品ID有效时才激活VIP
              await VipService.activateVip(
                productId: purchase.productID,
                purchaseDate: DateTime.now().toIso8601String(),
              );
              
              if (mounted) {
                setState(() {
                  _isVipActive = true;
                });
                _showToast('VIP subscription activated successfully!');
                Navigator.of(context).pop({
                  'vip_activated': true,
                  'product_id': purchase.productID,
                  'purchase_date': DateTime.now().toIso8601String(),
                });
              }
            } catch (e) {
              print('VipSubPage - Error activating VIP: $e');
              if (mounted) {
                _showToast('Failed to activate VIP. Please contact support.');
              }
            }
          } else {
            // 产品ID无效
            if (mounted) {
              _showToast('Invalid product. Please try again.');
            }
          }
        }
      } else if (purchase.status == PurchaseStatus.error) {
        if (mounted) {
          _showToast('Purchase failed: ${purchase.error?.message ?? ''}');
        }
      } else if (purchase.status == PurchaseStatus.canceled) {
        if (mounted) {
          _showToast('Purchase canceled.');
        }
      }
      
      // 清除购买状态和超时定时器
      if (mounted) {
        setState(() {
          _loadingStates.clear();
        });
        for (final timer in _timeoutTimers.values) {
          timer.cancel();
        }
        _timeoutTimers.clear();
      }
    }
  }

  void _handleTimeout(String productId) {
    if (mounted) {
      setState(() {
        _loadingStates[productId] = false;
      });
      
      _timeoutTimers[productId]?.cancel();
      _timeoutTimers.remove(productId);
      
      _showToast('Payment timeout. Please try again.');
    }
  }

  void _confirmSubscription() {
    if (_selectedSubscription == null) return;

    if (!_isAvailable) {
      _showToast('Store is not available');
      return;
    }

    if (_isVipActive) {
      _showToast('You already have an active VIP subscription');
      return;
    }

    _handleConfirmPurchase();
  }

  Future<void> _handleConfirmPurchase() async {
    if (_selectedSubscription == null) return;
    
    // 验证选中的订阅是否有效
    final validProductIds = _subscriptions.map((s) => s.productId).toSet();
    if (!validProductIds.contains(_selectedSubscription!.productId)) {
      _showToast('Invalid subscription selected. Please try again.');
      return;
    }
    
    setState(() {
      _loadingStates[_selectedSubscription!.productId] = true;
    });
    
    _timeoutTimers[_selectedSubscription!.productId] = Timer(
      Duration(seconds: timeoutDuration),
      () => _handleTimeout(_selectedSubscription!.productId),
    );
    
    try {
      // 只使用选中的产品进行购买，不使用备用产品
      final product = _products[_selectedSubscription!.productId];
      if (product == null) {
        throw Exception('Selected product not available for purchase');
      }
      
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _timeoutTimers[_selectedSubscription!.productId]?.cancel();
      _timeoutTimers.remove(_selectedSubscription!.productId);
      
      if (mounted) {
        _showToast('Purchase failed: ${e.toString()}');
      }
      setState(() {
        _loadingStates[_selectedSubscription!.productId] = false;
      });
    }
  }

  Future<void> _restorePurchases() async {
    if (!_isAvailable) {
      _showToast('Store is not available');
      return;
    }
    try {
      await _inAppPurchase.restorePurchases();
      _showToast('Restoring purchases...');
    } catch (e) {
      if (mounted) {
        _showToast('Restore failed: ${e.toString()}');
      }
    }
  }

  void _showToast(String message) {
    if (mounted) {
      // iOS 风格的 Toast 提示
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (context) => Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
      
      // 自动关闭提示
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Stack(
        children: [
          // 主要内容
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // VIP Top Background Image with Back Button
                  Stack(
                    children: [
                      // Background Image
                      Container(
                        width: screenWidth,
                        height: screenWidth,
                        child: Image.asset(
                          'assets/vip_top_bg.webp',
                          width: screenWidth,
                          height: screenWidth,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: screenWidth,
                              height: screenWidth,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFF1A1A1A),
                                    Color(0xFF2D2D2D),
                                    Color(0xFF80FED6),
                                  ],
                                  stops: [0.0, 0.3, 1.0],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Back Button
                      Positioned(
                        top: 20,
                        left: 20,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Member Exclusive Privileges
                  _buildPrivilegesSection(),
                  
                  // Join VIP Section
                  _buildSubscriptionSection(),
                  
                  // Confirm Button
                  _buildConfirmButton(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // 购买Loading覆盖层
          if (_loadingStates.values.any((loading) => loading))
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF80FED6)),
                    strokeWidth: 4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          const Spacer(),
          
          // VIP Club Title
          const Text(
            'VIP Club',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const Spacer(),
          
          // Placeholder for symmetry
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildCrownSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          // Golden Crown
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFFFA500),
                  Color(0xFFFF8C00),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // VIP Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF9B59B6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'VIP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivilegesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Member Exclusive Privileges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 15),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: _privileges.asMap().entries.map((entry) {
                final index = entry.key;
                final privilege = entry.value;
                final isLast = index == _privileges.length - 1;
                
                return Column(
                  children: [
                    _buildPrivilegeItem(privilege),
                    if (!isLast) _buildDivider(),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivilegeItem(VipPrivilege privilege) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF80FED6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPrivilegeIcon(privilege.id),
              color: const Color(0xFF80FED6),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  privilege.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  privilege.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPrivilegeIcon(String id) {
    switch (id) {
      case 'dubbing_script':
        return Icons.auto_awesome;
      case 'works_promotion':
        return Icons.mic;
      case 'personalized_identity':
        return Icons.star;
      case 'ad_free':
        return Icons.block;
      default:
        return Icons.star;
    }
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: const Color(0xFFE0E0E0),
    );
  }

  Widget _buildSubscriptionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Join VIP',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 15),
          
          ..._subscriptions.map((subscription) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSubscriptionCard(subscription),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(VipSubscription subscription) {
    final isSelected = _selectedSubscription?.id == subscription.id;
    
    return GestureDetector(
      onTap: () => _selectSubscription(subscription),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
              ? Border.all(color: Colors.black, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Most Popular Badge
            if (subscription.isMostPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF333333),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Most Popular',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Radio Button
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF80FED6) : const Color(0xFFE0E0E0),
                        width: 2,
                      ),
                      color: isSelected ? const Color(0xFF80FED6) : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Subscription Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subscription.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
             
                      ],
                    ),
                  ),
                  
                  // Price
                  Text(
                    '${subscription.currency} ${subscription.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    final canPurchase = !_isVipActive && _selectedSubscription != null;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 主购买按钮
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: canPurchase ? _confirmSubscription : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canPurchase ? const Color(0xFF80FED6) : Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: Text(
                _isVipActive ? 'VIP Active' : 'Start VIP Subscription',
                style: TextStyle(
                  color: canPurchase ? Colors.black : Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 恢复购买按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _restorePurchases,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Restore Purchases',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 说明文字
          Text(
            'Subscription will be charged to your Apple ID account. You can cancel anytime in Settings.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
