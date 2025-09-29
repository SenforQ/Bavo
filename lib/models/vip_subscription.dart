class VipSubscription {
  final String id;
  final String name;
  final String subtitle;
  final double price;
  final int durationDays;
  final bool isMostPopular;
  final String currency;
  final String productId;
  final bool isPriceLoaded;
  final double? originalPrice;
  final String? originalPriceText;

  VipSubscription({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.durationDays,
    this.isMostPopular = false,
    this.currency = '\$',
    required this.productId,
    this.isPriceLoaded = false,
    this.originalPrice,
    this.originalPriceText,
  });

  VipSubscription copyWith({
    String? id,
    String? name,
    String? subtitle,
    double? price,
    int? durationDays,
    bool? isMostPopular,
    String? currency,
    String? productId,
    bool? isPriceLoaded,
    double? originalPrice,
    String? originalPriceText,
  }) {
    return VipSubscription(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
      isMostPopular: isMostPopular ?? this.isMostPopular,
      currency: currency ?? this.currency,
      productId: productId ?? this.productId,
      isPriceLoaded: isPriceLoaded ?? this.isPriceLoaded,
      originalPrice: originalPrice ?? this.originalPrice,
      originalPriceText: originalPriceText ?? this.originalPriceText,
    );
  }
}

class VipPrivilege {
  final String id;
  final String title;
  final String description;
  final String iconPath;

  VipPrivilege({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
  });
}

class VipSubscriptionService {
  static List<VipSubscription> getSubscriptions() {
    return [
      VipSubscription(
        id: 'BavoWeekVIP',
        name: 'Weekly',
        subtitle: '7 Days VIP Access',
        price: 12.99,
        durationDays: 7,
        productId: 'BavoWeekVIP',
      ),
      VipSubscription(
        id: 'BavoMonthVIP',
        name: 'Monthly',
        subtitle: '30 Days VIP Access',
        price: 49.99,
        durationDays: 30,
        isMostPopular: true,
        productId: 'BavoMonthVIP',
      ),
    ];
  }

  static List<VipPrivilege> getPrivileges() {
    return [
      VipPrivilege(
        id: 'dubbing_script',
        title: 'Unlimited avatar editing',
        description: 'VIP can modify their personal information',
        iconPath: 'assets/vip_icons/dubbing_script.png',
      ),
      VipPrivilege(
        id: 'works_promotion',
        title: 'Unlimited browsing of informationn',
        description: 'VIP can browse information without restrictions',
        iconPath: 'assets/vip_icons/works_promotion.png',
      ),

      VipPrivilege(
        id: 'ad_free',
        title: 'Ad-free privilege',
        description: 'VIPs can get rid of ads',
        iconPath: 'assets/vip_icons/ad_free.png',
      ),
    ];
  }
}
