import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Admin Home — Ringkasan operasional gudang untuk admin.
// Berisi: greeting, KPI utama, alert stok rendah, antrian persetujuan,
// dan aktivitas terbaru. Semua tombol interaktif.
// ─────────────────────────────────────────────────────────────────────────────

class AdminHomePage extends StatefulWidget {
  final void Function(int) onNavigate;

  const AdminHomePage({
    super.key,
    required this.onNavigate,
  });

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const _adminName = 'Ahmad Fauzi';
  static const _adminRole = 'Super Admin · Gudang IPAL Pusat';

  // KPI ringkas
  final List<Map<String, dynamic>> _kpis = const [
    {
      'label': 'Permintaan Pending',
      'value': '14',
      'icon': Icons.pending_actions_rounded,
      'color': AppTheme.statusPending,
      'tabIndex': 1,
    },
    {
      'label': 'Disetujui Hari Ini',
      'value': '32',
      'icon': Icons.check_circle_rounded,
      'color': AppTheme.statusApproved,
      'tabIndex': 1,
    },
    {
      'label': 'Stok Rendah',
      'value': '7',
      'icon': Icons.warning_amber_rounded,
      'color': AppTheme.statusRejected,
      'tabIndex': 2,
    },
    {
      'label': 'Total Item',
      'value': '180',
      'icon': Icons.inventory_2_rounded,
      'color': AppTheme.primary,
      'tabIndex': 2,
    },
  ];

  // Alert stok rendah
  final List<Map<String, dynamic>> _lowStock = const [
    {'name': 'Pompa Submersible 2 HP', 'code': 'P03', 'stock': 2, 'min': 5},
    {'name': 'Membran RO 4040', 'code': 'F04', 'stock': 1, 'min': 4},
    {'name': 'MCB 3 Phase 16A', 'code': 'K05', 'stock': 3, 'min': 10},
    {'name': 'UV Sterilizer 11W', 'code': 'F28', 'stock': 0, 'min': 3},
  ];

