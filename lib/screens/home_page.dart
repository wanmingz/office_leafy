import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    'Happy': [
      "Your happiness is contagious! 🌟",
      "Keep spreading those positive vibes! ✨",
      "Your joy makes the world brighter! 🌈",
      "Stay as amazing as you are! 🌺"
    ],
    'Excited': [
      "Your enthusiasm is inspiring! 🚀",
      "Keep that energy flowing! ⚡",
      "Your excitement is contagious! 🎉",
      "Let's make this day amazing! 🌟"
    ],
    'Loved': [
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
    ]
  };

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
        title: Row(
          children: [
            Icon(
              getMoodIcon(mood),
              color: getMoodColor(mood),
            ),
            const SizedBox(width: 8),
            Text(
              'Add a note for "$mood"',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: TextField(
          controller: _noteController,
          decoration: InputDecoration(
            hintText: 'Why do you feel this way? (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              recordMoodWithNote(mood, _noteController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: getMoodColor(mood).withOpacity(0.8),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                color: const Color(0xFF1B5E20),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You got 1 Leafy Heart!',
                style: TextStyle(
                  fontSize: 16,
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
                color: const Color(0xFF1B5E20),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Daily Limit Reached',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your mood has been recorded, but you\'ve reached your daily limit of 3 Leafy Hearts. Your plant will be waiting for more love tomorrow!',
                style: TextStyle(
                  fontSize: 16,
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
      case 'Loved': return Icons.favorite;
      case 'Okay': return Icons.sentiment_satisfied;
      case 'Sad': return Icons.sentiment_dissatisfied;
      case 'Stressed': return Icons.psychology;
      default: return Icons.emoji_emotions;
    }
  }
  
  Color getMoodColor(String mood) {
    switch (mood) {
      case 'Happy': return Colors.amber;
      case 'Excited': return Colors.orange;
      case 'Loved': return Colors.red;
      case 'Okay': return Colors.green;
      case 'Sad': return Colors.blue;
      case 'Stressed': return Colors.purple;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final itemState = context.watch<ItemState>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Office Leafy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF1B5E20),
          ),
        ),
        backgroundColor: const Color(0xFFFFFCF5),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: const Color(0xFF1B5E20),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${itemState.leafyHeartsCount}',
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Growth stage card
                Container(
                  height: screenHeight * 0.44,
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
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Growth stage indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(2, (index) => 
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index < itemState.plantGrowthStage 
                                ? colorScheme.primary 
                                : colorScheme.primaryContainer.withOpacity(0.3),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                          )
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Plant image
                      Hero(
                        tag: 'plant_image',
                        child: SizedBox(
                          height: screenHeight * 0.32,
                          width: screenHeight * 0.32,
                          child: Image.asset(
                            'assets/plants/stage${itemState.plantGrowthStage}_${itemState.currentEmotion.toLowerCase()}.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Work mode message
                      Text(
                        getWorkModeMessage(),
                        style: TextStyle(
                          fontSize: 15,
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
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Plant's message (comfort quote)
                if (displayedQuote.isNotEmpty)
                  FadeTransition(
                    opacity: _animation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Stack(
                        children: [
                          // Speech bubble
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.eco,
                                      size: 20,
                                      color: colorScheme.primary,
                                      shadows: [
                                        Shadow(
                                          color: colorScheme.primary.withOpacity(0.2),
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                        )
                                      ],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Plant says:",
                                      style: TextStyle(
                                        fontSize: 14,
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
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  displayedQuote,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    color: colorScheme.onPrimaryContainer,
                                    shadows: [
                                      Shadow(
                                        color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                                        offset: const Offset(0, 1),
                                        blurRadius: 2,
                                      )
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          // Speech bubble tail
                          Positioned(
                            left: 36,
                            bottom: -6,
                            child: Transform.rotate(
                              angle: -0.5,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                
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
                        style: TextStyle(
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildMoodButton("Excited", Icons.celebration, Colors.orange),
                          _buildMoodButton("Happy", Icons.sentiment_very_satisfied, Colors.amber),
                          _buildMoodButton("Loved", Icons.favorite, Colors.red),
                          _buildMoodButton("Okay", Icons.sentiment_satisfied, Colors.green),
                          _buildMoodButton("Sad", Icons.sentiment_dissatisfied, Colors.blue),
                          _buildMoodButton("Stressed", Icons.psychology, Colors.purple),
                        ],
                      ),
                    ],
                  ),
                ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? const Color(0xFF1B5E20) : Theme.of(context).colorScheme.primary,
                shadows: [
                  Shadow(
                    color: (isSelected ? const Color(0xFF1B5E20) : Theme.of(context).colorScheme.primary).withOpacity(0.2),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  )
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF1B5E20) : Theme.of(context).colorScheme.primary,
                  shadows: [
                    Shadow(
                      color: (isSelected ? const Color(0xFF1B5E20) : Theme.of(context).colorScheme.primary).withOpacity(0.2),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodButton(String mood, IconData icon, Color color) {
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
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mood,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

