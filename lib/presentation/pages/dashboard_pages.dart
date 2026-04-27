import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'approval_pages.dart';
import 'home_pages.dart';
import 'item_management_pages.dart';
import 'profile_pages.dart';
import 'package:warehouse_admin_1/presentation/pages/report_pages.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    AdminHomePage(onNavigate: _changeTab),
    ApprovalPage(onNavigate: _changeTab),
    const ItemManagementPage(),
    ReportsPage(onNavigate: _changeTab),
    AdminProfilePage(onNavigate: _changeTab),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(Icons.dashboard_rounded, 'Beranda'),
    _NavItem(Icons.fact_check_rounded, 'Approval'),
    _NavItem(Icons.inventory_2_rounded, 'Stok'),
    _NavItem(Icons.bar_chart_rounded, 'Laporan'),
    _NavItem(Icons.person_rounded, 'Profil'),
  ];

  void _changeTab(int index) {
    if (index < 0 || index >= _pages.length) return;

    setState(() {
      _currentIndex = index;
    });
  }

  void _onTapNav(int index) {
    HapticFeedback.selectionClick();

    if (_currentIndex == index) return;

    _changeTab(index);
  }

  Future<bool> _onBackPressed() async {
    if (_currentIndex != 0) {
      _changeTab(0);
      return false;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar App?'),
        content: const Text('Yakin mau keluar?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, -3),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(
              _navItems.length,
              (index) => Expanded(
                child: _buildNavItem(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _onTapNav(index),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 8,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? AppTheme.primary.withOpacity(0.10)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: isSelected
                  ? AppTheme.primary
                  : Colors.grey.shade500,
            ),
            const SizedBox(height: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.primary
                        : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}