import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_state.dart';
import 'emotion_trend_page.dart';
import 'shop_page.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantGrowthPage extends StatelessWidget {
  const PlantGrowthPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final itemState = context.watch<ItemState>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Plant Growth',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B5E20),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${itemState.leafyHeartsCount}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
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
              // Plant growth stage card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Growth Stage: ${itemState.plantGrowthStage}',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildGrowthStage(
                            context,
                            stage: 1,
                            currentStage: itemState.plantGrowthStage,
                            title: 'Seedling',
                          ),
                          _buildGrowthStage(
                            context,
                            stage: 2,
                            currentStage: itemState.plantGrowthStage,
                            title: 'Growing',
                          ),
                          _buildGrowthStage(
                            context,
                            stage: 3,
                            currentStage: itemState.plantGrowthStage,
                            title: 'Mature',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Growth requirements card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Growth Requirements',
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRequirementItem(
                        context,
                        icon: Icons.water_drop,
                        title: 'Water Requirements',
                        description: _getWaterRequirement(itemState),
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _buildRequirementItem(
                        context,
                        icon: Icons.eco,
                        title: 'Fertilizer Requirements',
                        description: _getFertilizerRequirement(itemState),
                        color: Colors.green,
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
              onPressed: () {},
              isSelected: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthStage(
    BuildContext context, {
    required int stage,
    required int currentStage,
    required String title,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = stage <= currentStage;

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? colorScheme.primary : colorScheme.surface,
            border: Border.all(
              color: isActive ? colorScheme.primary : colorScheme.outline,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.eco,
            color: isActive ? colorScheme.onPrimary : colorScheme.outline,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.nunito(
            color: isActive ? colorScheme.primary : colorScheme.outline,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title == 'Water Requirements' ? 'Water' : 'Fertilizer',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.nunito(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getWaterRequirement(ItemState itemState) {
    switch (itemState.plantGrowthStage) {
      case 1:
        final remainingWater = 1 - itemState.waterUsed;
        return remainingWater > 0
            ? '$remainingWater more'
            : 'Done';
      case 2:
        final remainingWater = 5 - itemState.waterUsed;
        return remainingWater > 0
            ? '$remainingWater more'
            : 'Done';
      case 3:
        return 'Done';
      default:
        return 'Done';
    }
  }

  String _getFertilizerRequirement(ItemState itemState) {
    switch (itemState.plantGrowthStage) {
      case 1:
        final remainingFertilizer = 1 - itemState.fertilizerUsed;
        return remainingFertilizer > 0
            ? '$remainingFertilizer more'
            : 'Done';
      case 2:
        final remainingFertilizer = 3 - itemState.fertilizerUsed;
        return remainingFertilizer > 0
            ? '$remainingFertilizer more'
            : 'Done';
      case 3:
        return 'Done';
      default:
        return 'Done';
    }
  }
} 