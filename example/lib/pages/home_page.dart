import 'package:flutter/material.dart';
import '../controller/swip_controller.dart';
import 'swip_page.dart';
import '../screens/diagnostics_screen.dart';

enum NavigationItem {
  swipSdk,
  diagnostics,
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SwipController _swipController;
  NavigationItem _currentItem = NavigationItem.swipSdk;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _userId = 'example_user';

  @override
  void initState() {
    super.initState();
    _swipController = SwipController(userId: _userId);
  }

  @override
  void dispose() {
    _swipController.dispose();
    super.dispose();
  }

  void _onNavigationItemSelected(NavigationItem item) {
    setState(() {
      _currentItem = item;
    });
    Navigator.pop(context); // Close drawer after selection
  }

  Widget _buildCurrentPage() {
    switch (_currentItem) {
      case NavigationItem.swipSdk:
        return SwipPage(
          controller: _swipController,
          onMenuPressed: openDrawer,
        );
      case NavigationItem.diagnostics:
        return DiagnosticsScreen(
          storageService: _swipController.storage,
          onMenuPressed: openDrawer,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: _buildCurrentPage(),
    );
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: Column(
        children: [
          // Drawer Header with Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'SWIP Demo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Drawer Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // SWIP SDK
                _buildDrawerItem(
                  context: context,
                  icon: Icons.favorite_outline,
                  selectedIcon: Icons.favorite,
                  title: 'SWIP SDK',
                  subtitle: 'Wellness Impact Protocol',
                  color: Colors.green,
                  isSelected: _currentItem == NavigationItem.swipSdk,
                  onTap: () =>
                      _onNavigationItemSelected(NavigationItem.swipSdk),
                ),

                const SizedBox(height: 8),
                const Divider(height: 1),

                // Diagnostics
                _buildDrawerItem(
                  context: context,
                  icon: Icons.storage_outlined,
                  selectedIcon: Icons.storage,
                  title: 'Database Diagnostics',
                  subtitle: 'Storage & sync status',
                  color: Colors.blue,
                  isSelected: _currentItem == NavigationItem.diagnostics,
                  onTap: () =>
                      _onNavigationItemSelected(NavigationItem.diagnostics),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    String? subtitle,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final itemColor = color ?? colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected ? itemColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? itemColor.withOpacity(0.15)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    color: isSelected
                        ? itemColor
                        : colorScheme.onSurface.withOpacity(0.7),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? itemColor : colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: itemColor,
                      borderRadius: BorderRadius.circular(2),
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

