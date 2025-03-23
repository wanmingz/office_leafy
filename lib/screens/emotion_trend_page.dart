import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'calendar_page.dart';
import 'shop_page.dart';
import 'bag_page.dart';

class EmotionTrendPage extends StatefulWidget {
  final Map<DateTime, Map<String, dynamic>> moodLog;
  final int leafyHeartsCount;
  final Function(int)? onLeafyHeartsUpdate;
  
  const EmotionTrendPage(
    this.moodLog,
    {
      required this.leafyHeartsCount,
      this.onLeafyHeartsUpdate,
      super.key
    }
  );
  
  @override
  _EmotionTrendPageState createState() => _EmotionTrendPageState();
}

class _EmotionTrendPageState extends State<EmotionTrendPage> {
  String _selectedTimeframe = 'Week';
  
  Color getMoodColor(String mood) {
    switch (mood) {
      case 'Happy': return Colors.amber;
      case 'Excited': return Colors.orange;
      case 'Loved': return Colors.red;
      case 'Great': return Colors.green;
      case 'Sad': return Colors.blue;
      case 'Stressed': return Colors.purple;
      default: return Colors.grey;
    }
  }
  
  IconData getMoodIcon(String mood) {
    switch (mood) {
      case 'Happy': return Icons.sentiment_very_satisfied;
      case 'Excited': return Icons.celebration;
      case 'Loved': return Icons.favorite;
      case 'Great': return Icons.thumb_up;
      case 'Sad': return Icons.sentiment_dissatisfied;
      case 'Stressed': return Icons.psychology;
      default: return Icons.emoji_emotions;
    }
  }

  // Get mood score (positive moods have higher scores)
  int getMoodScore(String mood) {
    switch (mood) {
      case 'Happy': return 5;
      case 'Excited': return 5;
      case 'Loved': return 5;
      case 'Great': return 5;
      case 'Sad': return 2;
      case 'Stressed': return 1;
      default: return 3;
    }
  }
  
