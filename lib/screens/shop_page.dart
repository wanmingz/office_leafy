import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_state.dart';
import 'emotion_trend_page.dart';
import 'plant_growth_page.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  void _showPurchaseDialog(BuildContext context, String itemType) {
    final itemState = context.read<ItemState>();
    final leafyHeartsCount = itemState.leafyHeartsCount;
    final cost = itemType == 'water' ? 1 : 2;

    if (leafyHeartsCount < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Not enough Leafy Hearts to purchase ${itemType}!',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Purchase ${itemType == 'water' ? 'Water' : 'Fertilizer'}',
          style: const TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Cost: $cost Leafy Heart${cost > 1 ? 's' : ''}',
          style: const TextStyle(
            color: Color(0xFF1B5E20),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (itemType == 'water') {
                itemState.purchaseWater();
                itemState.useLeafyHearts(1);
              } else {
                itemState.purchaseFertilizer();
                itemState.useLeafyHearts(2);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${itemType == 'water' ? 'Water' : 'Fertilizer'} purchased successfully!',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF1B5E20),
                ),
              );
            },
            child: const Text(
              'Purchase',
              style: TextStyle(
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUseItemDialog(BuildContext context, String itemType) {
    final itemState = context.read<ItemState>();
    final count = itemType == 'water' ? itemState.waterCount : itemState.fertilizerCount;
    
    if (count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No ${itemType} available',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Use ${itemType == 'water' ? 'Water' : 'Fertilizer'}',
          style: const TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to use ${itemType}?',
          style: const TextStyle(
            color: Color(0xFF1B5E20),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (itemType == 'water') {
                itemState.useWater();
              } else {
                itemState.useFertilizer();
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${itemType} used successfully',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF1B5E20),
                ),
              );
            },
            child: const Text(
              'Use',
              style: TextStyle(
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemState = context.watch<ItemState>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop & Bag'),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${itemState.leafyHeartsCount}',
                  style: TextStyle(
                    color: colorScheme.primary,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop Section
              Text(
                'Shop',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Water
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.water_drop,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Water',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'You have: ${itemState.waterCount}',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Price: ',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Icon(
                                      Icons.favorite,
                                      color: colorScheme.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '1',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _showPurchaseDialog(context, 'water'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Buy'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Fertilizer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.eco,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Fertilizer',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'You have: ${itemState.fertilizerCount}',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Price: ',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Icon(
                                      Icons.favorite,
                                      color: colorScheme.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '2',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _showPurchaseDialog(context, 'fertilizer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Buy'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Bag Section
              Text(
                'Your Items',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Water
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.water_drop,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Water',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Available: ${itemState.waterCount}',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => _showUseItemDialog(context, 'water'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Use'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Fertilizer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.eco,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Fertilizer',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Available: ${itemState.fertilizerCount}',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => _showUseItemDialog(context, 'fertilizer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Use'),
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
              onPressed: () {},
              isSelected: true,
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
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
} 