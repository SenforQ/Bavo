import 'package:flutter/material.dart';
import 'dart:convert';
import 'dubbing_ai_detail_page.dart';
import '../services/character_filter_service.dart';

class Tab1DiscoverPage extends StatefulWidget {
  const Tab1DiscoverPage({super.key});

  @override
  State<Tab1DiscoverPage> createState() => _Tab1DiscoverPageState();
}

class _Tab1DiscoverPageState extends State<Tab1DiscoverPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<Map<String, dynamic>> characters = [];
  int selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 每次页面重新显示时重新加载数据
    _loadCharacters();
  }

  // 公开的刷新方法，供外部调用
  void refreshData() {
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/dubbingAI/dubbingAIConfig.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final allCharacters = List<Map<String, dynamic>>.from(data['characters']);
      
      // 获取被屏蔽和拉黑的角色列表
      final blockedCharacters = await CharacterFilterService.getBlockedCharacters();
      final blacklistedCharacters = await CharacterFilterService.getBlacklistedCharacters();
      
      // 过滤掉被屏蔽和拉黑的角色
      final filteredCharacters = allCharacters.where((character) {
        final characterName = character['RavoNickName'] ?? '';
        return !blockedCharacters.contains(characterName) && 
               !blacklistedCharacters.contains(characterName);
      }).toList();
      
      setState(() {
        characters = filteredCharacters;
      });
    } catch (e) {
      // Error loading characters
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用父类的build方法
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),
            // Category Tags
            _buildCategoryTags(),
            // Main Content
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Image.asset(
            'assets/home_discover_title.webp',
            width: 168,
            height: 46,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'Discover',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              );
            },
          ),

        ],
      ),
    );
  }

  Widget _buildCategoryTags() {
    if (characters.isEmpty) {
      return const SizedBox(height: 50);
    }
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final character = characters[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;
              });
              // 跳转到对应的角色详情页
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DubbingAIDetailPage(
                    character: character,
                    onCharacterFiltered: refreshData,
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                // 黑色背景层
                Positioned(
                  right: -2,
                  bottom: 5,
                  child: ClipPath(
                    clipper: ParallelogramClipper(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                character['RavoUserIcon'],
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            character['RavoNickName'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 主标签层
                ClipPath(
                  clipper: ParallelogramClipper(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF80FED6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 角色头像
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              character['RavoUserIcon'],
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Color(0xFF2C2C2C),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          character['RavoNickName'],
                          style: const TextStyle(
                            color: Color(0xFF2C2C2C),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent() {
    if (characters.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF80FED6),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Main featured card
          Expanded(
            flex: 2,
            child: _buildFeaturedCard(characters[0], 0),
          ),
          const SizedBox(width: 16),
              // Side cards
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    if (characters.length > 1)
                      Expanded(
                        child: _buildSideCard(characters[1], 1),
                      ),
                    if (characters.length > 2) ...[
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildSideCard(characters[2], 2),
                      ),
                    ],
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> character, int rank) {
    // 根据排名选择颜色
    Color rankColor;
    switch (rank) {
      case 0:
        rankColor = const Color(0xFFFFD700); // 金色 - Top 1
        break;
      case 1:
        rankColor = const Color(0xFFC0C0C0); // 银色 - Top 2
        break;
      case 2:
        rankColor = const Color(0xFFCD7F32); // 铜色 - Top 3
        break;
      default:
        rankColor = const Color(0xFF80FED6); // 默认浅青色
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DubbingAIDetailPage(
              character: character,
              onCharacterFiltered: refreshData,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF80FED6),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
            // Character image
            Positioned.fill(
              child: Image.asset(
                character['RavoShowPhoto'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE0E0E0),
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            // Top rank badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: rankColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Top ${rank + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom overlay with character info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Character avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          character['RavoUserIcon'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Character name and stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            character['RavoNickName'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${character['RavoShowFollowNum']} people have dubbed',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSideCard(Map<String, dynamic> character, int rank) {
    // 根据排名选择颜色
    Color rankColor;
    switch (rank) {
      case 1:
        rankColor = const Color(0xFFC0C0C0); // 银色 - Top 2
        break;
      case 2:
        rankColor = const Color(0xFFCD7F32); // 铜色 - Top 3
        break;
      default:
        rankColor = const Color(0xFF80FED6); // 默认浅青色
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DubbingAIDetailPage(
              character: character,
              onCharacterFiltered: refreshData,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            children: [
            // Character image
            Positioned.fill(
              child: Image.asset(
                character['RavoShowPhoto'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE0E0E0),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            // Top rank badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rankColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Top ${rank + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Character name overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 角色头像
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          character['RavoUserIcon'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 12,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 角色名称
                    Expanded(
                      child: Text(
                        character['RavoNickName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class ParallelogramClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final skew = size.height * 0.3; // 倾斜程度
    
    path.moveTo(skew, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - skew, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