  // Filter moods based on selected timeframe
  List<MapEntry<DateTime, Map<String, dynamic>>> getFilteredMoods() {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedTimeframe) {
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'Year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }
    
    return widget.moodLog.entries
        .where((entry) => entry.key.isAfter(startDate))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key)); // Sort by date ascending
  }
  
  // Count mood frequency
  Map<String, int> getMoodFrequency() {
    final filteredMoods = getFilteredMoods();
    final Map<String, int> frequency = {
      'Happy': 0,
      'Excited': 0,
      'Loved': 0,
      'Great': 0,
      'Sad': 0,
      'Stressed': 0,
    };
    
    for (var entry in filteredMoods) {
      final mood = entry.value['mood'] as String;
      frequency[mood] = (frequency[mood] ?? 0) + 1;
    }
    
    return frequency;
  }
  
  // Calculate average mood score
  double getAverageMoodScore() {
    final filteredMoods = getFilteredMoods();
    if (filteredMoods.isEmpty) return 0;
    
    int totalScore = 0;
    for (var entry in filteredMoods) {
      final mood = entry.value['mood'] as String;
      totalScore += getMoodScore(mood);
    }
    
    return totalScore / filteredMoods.length;
  }
  
  // Generate chart data
  List<FlSpot> getMoodChartData() {
    final filteredMoods = getFilteredMoods();
    if (filteredMoods.isEmpty) return [];
    
    // Group by day
    Map<String, List<MapEntry<DateTime, Map<String, dynamic>>>> groupedByDay = {};
    
    for (var entry in filteredMoods) {
      final dateStr = DateFormat('yyyy-MM-dd').format(entry.key);
      if (!groupedByDay.containsKey(dateStr)) {
        groupedByDay[dateStr] = [];
      }
      groupedByDay[dateStr]!.add(entry);
    }
    
    // Calculate average mood score per day
    List<FlSpot> spots = [];
    int dayIndex = 0;
    
    List<String> sortedDates = groupedByDay.keys.toList()..sort();
    
    for (String dateStr in sortedDates) {
      final entries = groupedByDay[dateStr]!;
      double totalScore = 0;
      
      for (var entry in entries) {
        final mood = entry.value['mood'] as String;
        totalScore += getMoodScore(mood);
      }
      
      double avgScore = totalScore / entries.length;
      spots.add(FlSpot(dayIndex.toDouble(), avgScore));
      dayIndex++;
    }
    
    return spots;
  }
  
  String getMoodTrend() {
    List<FlSpot> spots = getMoodChartData();
    if (spots.length < 2) return "Not enough data";
    
    double firstValue = spots.first.y;
    double lastValue = spots.last.y;
    
    if (lastValue > firstValue + 0.5) return "Your mood is improving! 🌟";
    if (firstValue > lastValue + 0.5) return "Your mood has been declining lately. 💭";
    return "Your mood has been relatively stable. ✨";
  }
  
  String getMostFrequentMood() {
    final frequency = getMoodFrequency();
    if (frequency.isEmpty) return "No data";
    
    String mostFrequent = frequency.keys.first;
    int maxCount = frequency.values.first;
    
    frequency.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = mood;
      }
    });
    
    return mostFrequent;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final moodFrequency = getMoodFrequency();
    final avgScore = getAverageMoodScore();
    final mostFrequentMood = getMostFrequentMood();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emotion Trends',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF1B5E20), // 深绿色
          ),
        ),
        backgroundColor: const Color(0xFFFFFCF5), // 温暖的米白色
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
                  '${widget.leafyHeartsCount}',
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeframe selector
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimeframeButton('Week', _selectedTimeframe == 'Week'),
                    _buildTimeframeButton('Month', _selectedTimeframe == 'Month'),
                    _buildTimeframeButton('Year', _selectedTimeframe == 'Year'),
                  ],
                ),
              ),
              // Summary cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: "Average Mood",
                        value: "${avgScore.toStringAsFixed(1)} / 5.0",
                        icon: Icons.trending_up,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        title: "Most Frequent",
                        value: mostFrequentMood,
                        icon: getMoodIcon(mostFrequentMood),
                        color: getMoodColor(mostFrequentMood),
                      ),
                    ),
                  ],
                ),
              ),
              // Mood chart
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mood Trend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: getMoodChartData(),
                              isCurved: true,
                              color: colorScheme.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: colorScheme.primary.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Mood distribution
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mood Distribution',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 200,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: PieChart(
                              PieChartData(
                                sections: moodFrequency.entries.map((entry) {
                                  final mood = entry.key;
                                  final count = entry.value;
                                  
                                  return PieChartSectionData(
                                    value: count.toDouble(),
                                    title: '${count.toString()}',
                                    radius: 80,
                                    color: getMoodColor(mood),
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    badgeWidget: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        getMoodIcon(mood),
                                        color: getMoodColor(mood),
                                        size: 16,
                                      ),
                                    ),
                                    badgePositionPercentageOffset: 1.2,
                                  );
                                }).toList(),
                                sectionsSpace: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: moodFrequency.entries.map((entry) {
                                final mood = entry.key;
                                final count = entry.value;
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: getMoodColor(mood),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          mood,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        count.toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.1),
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
              isSelected: false,
            ),
            _buildNavButton(
              context: context,
              icon: Icons.insights,
              label: 'Trends',
              onPressed: () {},
              isSelected: true,
            ),
            _buildNavButton(
              context: context,
              icon: Icons.calendar_month,
              label: 'Calendar',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarPage(
                  widget.moodLog,
                  leafyHeartsCount: widget.leafyHeartsCount,
                )),
              ),
              isSelected: false,
            ),
            _buildNavButton(
              context: context,
              icon: Icons.shopping_bag,
              label: 'Shop',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShopPage(
                  leafyHearts: widget.leafyHeartsCount,
                  moodLog: widget.moodLog,
                  onLeafyHeartsUpdate: widget.onLeafyHeartsUpdate ?? (newValue) {},
                  onItemPurchased: (item) {},
                  waterCount: 0,
                  fertilizerCount: 0,
                )),
              ),
              isSelected: false,
            ),
            _buildNavButton(
              context: context,
              icon: Icons.backpack,
              label: 'Bag',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BagPage(
                  leafyHearts: widget.leafyHeartsCount,
                  moodLog: widget.moodLog,
                  waterCount: 0,
                  fertilizerCount: 0,
                  onItemUsed: (item) {},
                )),
              ),
              isSelected: false,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimeframeButton(String label, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedTimeframe = label),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.primary : colorScheme.primary.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              shadows: [
                Shadow(
                  color: colorScheme.primary.withOpacity(0.2),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                  shadows: [
                    Shadow(
                      color: color.withOpacity(0.2),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.7),
              shadows: [
                Shadow(
                  color: colorScheme.onSurface.withOpacity(0.2),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                )
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
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
}