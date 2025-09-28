import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: screenWidth,
      height: 83,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/tabbar_bg.webp'),
          fit: BoxFit.fill,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(0, 'assets/tab_piex_1_n.webp', 'assets/tab_piex_1_s.webp', screenWidth),
          _buildTabItem(1, 'assets/tab_piex_2_n.webp', 'assets/tab_piex_2_s.webp', screenWidth),
          _buildTabItem(2, 'assets/tab_piex_3_n.webp', 'assets/tab_piex_3_s.webp', screenWidth),
          _buildTabItem(3, 'assets/tab_piex_4_n.webp', 'assets/tab_piex_4_s.webp', screenWidth),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String normalImage, String selectedImage, double screenWidth) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: SizedBox(
        width: screenWidth / 4,
        height: 83,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 11),
            child: SizedBox(
              width: 28,
              height: 28,
              child: Image.asset(
                isSelected ? selectedImage : normalImage,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
