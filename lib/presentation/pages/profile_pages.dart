import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'stock_check_pages.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Admin Profile — Identitas admin, pengaturan sistem, dan menu administrasi.
//
// Versi terhubung antar-halaman:
//   • Optional `onNavigate(int tabIndex)` untuk lompat tab (0 Beranda,
//     1 Persetujuan, 2 Inventaris, 3 Laporan, 4 Profil).
//   • "Pintasan Admin" row di atas: Cek Stok, Update Bulanan, Persetujuan,
//     Inventaris.
//   • Menu Audit Log buka bottom sheet log (demo).
//   • Menu Tentang Aplikasi buka dialog versi.
//   • Menu lainnya tetap menampilkan dialog "dalam pengembangan".
//   • Avatar tap untuk edit profil dengan animasi & pulse.
// ─────────────────────────────────────────────────────────────────────────────

class AdminProfilePage extends StatefulWidget {
  final void Function(int tabIndex)? onNavigate;

  const AdminProfilePage({super.key, this.onNavigate});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _maintenanceMode = false;
  bool _autoApproveLow = false;
  bool _emailReport = true;

  String _adminName = 'Ahmad Fauzi';
  String _adminPhone = '+62 813-9876-5432';
  String _adminOffice = 'PT. Tirta Aquatech Mandiri';
  String _adminPosition = 'Super Admin · Gudang IPAL Pusat';
  final String _adminEmail = 'admin@gudangpro.id';