  // Aktivitas terbaru
  final List<Map<String, dynamic>> _recentActivity = const [
    {
      'type': 'approve',
      'title': 'Permintaan disetujui',
      'desc': 'REQ-20260420-001 · Pompa Submersible 7.5 kW',
      'time': '5 menit lalu',
    },
    {
      'type': 'restock',
      'title': 'Restock masuk',
      'desc': 'Media Karbon Aktif · 40 kg dari PT. Aquatech',
      'time': '23 menit lalu',
    },
    {
      'type': 'reject',
      'title': 'Permintaan ditolak',
      'desc': 'REQ-20260420-007 · alasan: stok tidak cukup',
      'time': '1 jam lalu',
    },
    {
      'type': 'user',
      'title': 'User baru terdaftar',
      'desc': 'Bagas Pratama (Operator IPAL)',
      'time': '2 jam lalu',
    },
    {
      'type': 'transfer',
      'title': 'Transfer antar gudang',
      'desc': 'Blower Roots 1 HP · 2 unit dari Gudang A → Gudang C',
      'time': '3 jam lalu',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ───────────────────────── helpers ─────────────────────────
  Color _activityColor(String type) {
    switch (type) {
      case 'approve':
        return AppTheme.statusApproved;
      case 'reject':
        return AppTheme.statusRejected;
      case 'restock':
        return AppTheme.primary;
      case 'user':
        return AppTheme.primaryLight;
      case 'transfer':
        return AppTheme.primaryDark;
      default:
        return Colors.grey;
    }
  }

  IconData _activityIcon(String type) {
    switch (type) {
      case 'approve':
        return Icons.check_circle_rounded;
      case 'reject':
        return Icons.cancel_rounded;
      case 'restock':
        return Icons.south_rounded;
      case 'user':
        return Icons.person_add_rounded;
      case 'transfer':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.circle;
    }
  }

  void _snack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: color ?? AppTheme.primary,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _refresh() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _snack('Data berhasil diperbarui');
  }

  void _openProfile() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ProfilePeekSheet(
        name: _adminName,
        role: _adminRole,
        onLogout: () {
          Navigator.pop(ctx);
          _snack('Keluar dari akun...', color: Colors.redAccent);
        },
      ),
    );
  }

  void _openNotifications() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _NotificationSheet(),
    );
  }

  void _openPendingApprovals() {
    HapticFeedback.mediumImpact();
    _snack('Membuka 14 permintaan pending');
  }

  void _onKpiTap(Map<String, dynamic> k) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _KpiDetailSheet(
        label: k['label'] as String,
        value: k['value'] as String,
        icon: k['icon'] as IconData,
        color: k['color'] as Color,
        onAction: () {
          Navigator.pop(ctx);
          _snack('Membuka detail: ${k['label']}');
        },
      ),
    );
  }

  void _onLowStockTap(Map<String, dynamic> s) {
    HapticFeedback.selectionClick();
    final stock = s['stock'] as int;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Row(
          children: [
            Icon(
              stock == 0
                  ? Icons.error_rounded
                  : Icons.warning_amber_rounded,
              color: stock == 0
                  ? AppTheme.statusRejected
                  : AppTheme.statusPending,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                s['name'] as String,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kode: ${s['code']}'),
            const SizedBox(height: 4),
            Text('Stok saat ini: $stock'),
            Text('Minimum stok: ${s['min']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _snack('Permintaan restock untuk ${s['name']} dibuat',
                  color: AppTheme.statusApproved);
            },
            icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
            label: const Text('Restock'),
          ),
        ],
      ),
    );
  }

  void _onActivityTap(Map<String, dynamic> a) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _activityColor(a['type'] as String)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _activityIcon(a['type'] as String),
                    color: _activityColor(a['type'] as String),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    a['title'] as String,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(a['desc'] as String,
                style: const TextStyle(fontSize: 13, height: 1.4)),
            const SizedBox(height: 6),
            Text(a['time'] as String,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _snack('Membuka detail aktivitas');
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Lihat Detail Lengkap'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewAllLowStock() {
    HapticFeedback.selectionClick();
    _snack('Membuka semua stok rendah (7 item)');
  }

  // ───────────────────────── build ─────────────────────────
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: RefreshIndicator(
          onRefresh: _refresh,
          color: AppTheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: [
              // Header gradient + greeting
              SliverToBoxAdapter(child: _buildHeader()),

              // KPI grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverGrid.builder(
                  itemCount: _kpis.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.55,
                  ),
                  itemBuilder: (context, i) {
                    final k = _kpis[i];
                    return _kpiCard(
                      label: k['label'] as String,
                      value: k['value'] as String,
                      icon: k['icon'] as IconData,
                      color: k['color'] as Color,
                      onTap: () => _onKpiTap(k),
                    );
                  },
                ),
              ),

              // Alert stok rendah header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppTheme.statusRejected, size: 20),
                      const SizedBox(width: 6),
                      const Text(
                        'Peringatan Stok Rendah',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _viewAllLowStock,
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Low stock list
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _lowStock.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) =>
                        _lowStockCard(_lowStock[i]),
                  ),
                ),
              ),

              // Aktivitas terbaru header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded,
                          color: AppTheme.primary, size: 20),
                      const SizedBox(width: 6),
                      const Text(
                        'Aktivitas Terbaru',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _snack('Membuka log aktivitas'),
                        child: const Text(
                          'Riwayat',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Activity list
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList.separated(
                  itemCount: _recentActivity.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _activityCard(_recentActivity[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── widgets ─────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _openProfile,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'AF',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _openProfile,
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $_adminName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            _adminRole,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        tooltip: 'Notifikasi',
                        onPressed: _openNotifications,
                        icon: const Icon(
                          Icons.notifications_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IgnorePointer(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppTheme.statusRejected,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openPendingApprovals,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.white,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(text: 'Ada '),
                                TextSpan(
                                  text: '14 permintaan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' menunggu persetujuan Anda hari ini.',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withOpacity(0.15),
        highlightColor: color.withOpacity(0.05),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Spacer(),
                  Icon(Icons.trending_up_rounded,
                      color: color.withOpacity(0.6), size: 16),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lowStockCard(Map<String, dynamic> s) {
    final stock = s['stock'] as int;
    final empty = stock == 0;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _onLowStockTap(s),
        borderRadius: BorderRadius.circular(16),
        splashColor: (empty
                ? AppTheme.statusRejected
                : AppTheme.statusPending)
            .withOpacity(0.15),
        child: Ink(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (empty
                      ? AppTheme.statusRejected
                      : AppTheme.statusPending)
                  .withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: empty
                          ? AppTheme.bgRejected
                          : AppTheme.bgPending,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      empty ? 'KOSONG' : 'RENDAH',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: empty
                            ? AppTheme.statusRejected
                            : AppTheme.statusPending,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    s['code'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                s['name'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sisa $stock · Min ${s['min']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityCard(Map<String, dynamic> a) {
    final type = a['type'] as String;
    final color = _activityColor(type);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _onActivityTap(a),
        borderRadius: BorderRadius.circular(14),
        splashColor: color.withOpacity(0.12),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_activityIcon(type), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a['title'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a['desc'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    a['time'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet: Notifikasi
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationSheet extends StatelessWidget {
  const _NotificationSheet();

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, dynamic>>[
      {
        'icon': Icons.fact_check_rounded,
        'color': AppTheme.statusPending,
        'title': '14 permintaan menunggu',
        'sub': 'Beberapa request baru perlu disetujui',
        'time': '5 mnt',
      },
      {
        'icon': Icons.warning_amber_rounded,
        'color': AppTheme.statusRejected,
        'title': 'Stok UV Sterilizer 11W habis',
        'sub': 'Segera lakukan restock',
        'time': '1 jam',
      },
      {
        'icon': Icons.south_rounded,
        'color': AppTheme.primary,
        'title': 'Restock masuk',
        'sub': 'Media Karbon Aktif · 40 kg',
        'time': '2 jam',
      },
    ];
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (ctx, controller) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifikasi',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  Text(
                    'Tandai dibaca',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: controller,
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx2, i) {
                  final n = items[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          (n['color'] as Color).withOpacity(0.15),
                      child: Icon(n['icon'] as IconData,
                          color: n['color'] as Color),
                    ),
                    title: Text(n['title'] as String,
                        style:
                            const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(n['sub'] as String),
                    trailing: Text(n['time'] as String,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                    onTap: () {
                      Navigator.pop(ctx2);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Membuka: ${n['title']}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet: KPI detail
// ─────────────────────────────────────────────────────────────────────────────
class _KpiDetailSheet extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onAction;

  const _KpiDetailSheet({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onAction,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Buka Detail'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet: Profile peek
// ─────────────────────────────────────────────────────────────────────────────
class _ProfilePeekSheet extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback onLogout;

  const _ProfilePeekSheet({
    required this.name,
    required this.role,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primary.withOpacity(0.15),
                child: const Text(
                  'AF',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              role,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            _ProfileTile(
              icon: Icons.person_rounded,
              label: 'Profil Saya',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Membuka profil'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            _ProfileTile(
              icon: Icons.settings_rounded,
              label: 'Pengaturan',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Membuka pengaturan'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            _ProfileTile(
              icon: Icons.logout_rounded,
              label: 'Keluar',
              color: Colors.redAccent,
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: c),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color ?? AppTheme.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
