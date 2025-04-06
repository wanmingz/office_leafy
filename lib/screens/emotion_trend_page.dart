import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'shop_page.dart';
import 'plant_growth_page.dart';
import 'package:google_fonts/google_fonts.dart';


class EmotionTrendPage extends StatefulWidget {
  const EmotionTrendPage({super.key});

  @override
  State<EmotionTrendPage> createState() => _EmotionTrendPageState();
}

class _EmotionTrendPageState extends State<EmotionTrendPage> {
  String _selectedMonth = 'This Month';
  final List<String> _months = [
    'This Week',
    'This Month',
    'Last Month',
    'Previous Month',
    'Last 3 Months',
    'Last 6 Months',
    'Last 12 Months',
  ];

  @override
  Widget build(BuildContext context) {
    final itemState = context.watch<ItemState>();
    final moodLog = itemState.moodLog;
    final leafyHeartsCount = itemState.leafyHeartsCount;
    final colorScheme = Theme.of(context).colorScheme;

    // 按日期对心情数据进行分组
    Map<DateTime, List<Map<String, dynamic>>> groupedMoodData = {};
    DateTime now = DateTime.now();
    DateTime startDate;

    // 根据选择的时间范围设置开始日期
    switch (_selectedMonth) {
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Last Month':
        startDate = DateTime(now.year, now.month - 1, 1);
        break;
      case 'Previous Month':
        startDate = DateTime(now.year, now.month - 2, 1);
        break;
      case 'Last 3 Months':
        startDate = DateTime(now.year, now.month - 2, 1);
        break;
      case 'Last 6 Months':
        startDate = DateTime(now.year, now.month - 5, 1);
        break;
      case 'Last 12 Months':
        startDate = DateTime(now.year, now.month - 11, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    for (var entry in moodLog.entries) {
      if (entry.key.isBefore(startDate)) continue;
      DateTime date = DateTime(entry.key.year, entry.key.month, entry.key.day);
      if (!groupedMoodData.containsKey(date)) {
        groupedMoodData[date] = [];
      }
      groupedMoodData[date]!.add({
        'mood': entry.value['mood'],
        'note': entry.value['note'],
        'timestamp': entry.key,
      });
    }

    // 计算每种心情的出现次数
    final moodCounts = <String, int>{};
    for (var entry in moodLog.entries) {
      final mood = entry.value['mood'] as String;
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }

    // 按照分数从高到低排序心情
    final sortedMoods = moodCounts.keys.toList()
      ..sort((a, b) => _getMoodValue(b).compareTo(_getMoodValue(a)));

    // 计算总心情记录数
    int totalMoods = moodCounts.values.fold(0, (sum, count) => sum + count);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Emotion Trends',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B5E20),
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
                  '$leafyHeartsCount',
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
                            final todayMoods = moodLog.entries.where((entry) {
                              final date = entry.key;
                              return date.year == today.year &&
                                     date.month == today.month &&
                                     date.day == today.day;
                            }).toList();

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

                            // 按时间排序
                            todayMoods.sort((a, b) => b.key.compareTo(a.key));

                            // 计算平均分
                            final totalScore = todayMoods
                                .map((entry) => _getMoodValue(entry.value['mood'] as String))
                                .reduce((a, b) => a + b);
                            final averageScore = totalScore / todayMoods.length;

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // 左侧：今日心情得分
                                    Column(
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
                                    ),
                                    // 右侧：今日心情记录
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Today\'s Moods:',
                                          style: GoogleFonts.nunito(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...todayMoods.map((entry) {
                                          final mood = entry.value['mood'] as String;
                                          final time = entry.key;
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    color: _getMoodColor(mood),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  mood,
                                                  style: GoogleFonts.nunito(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: _getMoodColor(mood),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _formatTime(time),
                                                  style: GoogleFonts.nunito(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: colorScheme.onSurface.withOpacity(0.6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ],
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
                // 添加月份选择器
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Time Range',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _selectedMonth,
                        items: _months.map((String month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(
                              month,
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedMonth = newValue;
                            });
                          }
                        },
                        underline: Container(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 心情分布卡片
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
                          'Mood Distribution',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: totalMoods > 0
                              ? BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: 100,
                                    barGroups: sortedMoods.map((mood) {
                                      double percentage = (moodCounts[mood]! / totalMoods) * 100;
                                      return BarChartGroupData(
                                        x: sortedMoods.indexOf(mood),
                                        barRods: [
                                          BarChartRodData(
                                            toY: percentage,
                                            color: _getMoodColor(mood).withOpacity(0.8),
                                            width: 20,
                                            borderRadius: BorderRadius.circular(4),
                                            backDrawRodData: BackgroundBarChartRodData(
                                              show: true,
                                              color: Colors.grey.withOpacity(0.1),
                                              toY: 100,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            String mood = sortedMoods.elementAt(value.toInt());
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                mood,
                                                style: GoogleFonts.nunito(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: _getMoodColor(mood),
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              '${value.toInt()}%',
                                              style: GoogleFonts.nunito(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                    ),
                                    gridData: FlGridData(
                                      show: false,
                                    ),
                                    borderData: FlBorderData(
                                      show: false,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'No mood data yet',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: moodCounts.entries.map((entry) {
                            return _buildLegendItem(
                              entry.key,
                              entry.value,
                              _getMoodColor(entry.key),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 添加折线图
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 16),
                      child: Text(
                        'Mood Trend',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: totalMoods > 0
                          ? LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() >= groupedMoodData.length) return const Text('');
                                        DateTime date = groupedMoodData.keys.elementAt(value.toInt());
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            _formatDate(date),
                                            style: GoogleFonts.nunito(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: GoogleFonts.nunito(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: groupedMoodData.entries.map((entry) {
                                      double averageMoodValue = 0;
                                      if (entry.value.isNotEmpty) {
                                        averageMoodValue = entry.value.map((moodData) {
                                          return _getMoodValue(moodData['mood'] as String);
                                        }).reduce((a, b) => a + b) / entry.value.length;
                                      }
                                      return FlSpot(
                                        groupedMoodData.keys.toList().indexOf(entry.key).toDouble(),
                                        averageMoodValue,
                                      );
                                    }).toList(),
                                    isCurved: true,
                                    color: Theme.of(context).colorScheme.primary,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Text(
                                'No mood data yet',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 心情历史记录
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mood History',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (groupedMoodData.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No mood records yet',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ),
                          )
                        else
                          ...groupedMoodData.entries.map((dateEntry) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    _formatDate(dateEntry.key),
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                ...dateEntry.value.map((moodEntry) {
                                  return _buildMoodHistoryItem(
                                    moodEntry['mood'] as String,
                                    moodEntry['note'] as String,
                                    moodEntry['timestamp'] as DateTime,
                                    colorScheme,
                                  );
                                }).toList(),
                                const Divider(),
                              ],
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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

  Widget _buildLegendItem(String mood, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$mood ($count)',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodHistoryItem(
    String mood,
    String note,
    DateTime timestamp,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getMoodColor(mood).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getMoodIcon(mood),
              color: _getMoodColor(mood),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mood,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getMoodColor(mood),
                  ),
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    note,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatTime(timestamp),
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Mood Record'),
                    content: const Text('Are you sure you want to delete this mood record?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          final itemState = context.read<ItemState>();
                          itemState.deleteMood(timestamp);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getMoodColor(String mood) {
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

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case 'Excited': return Icons.celebration;
      case 'Happy': return Icons.sentiment_very_satisfied;
      case 'Grateful': return Icons.favorite;
      case 'Okay': return Icons.sentiment_satisfied;
      case 'Sad': return Icons.sentiment_dissatisfied;
      case 'Stressed': return Icons.psychology;
      case 'Tired': return Icons.bedtime;
      case 'Annoyed': return Icons.sentiment_very_dissatisfied;
      default: return Icons.emoji_emotions;
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
}