  String get _initials {
    final parts = _adminName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  // Menu khas admin
  final List<Map<String, dynamic>> _menuItems = const [
    {
      'title': 'Manajemen User',
      'subtitle': 'Tambah, ubah, atau nonaktifkan akun pengguna',
      'icon': Icons.group_outlined,
      'color': AppTheme.primary,
      'key': 'users',
    },
    {
      'title': 'Manajemen Gudang',
      'subtitle': 'Atur lokasi & cabang gudang',
      'icon': Icons.warehouse_outlined,
      'color': AppTheme.primaryDark,
      'key': 'warehouse',
    },
    {
      'title': 'Hak Akses & Peran',
      'subtitle': 'Konfigurasi role-based access control',
      'icon': Icons.lock_person_rounded,
      'color': AppTheme.primaryLight,
      'key': 'roles',
    },
    {
      'title': 'Audit Log',
      'subtitle': 'Catatan aktivitas seluruh user',
      'icon': Icons.fact_check_outlined,
      'color': AppTheme.statusApproved,
      'key': 'audit',
    },
    {
      'title': 'Backup & Restore',
      'subtitle': 'Cadangkan data atau pulihkan dari backup',
      'icon': Icons.backup_outlined,
      'color': AppTheme.statusInfo,
      'key': 'backup',
    },
    {
      'title': 'Integrasi Sistem',
      'subtitle': 'Hubungkan dengan ERP atau marketplace',
      'icon': Icons.integration_instructions_outlined,
      'color': AppTheme.statusPending,
      'key': 'integration',
    },
    {
      'title': 'Tentang Aplikasi',
      'subtitle': 'GudangPro Admin v1.0.0',
      'icon': Icons.info_outline_rounded,
      'color': Color(0xFF546E7A),
      'key': 'about',
    },
  ];

  // ─────────────────────────── Routing & cross-nav ───────────────────────────
  void _goToTab(int tab, String fallbackMsg) {
    HapticFeedback.selectionClick();
    if (widget.onNavigate != null) {
      widget.onNavigate!(tab);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fallbackMsg),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  void _openStockCheck() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StockCheckPage()),
    );
  }

  void _openMonthlyUpdate() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MonthlyStockUpdatePage()),
    );
  }

  void _onMenuTap(Map<String, dynamic> m) {
    final key = m['key'] as String;
    switch (key) {
      case 'audit':
        _showAuditLogSheet();
        break;
      case 'about':
        _showAboutDialog();
        break;
      default:
        _showInDevDialog(m['title'] as String);
    }
  }

  void _showAuditLogSheet() {
    HapticFeedback.selectionClick();
    final logs = [
      {
        'time': '08:42',
        'user': 'Bagas Pratama',
        'action': 'Mengirim permintaan REQ-20260420-001',
        'icon': Icons.send_rounded,
        'color': AppTheme.primary,
      },
      {
        'time': '09:01',
        'user': 'Anda',
        'action': 'Login ke panel admin',
        'icon': Icons.login_rounded,
        'color': AppTheme.statusApproved,
      },
      {
        'time': '09:18',
        'user': 'Anda',
        'action': 'Menyetujui REQ-20260420-002 (24 unit filter)',
        'icon': Icons.check_circle_rounded,
        'color': AppTheme.statusApproved,
      },
      {
        'time': '10:05',
        'user': 'Anda',
        'action': 'Update stok bulanan kategori "Pompa"',
        'icon': Icons.edit_calendar_rounded,
        'color': AppTheme.primary,
      },
      {
        'time': '10:34',
        'user': 'Dewi Lestari',
        'action': 'Menambah item baru: Seal Mekanis 25mm',
        'icon': Icons.add_box_rounded,
        'color': AppTheme.statusInfo,
      },
      {
        'time': '11:21',
        'user': 'Anda',
        'action': 'Menolak REQ-20260419-008 (alasan: anggaran)',
        'icon': Icons.cancel_rounded,
        'color': AppTheme.statusRejected,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scroll) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    Icon(Icons.fact_check_outlined,
                        color: AppTheme.primary, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Audit Log Hari Ini',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'Aktivitas terbaru pengguna & admin (demo).',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade100),
              Expanded(
                child: ListView.separated(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 18, color: Colors.grey.shade100),
                  itemBuilder: (ctx, i) {
                    final l = logs[i];
                    return Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: (l['color'] as Color).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(l['icon'] as IconData,
                              color: l['color'] as Color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l['action'] as String,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${l['user']} · ${l['time']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.admin_panel_settings_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'GudangPro Admin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Text(
                'Versi 1.0.0  •  Build 2026.04',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF607D8B),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Sistem manajemen inventaris IPAL untuk admin gudang. '
                'Pantau stok, setujui permintaan, dan kelola laporan dari satu tempat.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInDevDialog(String name) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.construction_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 18),
              const Text(
                'Sedang Dalam Tahap Pengembangan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fitur "$name" akan segera tersedia di pembaruan berikutnya. Terima kasih atas kesabaran Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

  void _showEditProfileSheet() {
    HapticFeedback.selectionClick();
    final nameCtrl = TextEditingController(text: _adminName);
    final phoneCtrl = TextEditingController(text: _adminPhone);
    final officeCtrl = TextEditingController(text: _adminOffice);
    final positionCtrl = TextEditingController(text: _adminPosition);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scroll) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Edit Profil Admin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppTheme.primary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade100),
              Expanded(
                child: ListView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _initials,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.statusApproved,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _field(nameCtrl, 'Nama Lengkap',
                        Icons.person_outline_rounded),
                    const SizedBox(height: 14),
                    _field(phoneCtrl, 'Nomor Telepon',
                        Icons.phone_outlined,
                        keyboard: TextInputType.phone),
                    const SizedBox(height: 14),
                    _field(officeCtrl, 'Kantor / Perusahaan',
                        Icons.business_outlined),
                    const SizedBox(height: 14),
                    _field(positionCtrl, 'Posisi / Jabatan',
                        Icons.badge_outlined),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _adminName = nameCtrl.text.trim();
                            _adminPhone = phoneCtrl.text.trim();
                            _adminOffice = officeCtrl.text.trim();
                            _adminPosition = positionCtrl.text.trim();
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profil admin diperbarui.'),
                              backgroundColor: AppTheme.statusApproved,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType? keyboard, int maxLines = 1}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.primary),
      ),
    );
  }

  void _showLogoutDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar Admin?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari panel admin?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: AppTheme.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusRejected,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _showEditProfileSheet,
                        child: Stack(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _initials,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppTheme.statusApproved,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.shield_rounded,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _adminName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _adminPosition,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _adminEmail,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Stats khas admin
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _stat('3', 'Gudang'),
                          _divider(),
                          _stat('24', 'Staff'),
                          _divider(),
                          _stat('847', 'Transaksi'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text('Profil Admin'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded,
                    color: Colors.white, size: 20),
                onPressed: _showEditProfileSheet,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Pintasan Admin ─────────────────────────────────
                  _sectionTitle('Pintasan Admin'),
                  const SizedBox(height: 10),
                  _cardContainer(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _shortcut(
                              icon: Icons.fact_check_rounded,
                              label: 'Cek Stok',
                              onTap: _openStockCheck,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _shortcut(
                              icon: Icons.edit_calendar_rounded,
                              label: 'Update\nBulanan',
                              onTap: _openMonthlyUpdate,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _shortcut(
                              icon: Icons.fact_check_outlined,
                              label: 'Persetujuan',
                              onTap: () => _goToTab(1,
                                  'Buka tab "Persetujuan" di bawah.'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _shortcut(
                              icon: Icons.inventory_2_outlined,
                              label: 'Inventaris',
                              onTap: () => _goToTab(2,
                                  'Buka tab "Inventaris" di bawah.'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _sectionTitle('Pengaturan Sistem'),
                  const SizedBox(height: 10),
                  _cardContainer(
                    child: Column(
                      children: [
                        _toggle(
                          icon: Icons.build_rounded,
                          color: AppTheme.statusPending,
                          title: 'Mode Maintenance',
                          subtitle:
                              'Sementara nonaktifkan akses untuk semua user',
                          value: _maintenanceMode,
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            setState(() => _maintenanceMode = v);
                            if (v) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Mode Maintenance aktif. Pengguna tidak dapat mengakses sistem.'),
                                  backgroundColor: AppTheme.statusPending,
                                ),
                              );
                            }
                          },
                        ),
                        Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                            indent: 60),
                        _toggle(
                          icon: Icons.auto_awesome_rounded,
                          color: AppTheme.primary,
                          title: 'Auto-Approve Permintaan Kecil',
                          subtitle: 'Setujui otomatis permintaan ≤ 5 unit',
                          value: _autoApproveLow,
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            setState(() => _autoApproveLow = v);
                          },
                        ),
                        Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                            indent: 60),
                        _toggle(
                          icon: Icons.email_rounded,
                          color: AppTheme.statusApproved,
                          title: 'Laporan Email Harian',
                          subtitle:
                              'Kirim ringkasan harian otomatis ke email admin',
                          value: _emailReport,
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            setState(() => _emailReport = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Manajemen & Administrasi'),
                  const SizedBox(height: 10),
                  _cardContainer(
                    child: Column(
                      children: _menuItems.asMap().entries.map((e) {
                        final idx = e.key;
                        final m = e.value;
                        return Column(
                          children: [
                            _menuTile(
                              icon: m['icon'] as IconData,
                              color: m['color'] as Color,
                              title: m['title'] as String,
                              subtitle: m['subtitle'] as String,
                              isFirst: idx == 0,
                              isLast: idx == _menuItems.length - 1,
                              onTap: () => _onMenuTap(m),
                            ),
                            if (idx < _menuItems.length - 1)
                              Divider(
                                height: 1,
                                color: Colors.grey.shade100,
                                indent: 60,
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text(
                        'Keluar dari Admin',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.statusRejected.withOpacity(0.1),
                        foregroundColor: AppTheme.statusRejected,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: AppTheme.statusRejected,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'GudangPro Admin v1.0.0  •  © 2026',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shortcut({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.primaryPale.withOpacity(0.4),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: AppTheme.primary.withOpacity(0.15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryDark,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryDark,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _cardContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _toggle({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.primary.withOpacity(0.3);
              }
              return Colors.grey.shade200;
            }),
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool isFirst,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(18) : Radius.zero,
        bottom: isLast ? const Radius.circular(18) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}
