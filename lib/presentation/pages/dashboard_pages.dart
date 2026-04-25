import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:warehouse_admin_1/presentation/pages/report_pages.dart';
import 'app_theme.dart';
import 'home_pages.dart';
import 'approval_pages.dart';
import 'item_management_pages.dart';
import 'profile_pages.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DashboardScreen — Container utama berisi 5 tab.
//
// Setiap halaman anak (Home, Approval, Inventory, Reports, Profile) punya
// Scaffold + AppBar sendiri, jadi dashboard ini SENGAJA tidak menambah AppBar
// atau FloatingActionButton di level container, supaya tidak bertumpuk.
//
// Yang ditingkatkan:
//   • Bottom navigation: ripple, scale icon, animasi label, haptic feedback
//   • Long-press tab → menampilkan label sebagai tooltip snackbar
//   • Tap tab yang sama → memanggil scroll-to-top callback bila tersedia
//   • Tombol back fisik: dari tab non-Beranda kembali ke Beranda dulu,
//     baru memunculkan dialog konfirmasi keluar.
//   • IndexedStack tetap dipakai supaya state tiap tab terjaga
//     (filter, scroll position, form, dsb).
// ─────────────────────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 0;

  late final List<Widget> _pages = [
    AdminHomePage(onNavigate: _goToTab),
    ApprovalPage(onNavigate: _goToTab),
    const ItemManagementPage(),
    ReportsPage(onNavigate: _goToTab),
    AdminProfilePage(onNavigate: _goToTab),
  ];

  void _goToTab(int i) {
    if (i < 0 || i >= _pages.length) return;
    setState(() => _index = i);
  }

  final List<_NavItem> _items = const [
    _NavItem(Icons.dashboard_rounded, 'Beranda'),
    _NavItem(Icons.fact_check_rounded, 'Persetujuan'),
    _NavItem(Icons.inventory_2_rounded, 'Inventaris'),
    _NavItem(Icons.bar_chart_rounded, 'Laporan'),
    _NavItem(Icons.person_rounded, 'Profil'),
  ];

  void _onTabTapped(int i) {
    if (_index == i) {
      // Sudah berada di tab ini — beri umpan balik halus.
      HapticFeedback.selectionClick();
      _showSnack('Anda sedang di halaman ${_items[i].label}');
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.primary,
          duration: const Duration(milliseconds: 1400),
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Keluar Aplikasi?'),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari GudangPro Admin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppTheme.primary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(96, 44),
            ),
            onPressed: () => Navigator.pop(ctx, true),
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
      onWillPop: () async {
        if (_index != 0) {
          _onTabTapped(0);
          return false;
        }
        return _confirmExit();
      },
      child: Scaffold(
        // Tidak ada AppBar di sini — setiap halaman anak sudah punya AppBar
        // atau header gradient sendiri.
        body: IndexedStack(index: _index, children: _pages),
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
            color: AppTheme.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final selected = _index == i;
              final item = _items[i];
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onTabTapped(i),
                    onLongPress: () {
                      HapticFeedback.mediumImpact();
                      _showSnack('Pintasan: ${item.label}');
                    },
                    borderRadius: BorderRadius.circular(14),
                    splashColor: AppTheme.primary.withOpacity(0.15),
                    highlightColor: AppTheme.primary.withOpacity(0.06),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: EdgeInsets.symmetric(
                        horizontal: selected ? 14 : 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primary.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            scale: selected ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 220),
                            child: Icon(
                              item.icon,
                              color: selected
                                  ? AppTheme.primary
                                  : Colors.grey.shade400,
                              size: 22,
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: selected
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Text(
                                      item.label,
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
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
