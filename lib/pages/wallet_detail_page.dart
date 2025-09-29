import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../services/coin_service.dart';

// 金币产品常量
class CoinProduct {
  final String productId;
  final int coins;
  final double price;
  final String priceText;

  CoinProduct({
    required this.productId,
    required this.coins,
    required this.price,
    required this.priceText,
  });
}

final List<CoinProduct> kCoinProducts = [
  CoinProduct(productId: 'Bavo', coins: 32, price: 0.99, priceText: '\$0.99'),
  CoinProduct(productId: 'Bavo1', coins: 60, price: 1.99, priceText: '\$1.99'),
  CoinProduct(productId: 'Bavo2', coins: 96, price: 2.99, priceText: '\$2.99'),
  CoinProduct(productId: 'Bavo4', coins: 155, price: 4.99, priceText: '\$4.99'),
  CoinProduct(productId: 'Bavo5', coins: 189, price: 5.99, priceText: '\$5.99'),
  CoinProduct(productId: 'Bavo9', coins: 359, price: 9.99, priceText: '\$9.99'),
  CoinProduct(productId: 'Bavo19', coins: 729, price: 19.99, priceText: '\$19.99'),
  CoinProduct(productId: 'Bavo49', coins: 1869, price: 49.99, priceText: '\$49.99'),
  CoinProduct(productId: 'Bavo99', coins: 3799, price: 99.99, priceText: '\$99.99'),
  CoinProduct(productId: 'Bavo159', coins: 5999, price: 159.99, priceText: '\$159.99'),
  CoinProduct(productId: 'Bavo239', coins: 9059, price: 239.99, priceText: '\$239.99'), 
];

class WalletDetailPage extends StatefulWidget {
  const WalletDetailPage({super.key});

  @override
  State<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends State<WalletDetailPage> {
  int _currentCoins = 0;
  int _selectedIndex = 0; // 默认选中第一个产品
  bool _isPurchasing = false; // 全局购买状态
  final Map<String, Timer> _timeoutTimers = {}; // 为每个商品管理超时定时器
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  Map<String, ProductDetails> _products = {};
  int _retryCount = 0;
  static const int maxRetries = 3;
  static const int timeoutDuration = 30; // 30秒超时

  // 处理购买超时
  void _handlePurchaseTimeout() {
    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });
      
      // 取消定时器
      _timeoutTimers['purchase']?.cancel();
      _timeoutTimers.remove('purchase');
      
      // 显示超时提示
      try {
        _showToast('Payment timeout. Please try again.');
      } catch (e) {
        debugPrint('Failed to show timeout toast: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeUserAndLoadCoins();
    _checkConnectivityAndInit();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    // 取消所有超时定时器
    for (final timer in _timeoutTimers.values) {
      timer.cancel();
    }
    _timeoutTimers.clear();
    super.dispose();
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
      final Set<String> kIds = kCoinProducts.map((e) => e.productId).toSet();
      final response = await _inAppPurchase.queryProductDetails(kIds);
      if (response.error != null) {
        if (_retryCount < maxRetries) {
          _retryCount++;
          await Future.delayed(const Duration(seconds: 2));
          await _initIAP();
          return;
        }
        _showToast('Failed to load products: ${response.error!.message}');
      }
      setState(() {
        _products = {for (var p in response.productDetails) p.id: p};
      });
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

  Future<void> _initializeUserAndLoadCoins() async {
    // 静默初始化新用户（只在首次进入时执行）
    await CoinService.initializeNewUser();
    await _loadCoins();
  }

  Future<void> _loadCoins() async {
    final coins = await CoinService.getCurrentCoins();
    setState(() {
      _currentCoins = coins;
    });
  }


  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      // 只有在购买成功或恢复购买时才添加金币
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        // 先完成购买确认
        await _inAppPurchase.completePurchase(purchase);
        
        // 验证购买是否真的成功
        if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
          // 找到对应的产品并添加金币
          final product = kCoinProducts.firstWhere(
            (p) => p.productId == purchase.productID,
            orElse: () => CoinProduct(productId: '', coins: 0, price: 0, priceText: ''),
          );
          
          // 只有在找到有效产品且金币数量大于0时才添加
          if (product.coins > 0) {
            final success = await CoinService.addCoins(product.coins);
            
            if (success && mounted) {
              await _loadCoins(); // 重新加载金币余额
              
              // 显示成功提示
              try {
                _showToast('Successfully purchased ${product.coins} coins!');
              } catch (e) {
                debugPrint('Failed to show success toast: $e');
              }
            } else {
              // 添加金币失败
              if (mounted) {
                try {
                  _showToast('Failed to add coins. Please contact support.');
                } catch (e) {
                  debugPrint('Failed to show error toast: $e');
                }
              }
            }
          }
        }
      } else if (purchase.status == PurchaseStatus.error) {
        if (mounted) {
          try {
            _showToast('Purchase failed: ${purchase.error?.message ?? ''}');
          } catch (e) {
            debugPrint('Failed to show error toast: $e');
          }
        }
      } else if (purchase.status == PurchaseStatus.canceled) {
        if (mounted) {
          try {
            _showToast('Purchase canceled.');
          } catch (e) {
            debugPrint('Failed to show cancel toast: $e');
          }
        }
      }
      
