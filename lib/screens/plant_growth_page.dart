import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_state.dart';

class PlantGrowthPage extends StatelessWidget {
  const PlantGrowthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final itemState = context.watch<ItemState>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Growth'),
        centerTitle: true,
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
                        'Current Growth Stage',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
          style: TextStyle(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
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
        final remainingWater = 2 - itemState.waterUsed;
        return remainingWater > 0
            ? 'Need $remainingWater more water(s)'
            : 'Water requirements met';
      case 2:
        return 'Water requirements met';
      case 3:
        return 'Water requirements met';
      default:
        return 'Water requirements met';
    }
  }

  String _getFertilizerRequirement(ItemState itemState) {
    switch (itemState.plantGrowthStage) {
      case 1:
        final remainingFertilizer = 1 - itemState.fertilizerUsed;
        return remainingFertilizer > 0
            ? 'Need $remainingFertilizer more fertilizer(s)'
            : 'Fertilizer requirements met';
      case 2:
        return 'Fertilizer requirements met';
      case 3:
        return 'Fertilizer requirements met';
      default:
        return 'Fertilizer requirements met';
    }
  }
} 