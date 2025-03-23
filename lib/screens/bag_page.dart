import 'package:flutter/material.dart';
import 'emotion_trend_page.dart';
import 'calendar_page.dart';
import 'shop_page.dart';

class BagPage extends StatefulWidget {
  final int leafyHearts;
  final Map<DateTime, Map<String, dynamic>> moodLog;
  final int waterCount;
  final int fertilizerCount;
  final Function(String) onItemUsed;

  const BagPage({
    super.key,
    required this.leafyHearts,
    required this.moodLog,
    required this.waterCount,
    required this.fertilizerCount,
    required this.onItemUsed,
  });

  @override
  State<BagPage> createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {

  @override
  void initState() {
    super.initState();
  }

  void _useWater() {
    if (widget.waterCount > 0) {
      setState(() {
        widget.onItemUsed('Water');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('使用了水！'),
          backgroundColor: Color(0xFF1B5E20),
        ),
      );
    }
  }

  void _useFertilizer() {
    if (widget.fertilizerCount > 0) {
      setState(() {
        widget.onItemUsed('Fertilizer');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('使用了肥料！'),
          backgroundColor: Color(0xFF1B5E20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bag',
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
                  '${widget.leafyHearts}',
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildItemCard(
                    context,
                    'Water',
                    'Give your plant some water',
                    Icons.water_drop,
                    Colors.blue,
                    widget.waterCount,
                    _useWater,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildItemCard(
                    context,
                    'Fertilizer',
                    'Help your plant grow faster',
                    Icons.eco,
                    Colors.green,
                    widget.fertilizerCount,
                    _useFertilizer,
                  ),
                ),
              ],
            ),
          ],
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
                widget.onItemUsed('Water');
                widget.onItemUsed('Fertilizer');
                widget.onItemUsed('LeafyHearts');
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
                  leafyHeartsCount: widget.leafyHearts,
                )),
              ),
              isSelected: false,
            ),
            _buildNavButton(
              context: context,
              icon: Icons.calendar_month,
              label: 'Calendar',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarPage(
                  widget.moodLog,
                  leafyHeartsCount: widget.leafyHearts,
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
                  leafyHearts: widget.leafyHearts,
                  moodLog: widget.moodLog,
                  onLeafyHeartsUpdate: (newValue) {
                    widget.onItemUsed('LeafyHearts');
                  },
                  onItemPurchased: (item) {},
                  waterCount: widget.waterCount,
                  fertilizerCount: widget.fertilizerCount,
                )),
              ),
              isSelected: false,
            ),
            _buildNavButton(
              context: context,
              icon: Icons.backpack,
              label: 'Bag',
              onPressed: () {},
              isSelected: true,
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

  Widget _buildItemCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    int count,
    VoidCallback onUse,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: count > 0 ? onUse : null,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'x$count',
                    style: const TextStyle(
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 