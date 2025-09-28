import 'package:flutter/material.dart';
import '../widgets/custom_tabbar.dart';
import 'tab_1_discover_page.dart';
import 'tab_2_popular_page.dart';
import 'tab_3_history_page.dart';
import 'tab_4_mine_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final GlobalKey<State<Tab1DiscoverPage>> _discoverPageKey = GlobalKey<State<Tab1DiscoverPage>>();

  List<Widget> get _pages => [
    Tab1DiscoverPage(key: _discoverPageKey),
    const Tab2PopularPage(),
    const Tab3HistoryPage(),
    const Tab4MinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 背景图片
          Positioned.fill(
            child: Image.asset(
              'assets/base_bg.webp',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
          ),
          // 页面内容
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 83, // 为底部tabbar留出空间
            child: _pages[_currentIndex],
          ),
          // 底部tabbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomTabBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
