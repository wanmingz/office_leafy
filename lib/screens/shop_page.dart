import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_state.dart';
import 'emotion_trend_page.dart';
import 'bag_page.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  void _handlePurchase(BuildContext context, String item, int price) {
    final itemState = context.read<ItemState>();
    
    if (itemState.leafyHeartsCount >= price) {
      itemState.useLeafyHearts(price);
      if (item == 'Water') {
        itemState.purchaseWater();
      } else if (item == 'Fertilizer') {
        itemState.purchaseFertilizer();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully purchased $item!'),
          backgroundColor: const Color(0xFF1B5E20),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough Leafy Hearts!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPurchaseDialog(BuildContext context, String item, int price) {
    final itemState = context.read<ItemState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Purchase $item?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will cost $price Leafy Heart${price > 1 ? 's' : ''}.'),
            const SizedBox(height: 8),
            Text('You have ${itemState.leafyHeartsCount} Leafy Heart${itemState.leafyHeartsCount > 1 ? 's' : ''}.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handlePurchase(context, item, price);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
            ),
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemState = context.watch<ItemState>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shop',
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
            _buildShopItem(
              context,
              'Water',
              'Give your plant some water',
              Icons.water_drop,
              Colors.blue,
              1,
              itemState.waterCount,
            ),
            const SizedBox(height: 16),
            _buildShopItem(
              context,
              'Fertilizer',
              'Help your plant grow faster',
              Icons.eco,
              Colors.green,
              2,
              itemState.fertilizerCount,
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
                MaterialPageRoute(builder: (context) => const EmotionTrendPage()),
              ),
              isSelected: false,
            ),
            _buildNavButton(
              context: context,
              icon: Icons.shopping_bag,
              label: 'Shop',
              onPressed: () {},
              isSelected: true,
            ),
            _buildNavButton(
              context: context,
              icon: Icons.backpack,
              label: 'Bag',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BagPage()),
              ),
              isSelected: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    int price,
    int count,
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
          onTap: () => _showPurchaseDialog(context, title, price),
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: const Color(0xFF1B5E20),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$price',
                            style: const TextStyle(
                              color: Color(0xFF1B5E20),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You have: x$count',
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w500,
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