import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'emotion_trend_page.dart';
import 'shop_page.dart';
import '../providers/item_state.dart';
import 'plant_growth_page.dart';
import 'setting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String displayedQuote = "";
  final TextEditingController _noteController = TextEditingController();
  String? selectedMood;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Updated comforting quotes with mood-specific messages
  Map<String, List<String>> comfortingQuotes = {
    'Excited': [
      "Your enthusiasm is inspiring! 🚀",
      "Keep that energy flowing! ⚡",
      "Your excitement is contagious! 🎉",
      "Let's make this day amazing! 🌟"
    ],
    'Happy': [
      "Your happiness is contagious! 🌟",
      "Keep spreading those positive vibes! ✨",
      "Your joy makes the world brighter! 🌈",
      "Stay as amazing as you are! 🌺"
    ],
    'Grateful': [
      "You are deeply appreciated! 💝",
      "Your presence makes a difference! 💫",
      "You're surrounded by love! 💖",
      "You deserve all the love! 💕"
    ],
    'Okay': [
      "Every day is a new opportunity! 🌱",
      "Small steps lead to big changes! 🚶",
      "You're doing just fine! 👍",
      "Keep moving forward! 🎯"
    ],
    'Sad': [
      "It's okay to feel this way 💝",
      "This feeling will pass 🌅",
      "You're stronger than you know 💪",
      "Take it one step at a time 🐢"
    ],
    'Stressed': [
      "Take a deep breath 🌬️",
      "You've got this! 💪",
      "One moment at a time ⏳",
      "You're doing your best 🌟"
    ],
    'Tired': [
      "Rest is not a reward, it's a necessity 💤",
      "Take a moment to recharge ⚡",
      "Your body needs rest to perform its best 🌙",
      "It's okay to take a break 🌿"
    ],
    'Annoyed': [
      "Take a deep breath and let it go 🌬️",
      "This too shall pass 🌅",
      "Focus on what you can control 🎯",
      "You're stronger than this situation 💪"
    ]
  };
  
  get ref => null;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // 设置默认消息
    setState(() {
      displayedQuote = getWorkModeMessage();
    });
    _animationController.reset();
    _animationController.forward();

    // 初始化时检查植物生长
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemState>().updatePlantGrowth();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void showMoodNoteDialog(String mood) {
    selectedMood = mood;
    _noteController.text = ''; // Clear previous notes
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              getMoodIcon(mood),
              color: getMoodColor(mood),
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Add a note for "$mood"',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Why do you feel this way? (optional)',
              hintStyle: GoogleFonts.nunito(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFE8F5E9),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFE8F5E9),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFF1B5E20),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFE8F5E9).withOpacity(0.3),
            ),
            maxLines: 3,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF1B5E20),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              recordMoodWithNote(mood, _noteController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void recordMoodWithNote(String mood, String note) {
    final itemState = context.read<ItemState>();
    
    // 记录心情
    itemState.recordMood(mood, note);
    
    // 只有在未达到每日限制时才增加 Leafy Hearts
    if (itemState.canRecordMoodToday()) {
      itemState.addLeafyHeart();
      
      // Show congratulations dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite,
                color: Color(0xFF1B5E20),
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Congratulations!',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You got 1 Leafy Heart!',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // 如果达到每日限制，显示提示信息
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite,
                color: Color(0xFF1B5E20),
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Daily Limit Reached',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your mood has been recorded, but you\'ve reached your daily limit of 3 Leafy Hearts. Your plant will be waiting for more love tomorrow!',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    
    // Display a mood-specific comforting quote
    final moodQuotes = comfortingQuotes[mood] ?? [];
    if (moodQuotes.isNotEmpty) {
      setState(() {
        displayedQuote = (moodQuotes..shuffle()).first;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  String getWorkModeMessage() {
    TimeOfDay now = TimeOfDay.fromDateTime(DateTime.now());
    if (now.hour < 9) return "Good morning! Let's start the day 🌞";
    if (now.hour >= 9 && now.hour < 12) return "Let's have a productive morning! 💼";
    if (now.hour >= 12 && now.hour < 18) return "You're doing great! Keep going! 🌿";
    return "Time to relax! You worked hard today 🌙";
  }
  
  IconData getMoodIcon(String mood) {
    switch (mood) {
      case 'Happy': return Icons.sentiment_very_satisfied;
      case 'Excited': return Icons.celebration;
      case 'Grateful': return Icons.favorite;
      case 'Okay': return Icons.sentiment_satisfied;
      case 'Sad': return Icons.sentiment_dissatisfied;
      case 'Stressed': return Icons.psychology;
      case 'Tired': return Icons.bedtime;
      case 'Annoyed': return Icons.sentiment_very_dissatisfied;
      default: return Icons.emoji_emotions;
    }
  }
  
  Color getMoodColor(String mood) {
    switch (mood) {
      // 好心情 - 暖色调
      case 'Excited': return Colors.orange;       // 明亮的橙色
      case 'Happy': return Colors.amber;          // 温暖的琥珀色
      case 'Grateful': return Colors.deepOrange;  // 深橙色
      case 'Okay': return Colors.lightGreen;      // 浅绿色

      // 坏心情 - 冷色调
      case 'Sad': return Colors.blue;             // 蓝色
      case 'Stressed': return Colors.indigo;      // 靛蓝色
      case 'Tired': return Colors.blueGrey;       // 蓝灰色
      case 'Annoyed': return Colors.purple;       // 紫色
      default: return Colors.grey;
    }
  }

  Color _getScoreColor(double score, ColorScheme colorScheme) {
    if (score >= 3.0) {
      // 暖色调
      if (score >= 4.5) return Colors.deepOrange; // 非常好
      if (score >= 4.0) return Colors.orange;     // 很好
      return Colors.amber;                         // 好
    } else {
      // 冷色调
      if (score >= 2.0) return Colors.blue;       // 一般
      if (score >= 1.0) return Colors.indigo;     // 不太好
      return Colors.purple;                        // 需要关注
    }
  }

  double _getMoodValue(String mood) {
    switch (mood) {
      case 'Excited': return 5.0;
      case 'Happy': return 4.0;
      case 'Grateful': return 4.0;
      case 'Okay': return 3.0;
      case 'Sad': return 2.0;
      case 'Stressed': return 1.0;
      case 'Tired': return 1.5;
      case 'Annoyed': return 1.5;
      default: return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final itemState = context.watch<ItemState>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Office Leafy',
          style: GoogleFonts.baloo2(
            fontSize: 32,
            color: const Color(0xFF1B5E20),
            letterSpacing: 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFFFCF5),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Color(0xFF1B5E20),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${itemState.leafyHeartsCount}',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Color(0xFF1B5E20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFCF5),
              Color(0xFFFFFCF5),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Growth stage card
                Container(
                  height: screenHeight * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Plant image
                      Hero(
                        tag: 'plant_image',
                        child: Container(
                          height: screenHeight * 0.32,
                          width: screenHeight * 0.32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/plants/stage${itemState.growthStage > 2 ? 2 : itemState.growthStage}_${itemState.currentEmotion.toLowerCase()}.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                // Leafy says 容器
                const SizedBox(height: 6),
                FadeTransition(
                  opacity: _animation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B5E20).withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Stack(
                        children: [
                          // 云朵装饰
                          Positioned(
                            top: -6,
                            left: 12,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: 12,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -6,
                            left: 18,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -8,
                            right: 18,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B5E20).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.eco,
                                        size: 14,
                                        color: const Color(0xFF1B5E20),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Leafy says:",
                                      style: GoogleFonts.nunito(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1B5E20),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    displayedQuote,
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1B5E20),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                
                // Mood tracker
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "How do you feel today?",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                          shadows: [
                            Shadow(
                              color: colorScheme.primary.withOpacity(0.2),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // 心情按钮布局
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          // 第一行：高分心情
                          _buildMoodButton("Excited", Icons.celebration),
                          _buildMoodButton("Happy", Icons.sentiment_very_satisfied),
                          _buildMoodButton("Grateful", Icons.favorite),
                          _buildMoodButton("Okay", Icons.sentiment_satisfied),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // 第二行：低分心情
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildMoodButton("Sad", Icons.sentiment_dissatisfied),
                          _buildMoodButton("Tired", Icons.bedtime),
                          _buildMoodButton("Annoyed", Icons.sentiment_very_dissatisfied),
                          _buildMoodButton("Stressed", Icons.psychology),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 今日心情得分卡片
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Today\'s Mood Score',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            // 计算今日平均得分
                            final today = DateTime.now();
                            final todayMoods = itemState.moodLog.entries.where((entry) {
                              final date = entry.key;
                              return date.year == today.year &&
                                     date.month == today.month &&
                                     date.day == today.day;
                            }).map((entry) => entry.value['mood'] as String).toList();

                            if (todayMoods.isEmpty) {
                              return Text(
                                'No mood recorded yet today',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              );
                            }

                            // 计算平均分
                            final totalScore = todayMoods
                                .map((mood) => _getMoodValue(mood))
                                .reduce((a, b) => a + b);
                            final averageScore = totalScore / todayMoods.length;

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      averageScore.toStringAsFixed(1),
                                      style: GoogleFonts.nunito(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w600,
                                        color: _getScoreColor(averageScore, colorScheme),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '/ 5.0',
                                      style: GoogleFonts.nunito(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${todayMoods.length} mood${todayMoods.length > 1 ? 's' : ''} recorded today',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 添加版本号
                Text(
                  "© 2025 Office Leafy. All rights reserved.",
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, -6),
              spreadRadius: 2,
            )
          ],
        ),
        padding: EdgeInsets.only(
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(
              context: context,
              icon: Icons.home,
              label: 'Home',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              isSelected: true,
            ),
            _buildNavButton(
              context: context,
              icon: Icons.insights,
              label: 'Trends',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmotionTrendPage()),
                );
              },
              isSelected: false,
            ),
            _buildNavButton(
              context: context,
              icon: Icons.shopping_bag,
              label: 'Shop',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShopPage()),
                );
              },
              isSelected: false,
            ),
            _buildNavButton(
              context: context,
              icon: Icons.local_florist,
              label: 'Plant',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlantGrowthPage()),
                );
              },
              isSelected: false,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isSelected,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodButton(String mood, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showMoodNoteDialog(mood),
        borderRadius: BorderRadius.circular(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: getMoodColor(mood).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: getMoodColor(mood),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mood,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: getMoodColor(mood).withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

