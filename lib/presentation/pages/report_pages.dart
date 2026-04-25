import 'package:flutter/material.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Reports — Halaman laporan & analitik gudang untuk admin.
// Menampilkan ringkasan harian/mingguan/bulanan, distribusi kategori,
// dan tombol ekspor (PDF / Excel).
// ─────────────────────────────────────────────────────────────────────────────

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _period = 1; // 0 hari, 1 minggu, 2 bulan
  final List<String> _periods = const ['Harian', 'Mingguan', 'Bulanan'];

  // Data dummy chart bar (transaksi 7 hari)
  final List<Map<String, dynamic>> _bars = const [
    {'day': 'Sen', 'in': 12, 'out': 8},
    {'day': 'Sel', 'in': 18, 'out': 14},
    {'day': 'Rab', 'in': 9, 'out': 22},
    {'day': 'Kam', 'in': 24, 'out': 16},
    {'day': 'Jum', 'in': 15, 'out': 19},
    {'day': 'Sab', 'in': 6, 'out': 4},
    {'day': 'Min', 'in': 3, 'out': 2},
  ];

  // Distribusi kategori
  final List<Map<String, dynamic>> _categories = const [
    {
      'name': 'Pompa IPAL',
      'count': 42,
      'percent': 0.28,
      'color': AppTheme.primary,
    },
    {
      'name': 'Filter IPAL',
      'count': 31,
      'percent': 0.21,
      'color': AppTheme.primaryDark,
    },
    {
      'name': 'Blower Aerasi',
      'count': 24,
      'percent': 0.16,
      'color': AppTheme.primaryLight,
    },
    {
      'name': 'Panel Kontrol',
      'count': 19,
      'percent': 0.13,
      'color': AppTheme.primaryMid,
    },
    {
      'name': 'Pipa & Saluran',
      'count': 33,
      'percent': 0.22,
      'color': AppTheme.primaryLighter,
    },
  ];

  // Top requested items
  final List<Map<String, dynamic>> _topItems = const [
    {'name': 'Pompa Submersible 1 HP', 'qty': 24, 'unit': 'unit'},
    {'name': 'Filter Cartridge 10" 5µm', 'qty': 86, 'unit': 'unit'},
    {'name': 'Media Karbon Aktif 25kg', 'qty': 320, 'unit': 'kg'},
    {'name': 'Pipa PVC AW 2"', 'qty': 180, 'unit': 'meter'},
    {'name': 'MCB 3 Phase 16A', 'qty': 42, 'unit': 'unit'},
  ];

  void _showExportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Ekspor Laporan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih format yang ingin diunduh',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            _exportTile(
              icon: Icons.picture_as_pdf_rounded,
              color: AppTheme.statusRejected,
              title: 'Format PDF',
              subtitle: 'Laporan terformat lengkap dengan grafik',
            ),
            const SizedBox(height: 10),
            _exportTile(
              icon: Icons.table_chart_rounded,
              color: AppTheme.statusApproved,
              title: 'Format Excel',
              subtitle: 'Spreadsheet untuk analisis lebih lanjut',
            ),
            const SizedBox(height: 10),
            _exportTile(
              icon: Icons.description_rounded,
              color: AppTheme.primary,
              title: 'Format CSV',
              subtitle: 'File teks ringan, kompatibel banyak aplikasi',
            ),
          ],
        ),
      ),
    );
  }

  Widget _exportTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mengunduh laporan ($title)…'),
            backgroundColor: color,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.download_rounded,
                color: AppTheme.primary, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxBar = _bars
        .map((b) => (b['in'] as int) + (b['out'] as int))
        .reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Laporan & Analitik'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _showExportSheet,
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Period selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: _periods.asMap().entries.map((e) {
                final selected = _period == e.key;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _period = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Summary cards
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  label: 'Total Transaksi',
                  value: '147',
                  icon: Icons.receipt_long_rounded,
                  color: AppTheme.primary,
                  trend: '+12%',
                  trendUp: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  label: 'Disetujui',
                  value: '124',
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.statusApproved,
                  trend: '+8%',
                  trendUp: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  label: 'Ditolak',
                  value: '23',
                  icon: Icons.cancel_rounded,
                  color: AppTheme.statusRejected,
                  trend: '-5%',
                  trendUp: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  label: 'Stok Kritis',
                  value: '7',
                  icon: Icons.warning_amber_rounded,
                  color: AppTheme.statusPending,
                  trend: '+2',
                  trendUp: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Bar chart - aktivitas mingguan
          _sectionCard(
            title: 'Aktivitas Mingguan',
            subtitle: 'Barang masuk & keluar 7 hari terakhir',
            child: SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _bars.map((b) {
                  final inVal = b['in'] as int;
                  final outVal = b['out'] as int;
                  final total = inVal + outVal;
                  final ratio = total / maxBar;
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 130,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 14,
                                height: 130 *
                                    ratio *
                                    (inVal / (total == 0 ? 1 : total)),
                                decoration: BoxDecoration(
                                  color: AppTheme.statusApproved,
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(4)),
                                ),
                              ),
                              Container(
                                width: 14,
                                height: 130 *
                                    ratio *
                                    (outVal / (total == 0 ? 1 : total)),
                                decoration: const BoxDecoration(
                                  color: AppTheme.statusRejected,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          b['day'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            footer: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(AppTheme.statusApproved, 'Masuk'),
                const SizedBox(width: 16),
                _legendDot(AppTheme.statusRejected, 'Keluar'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category distribution
          _sectionCard(
            title: 'Distribusi per Kategori',
            subtitle: 'Permintaan barang berdasarkan kategori',
            child: Column(
              children: _categories.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            c['name'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${c['count']} req',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: c['percent'] as double,
                          minHeight: 8,
                          backgroundColor: AppTheme.primaryPale.withOpacity(0.5),
                          color: c['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Top requested items
          _sectionCard(
            title: 'Item Paling Banyak Diminta',
            subtitle: 'Top 5 berdasarkan kuantitas',
            child: Column(
              children: _topItems.asMap().entries.map((e) {
                final idx = e.key;
                final it = e.value;
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: idx == _topItems.length - 1 ? 0 : 12),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${idx + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          it['name'] as String,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${it['qty']} ${it['unit']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    required bool trendUp,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (trendUp
                          ? AppTheme.statusApproved
                          : AppTheme.statusRejected)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      trendUp
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 10,
                      color: trendUp
                          ? AppTheme.statusApproved
                          : AppTheme.statusRejected,
                    ),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: trendUp
                            ? AppTheme.statusApproved
                            : AppTheme.statusRejected,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
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
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
    Widget? footer,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
          child,
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
