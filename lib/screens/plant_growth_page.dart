import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_state.dart';
import 'emotion_trend_page.dart';
import 'shop_page.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantGrowthPage extends StatefulWidget {
  const PlantGrowthPage({super.key});

  @override
  State<PlantGrowthPage> createState() => _PlantGrowthPageState();
}

class _PlantGrowthPageState extends State<PlantGrowthPage> {
  int? previousStage;

  @override
  void initState() {
    super.initState();
    final itemState = context.read<ItemState>();
    previousStage = itemState.growthStage;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final itemState = context.watch<ItemState>();
    if (itemState.growthStage > (previousStage ?? 0)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGrowthAlert(context, itemState.growthStage);
      });
      previousStage = itemState.growthStage;
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
              // Plant image
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      'assets/plants/stage${itemState.growthStage}.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Plant growth stage card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Growth Stage: ${itemState.growthStage}',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildGrowthStages(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Growth requirements card
              _buildGrowthRequirementsCard(context),
              const SizedBox(height: 24),
              
              // Use items card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bag',
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildUseItem(
                        context,
                        'Water',
                        itemState.waterCount,
                        itemState.waterCount > 0 ? () {
                          _showUseItemDialog(context, 'water');
                        } : null,
                      ),
                      const SizedBox(height: 16),
                      _buildUseItem(
                        context,
                        'Fertilizer',
                        itemState.fertilizerCount,
                        itemState.fertilizerCount > 0 ? () {
                          _showUseItemDialog(context, 'fertilizer');
                        } : null,
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

  Widget _buildGrowthRequirementsCard(BuildContext context) {
    final itemState = context.watch<ItemState>();
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            _buildRequirementRow(
              context,
              Icons.water_drop,
              'Water',
              _getWaterRequirement(itemState),
              itemState.usedWaterCount,
            ),
            const SizedBox(height: 8),
            _buildRequirementRow(
              context,
              Icons.eco,
              'Fertilizer',
              _getFertilizerRequirement(itemState),
              itemState.usedFertilizerCount,
            ),
            const SizedBox(height: 8),
            _buildRequirementRow(
              context,
              Icons.mood,
              'Mood Record Days',
              _getMoodRequirement(itemState),
              _getUniqueMoodDays(itemState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementRow(
    BuildContext context,
    IconData icon,
    String label,
    int total,
    int remaining,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: $remaining/$total',
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  int _getWaterRequirement(ItemState itemState) {
    switch (itemState.growthStage) {
      case 0:
        return 1;
      case 1:
        return 3;
      case 2:
        return 5;
      default:
        return 0;
    }
  }

  int _getFertilizerRequirement(ItemState itemState) {
    switch (itemState.growthStage) {
      case 0:
        return 1;
      case 1:
        return 2;
      case 2:
        return 3;
      default:
        return 0;
    }
  }

  int _getUniqueMoodDays(ItemState itemState) {
    final uniqueDays = itemState.moodLog.keys.map((date) => 
      DateTime(date.year, date.month, date.day)
    ).toSet().length;
    return uniqueDays;
  }

  int _getMoodRequirement(ItemState itemState) {
    switch (itemState.growthStage) {
      case 0:
        return 3;
      case 1:
        return 5;
      case 2:
        return 7;
      default:
        return 0;
    }
  }

  Widget _buildUseItem(
    BuildContext context,
    String itemName,
    int itemCount,
    VoidCallback? onPressed,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              itemName == 'Water' ? Icons.water_drop : Icons.local_florist,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '$itemName: $itemCount',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: onPressed == null 
                ? Colors.grey.withOpacity(0.1)
                : Theme.of(context).colorScheme.primary,
            foregroundColor: onPressed == null 
                ? Colors.grey
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Use'),
        ),
      ],
    );
  }

  Widget _buildGrowthStages(BuildContext context) {
    return Consumer<ItemState>(
      builder: (context, itemState, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGrowthStage(
              context,
              stage: 0,
              currentStage: itemState.growthStage,
              title: 'Seed',
            ),
            _buildGrowthStage(
              context,
              stage: 1,
              currentStage: itemState.growthStage,
              title: 'Sprout',
            ),
            _buildGrowthStage(
              context,
              stage: 2,
              currentStage: itemState.growthStage,
              title: 'Growing',
            ),
            _buildGrowthStage(
              context,
              stage: 3,
              currentStage: itemState.growthStage,
              title: 'Mature',
            ),
          ],
        );
      },
    );
  }

  void _showGrowthAlert(BuildContext context, int newStage) {
    String message = '';
    switch (newStage) {
      case 1:
        message = 'Your plant has sprouted! 🌱';
        break;
      case 2:
        message = 'Your plant has grown! 🌿';
        break;
      case 3:
        message = 'Your plant has matured! 🌳';
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco,
              color: const Color(0xFF1B5E20),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Plant Growth Update!',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B5E20),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'OK',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B5E20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUseItemDialog(BuildContext context, String itemType) {
    final itemState = Provider.of<ItemState>(context, listen: false);
    final count = itemType == 'water' ? itemState.waterCount : itemState.fertilizerCount;
    
    if (count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No $itemType available',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Use ${itemType == 'water' ? 'Water' : 'Fertilizer'}',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B5E20),
          ),
        ),
        content: Text(
          'Are you sure you want to use $itemType?',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B5E20),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B5E20),
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
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$itemType used successfully',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: const Color(0xFF1B5E20),
                ),
              );
            },
            child: Text(
              'Use',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B5E20),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 