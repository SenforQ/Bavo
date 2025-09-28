import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'video_detail_page.dart';
import 'popular_figure_detail_page.dart';
import '../services/character_filter_service.dart';

class Tab2PopularPage extends StatefulWidget {
  const Tab2PopularPage({super.key});

  @override
  State<Tab2PopularPage> createState() => _Tab2PopularPageState();
}

class _Tab2PopularPageState extends State<Tab2PopularPage> {
  List<Map<String, dynamic>> _characters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/dubbingAll.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<Map<String, dynamic>> allCharacters = List<Map<String, dynamic>>.from(jsonData['characters']);
      
      // 过滤被屏蔽和拉黑的角色
      final filteredCharacters = await CharacterFilterService.filterCharacters(allCharacters);
      
      setState(() {
        _characters = filteredCharacters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Column(
        children: [
          // 顶部视频区域
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Stack(
              children: [
                // 视频缩略图/背景
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/bavo_voice_play.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 120,
                      color: Colors.white30,
                    ),
                  ),
                ),
                // 视频播放按钮
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VideoDetailPage(
                            videoPath: 'assets/bavo_voice_play.mov',
                            title: 'Bavo Voice Play',
                            description: 'Experience amazing voice acting with our AI-powered dubbing technology',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 40,
                        color: Color(0xFF80FED6),
                      ),
                    ),
                  ),
                ),
                // 视频信息覆盖层
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Official Style',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 视频时长
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '00:09',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 热门作品列表区域
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Row(
                    children: [
                      Image.asset(
                        'assets/popular_title.webp',
                        width: 223,
                        height: 42,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Popular works',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000000),
                            ),
                          );
                        },
                      ),
                     
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 作品列表
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF80FED6),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _characters.length,
                            itemBuilder: (context, index) {
                              final character = _characters[index];
                              return _buildCharacterCard(character, index);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(Map<String, dynamic> character, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: 335,
      height: 154,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/community_card_bg.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
          // 角色头像
          GestureDetector(
            onTap: () {
              // 跳转到角色详情页
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PopularFigureDetailPage(
                    character: character,
                    onCharacterFiltered: _loadCharacters,
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 131,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      character['RavoShowPhoto'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF80FED6),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
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
          const SizedBox(width: 12),
          // 角色信息
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character['RavoNickName'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#${character['RavoGender'] == 'female' ? 'Vitality sound' : 'Loli voice'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // 关注者头像
                      SizedBox(
                        width: 90, // 调整宽度以适应32px头像
                        height: 32,
                        child: Stack(
                          children: [
                            _buildFollowerAvatar('assets/dubbingFemale/1/dubbingFemale_1_avatar.webp'),
                            Positioned(
                              left: 20,
                              child: _buildFollowerAvatar('assets/dubbingMale/1/dubbingMale_1_avatar.webp'),
                            ),
                            Positioned(
                              left:40,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF666666),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${character['RavoShowFollowNum']}+',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // 聊天按钮
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '👋',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'hi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildFollowerAvatar(String imagePath) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF80FED6),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            );
          },
        ),
      ),
    );
  }
}
