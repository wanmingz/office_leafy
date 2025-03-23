import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'emotion_trend_page.dart';
import 'shop_page.dart';
import 'bag_page.dart';

class CalendarPage extends StatefulWidget {
  final Map<DateTime, Map<String, dynamic>> moodLog;
  final int leafyHeartsCount;
  final Function(int)? onLeafyHeartsUpdate;

  const CalendarPage(
    this.moodLog, 
    {
      required this.leafyHeartsCount,
      this.onLeafyHeartsUpdate,
      super.key
    }
  );
  
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();
  
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  List<MapEntry<DateTime, Map<String, dynamic>>> getFilteredEntries() {
    return widget.moodLog.entries.where((entry) {
      return entry.key.year == _selectedDate.year && 
             entry.key.month == _selectedDate.month;
    }).toList()
      ..sort((a, b) => b.key.compareTo(a.key));
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredEntries = getFilteredEntries();
      
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mood Calendar',
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
      body: Column(
        children: [
          // 年月选择器
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month - 1,
                      );
                    });
                  },
                ),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      DateFormat('MMMM yyyy').format(_selectedDate),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          // 情绪记录列表
          Expanded(
            child: filteredEntries.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sentiment_neutral,
                        size: 64,
                        color: colorScheme.primary.withOpacity(0.5),
                        shadows: [
                          Shadow(
                            color: colorScheme.primary.withOpacity(0.2),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No moods recorded for this month",
                        style: TextStyle(
                          fontSize: 18,
                          color: colorScheme.primary.withOpacity(0.7),
                          shadows: [
                            Shadow(
                              color: colorScheme.primary.withOpacity(0.2),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Try selecting a different month",
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.primary.withOpacity(0.5),
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
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, index) {
                    final entry = filteredEntries[index];
                    final date = entry.key;
                    final data = entry.value;
                    final mood = data['mood'] as String;
                    final note = data['note'] as String;
                    
                    return GestureDetector(
                      onLongPress: () => _showDeleteConfirmationDialog(context, date, mood, note),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: getMoodColor(mood).withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: getMoodColor(mood).withOpacity(0.2),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        )
                                      ],
                                    ),
                                    child: Icon(
                                      getMoodIcon(mood),
                                      color: getMoodColor(mood),
                                      size: 24,
                                      shadows: [
                                        Shadow(
                                          color: getMoodColor(mood).withOpacity(0.2),
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          DateFormat('MMMM d, y').format(date),
                                          style: TextStyle(
                                            fontSize: 16,
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
                                        Text(
                                          DateFormat('h:mm a').format(date),
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
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: getMoodColor(mood).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      mood,
                                      style: TextStyle(
                                        color: getMoodColor(mood),
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          Shadow(
                                            color: getMoodColor(mood).withOpacity(0.2),
                                            offset: const Offset(0, 1),
                                            blurRadius: 2,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    color: Colors.red.withOpacity(0.7),
                                    onPressed: () => _showDeleteConfirmationDialog(context, date, mood, note),
                                  ),
                                ],
                              ),
                            ),
                            if (note.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer.withOpacity(0.05),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                                ),
                                child: Text(
                                  note,
                                  style: TextStyle(
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
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmotionTrendPage(
                  widget.moodLog,
                  leafyHeartsCount: widget.leafyHeartsCount,
                )),
              ),
              isSelected: false,
            ),
            _buildNavButton(
              context: context,
              icon: Icons.calendar_month,
              label: 'Calendar',
              onPressed: () {},
              isSelected: true,
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

  void _showDeleteConfirmationDialog(BuildContext context, DateTime date, String mood, String note) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Mood Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this mood record?'),
            const SizedBox(height: 8),
            Text('Mood: $mood'),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Note: $note'),
            ],
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              setState(() {
                widget.moodLog.removeWhere((key, value) => 
                  key == date && 
                  value['mood'] == mood && 
                  value['note'] == note
                );
              });
              Navigator.pop(context);
            },
            isDestructiveAction: true,
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}