      // 清除购买状态和超时定时器
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
        
        // 取消所有超时定时器
        for (final timer in _timeoutTimers.values) {
          timer.cancel();
        }
        _timeoutTimers.clear();
      }
    }
  }

  Future<void> _handleConfirmPurchase() async {
    if (!_isAvailable) {
      _showToast('Store is not available');
      return;
    }
    
    // 获取选中的产品
    final selectedProduct = kCoinProducts[_selectedIndex];
    
    setState(() {
      _isPurchasing = true; // 使用全局购买状态
    });
    
    // 设置30秒超时定时器
    _timeoutTimers['purchase'] = Timer(
      Duration(seconds: timeoutDuration),
      () => _handlePurchaseTimeout(),
    );
    
    try {
      // 尝试获取对应的产品详情
      final product = _products[selectedProduct.productId];
      
      // 如果没有找到对应的产品，使用第一个可用的产品进行购买
      ProductDetails? productToUse = product;
      if (productToUse == null && _products.isNotEmpty) {
        productToUse = _products.values.first;
      }
      
      if (productToUse == null) {
        throw Exception('No products available for purchase');
      }
      
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productToUse);
      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      // 取消超时定时器
      _timeoutTimers['purchase']?.cancel();
      _timeoutTimers.remove('purchase');
      
      if (mounted) {
        _showToast('Purchase failed: ${e.toString()}');
      }
      setState(() {
        _isPurchasing = false; // 清除购买状态
      });
    }
  }

  void _showToast(String message) {
    if (mounted) {
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // 背景图片
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: screenWidth,
              height: 242,
              child: Image.asset(
                'assets/wallet_bg.webp',
                width: screenWidth,
                height: 242,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: screenWidth,
                    height: 242,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF4FC3F7),
                          Color(0xFF81C784),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // 账户余额显示 - 在顶部背景图片上
          Positioned(
            top: 120,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account balance',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF092F38),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_currentCoins',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
          // 状态栏和导航栏区域
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + 60,
              child: Stack(
                children: [
                  // 返回按钮
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  // 标题
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 0,
                    right: 0,
                    child: const Center(
                      child: Text(
                        'Wallet',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // 说明按钮
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => _showWalletUsageDialog(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 主要内容区域 - 可滑动
          Positioned(
            top: 267,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // 金币购买选项列表
                    _buildCoinList(),
                    const SizedBox(height: 100), // 为悬浮按钮留出空间
                  ],
                ),
              ),
            ),
          ),
          // 悬浮购买按钮
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isPurchasing ? null : () {
                  if (_selectedIndex < kCoinProducts.length) {
                    _onProductSelected(kCoinProducts[_selectedIndex]);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF80FED6),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                child: Text(
                  _isPurchasing ? 'Processing...' : 'Purchase',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: kCoinProducts.length,
        itemBuilder: (context, index) {
          final product = kCoinProducts[index];
          return Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? 0 : 12,
              bottom: 12,
            ),
            child: _buildCoinCard(product, index),
          );
        },
      ),
    );
  }

  Widget _buildCoinCard(CoinProduct product, int index) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD9E6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF0D66) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 金币图标
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F8F0),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/wallet_coin.webp',
                    width: 35,
                    height: 23,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.monetization_on,
                        color: Color(0xFF87A156),
                        size: 32,
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 金币信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${product.coins} Gold Coins',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Perfect for AI chat',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // 价格信息
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.priceText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF80FED6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Selected',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onProductSelected(CoinProduct product) {
    // 显示确认对话框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.diamond,
                color: Color(0xFFFFD700),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Confirm Purchase',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to purchase ${product.coins} coins for ${product.priceText}?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleConfirmPurchase();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF80FED6),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Purchase',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showWalletUsageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF80FED6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Wallet Usage',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUsageRule(
                '1',
                'Elf character unlock requires 1000 coins',
              ),
              const SizedBox(height: 16),
              _buildUsageRule(
                '2',
                'Each chat session with Elf character costs 20 coins',
              ),
              const SizedBox(height: 16),
              _buildUsageRule(
                '3',
                'New users receive 100 coins as a welcome bonus',
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF80FED6),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUsageRule(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF80FED6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}