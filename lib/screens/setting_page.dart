import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_state.dart';
import 'emotion_trend_page.dart';
import 'shop_page.dart';
import 'plant_growth_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Reset All Data',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to reset all data? This action cannot be undone.',
          style: TextStyle(
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
              context.read<ItemState>().resetAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'All data has been reset',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Color(0xFF1B5E20),
                ),
              );
            },
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Future<void> _sendFeedback() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'officeleafy@gmail.com',
      queryParameters: {
        'subject': 'Office Leafy Feedback',
        'body': 'Hi Leafy,\n\nI would like to provide feedback about the app:\n\n'
      }
    );

    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      debugPrint('Could not launch email: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF1B5E20),
          ),
        ),
        backgroundColor: const Color(0xFFFFFCF5),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.feedback,
                color: Color(0xFF1B5E20),
              ),
            ),
            title: const Text(
              'Send Feedback',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text('Help us improve Office Leafy'),
            onTap: _sendFeedback,
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.refresh,
                color: Colors.red,
              ),
            ),
            title: const Text(
              'Reset All Data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text('Clear all progress and start over'),
            onTap: () => _showResetConfirmationDialog(context),
          ),
          const Divider(),
          // 可以在这里添加更多设置选项
        ],
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
}
