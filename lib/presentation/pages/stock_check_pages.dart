import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Stock Check & Monthly Update — dua halaman terpisah:
//
//   1) StockCheckPage          → Memeriksa stok seluruh barang sekaligus
//                                (filter status, search, ringkasan).
//   2) MonthlyStockUpdatePage  → Update stok bulanan secara bulk.
//                                Admin dapat menambah/mengurangi stok tiap
//                                item lalu menyimpan semua perubahan.
//
// Kedua halaman pakai tema oranye yang sama dengan halaman lain di repo
// (AppTheme.primaryGradient pada AppBar, AppTheme.background pada body).
// ─────────────────────────────────────────────────────────────────────────────

// Daftar item gudang shared. Idealnya nanti ditarik dari satu sumber data
// (provider / repository). Untuk demo, dataset disamakan dengan
// item_management_pages.dart agar tampak konsisten.
List<Map<String, dynamic>> kSharedStockItems = [
  {
    'id': 'P02',
    'name': 'Pompa Submersible 1 HP',
    'category': 'Pompa',
    'stock': 12,
    'unit': 'unit',
    'min': 5,
    'location': 'Rak A-03',
  },
  {
    'id': 'P03',
    'name': 'Pompa Submersible 2 HP',
    'category': 'Pompa',
    'stock': 2,
    'unit': 'unit',
    'min': 5,
    'location': 'Rak A-04',
  },
  {
    'id': 'F04',
    'name': 'Membran RO 4040',
    'category': 'Filter',
    'stock': 1,
    'unit': 'modul',
    'min': 4,
    'location': 'Rak B-12',
  },
  {
    'id': 'F11',
    'name': 'Media Karbon Aktif 25kg',
    'category': 'Filter',
    'stock': 80,
    'unit': 'kg',
    'min': 50,
    'location': 'Rak B-09',
  },
  {
    'id': 'F28',
    'name': 'UV Sterilizer 11W',
    'category': 'Filter',
    'stock': 0,
    'unit': 'unit',
    'min': 3,
    'location': 'Rak B-15',
  },
  {
    'id': 'B02',
    'name': 'Blower Roots 1 HP',
    'category': 'Blower',
    'stock': 6,
    'unit': 'unit',
    'min': 3,
    'location': 'Rak C-02',
  },
  {
    'id': 'B07',
    'name': 'Diffuser Gelembung Halus 12"',
    'category': 'Blower',
    'stock': 45,
    'unit': 'unit',
    'min': 20,
    'location': 'Rak C-08',
  },
  {
    'id': 'K05',
    'name': 'MCB 3 Phase 16A',
    'category': 'Panel',
    'stock': 3,
    'unit': 'unit',
    'min': 10,
    'location': 'Rak K-05',
  },
  {
    'id': 'K20',
    'name': 'Box Panel IP54 400x300',
    'category': 'Panel',
    'stock': 14,
    'unit': 'unit',
    'min': 5,
    'location': 'Rak K-12',
  },
  {
    'id': 'S05',
    'name': 'Pipa PVC AW 2" / 6m',
    'category': 'Pipa',
    'stock': 90,
    'unit': 'meter',
    'min': 30,
    'location': 'Rak D-02',
  },
  {
    'id': 'S18',
    'name': 'Ball Valve PVC 2"',
    'category': 'Pipa',
    'stock': 25,
    'unit': 'unit',
    'min': 10,
    'location': 'Rak D-08',
  },
];

// ═════════════════════════════════════════════════════════════════════════════
//  1) STOCK CHECK PAGE
// ═════════════════════════════════════════════════════════════════════════════
class StockCheckPage extends StatefulWidget {
  const StockCheckPage({super.key});

  @override
  State<StockCheckPage> createState() => _StockCheckPageState();
}

class _StockCheckPageState extends State<StockCheckPage> {
  final _searchCtrl = TextEditingController();
  int _filter = 0; // 0 semua, 1 habis, 2 rendah, 3 aman

  final List<String> _filters = const ['Semua', 'Habis', 'Rendah', 'Aman'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _color(int stock, int min) {
    if (stock == 0) return AppTheme.statusRejected;
    if (stock < min) return AppTheme.statusPending;
    return AppTheme.statusApproved;
  }

  String _label(int stock, int min) {
    if (stock == 0) return 'Habis';
    if (stock < min) return 'Rendah';
    return 'Aman';
  }

  bool _matchFilter(Map<String, dynamic> it) {
    final stock = it['stock'] as int;
    final min = it['min'] as int;
    switch (_filter) {
      case 1:
        return stock == 0;
      case 2:
        return stock > 0 && stock < min;
      case 3:
        return stock >= min;
      default:
        return true;
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return kSharedStockItems.where((it) {
      final byQuery = q.isEmpty ||
          (it['name'] as String).toLowerCase().contains(q) ||
          (it['id'] as String).toLowerCase().contains(q);
      return byQuery && _matchFilter(it);
    }).toList();
  }

  Map<String, int> get _summary {
    int habis = 0, rendah = 0, aman = 0;
    for (final it in kSharedStockItems) {
      final stock = it['stock'] as int;
      final min = it['min'] as int;
      if (stock == 0) {
        habis++;
      } else if (stock < min) {
        rendah++;
      } else {
        aman++;
      }
    }
    return {'habis': habis, 'rendah': rendah, 'aman': aman};
  }

  Future<void> _refresh() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stok berhasil diperiksa ulang.'),
        backgroundColor: AppTheme.statusApproved,
      ),
    );
  }

  void _showDetail(Map<String, dynamic> it) {
    HapticFeedback.selectionClick();
    final stock = it['stock'] as int;
    final min = it['min'] as int;
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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      it['id'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    it['name'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow('Kategori', it['category'] as String),
            _detailRow('Lokasi', it['location'] as String),
            _detailRow(
              'Stok saat ini',
              '$stock ${it['unit']}',
              color: _color(stock, min),
            ),
            _detailRow('Stok minimum', '$min ${it['unit']}'),
            _detailRow('Status', _label(stock, min),
                color: _color(stock, min)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Permintaan restock untuk '
                              '${it['name']} telah dibuat.'),
                          backgroundColor: AppTheme.statusApproved,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    label: const Text('Restock'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MonthlyStockUpdatePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: const Text('Update Stok'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color ?? AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Ekspor Laporan Stok?'),
        content: const Text(
          'Laporan akan berisi seluruh item beserta status stok terkini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: AppTheme.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Laporan stok berhasil diekspor.'),
                  backgroundColor: AppTheme.statusApproved,
                ),
              );
            },
            child: const Text('Ekspor'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _summary;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Cek Stok Semua Barang'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        actions: [
          IconButton(
            tooltip: 'Ekspor laporan',
            icon: const Icon(Icons.download_rounded),
            onPressed: _exportReport,
          ),
          IconButton(
            tooltip: 'Update bulanan',
            icon: const Icon(Icons.edit_calendar_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MonthlyStockUpdatePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _refresh,
        child: Column(
          children: [
            // Summary kartu
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      label: 'Habis',
                      value: '${s['habis']}',
                      icon: Icons.error_rounded,
                      color: AppTheme.statusRejected,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryCard(
                      label: 'Rendah',
                      value: '${s['rendah']}',
                      icon: Icons.warning_amber_rounded,
                      color: AppTheme.statusPending,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryCard(
                      label: 'Aman',
                      value: '${s['aman']}',
                      icon: Icons.check_circle_rounded,
                      color: AppTheme.statusApproved,
                    ),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau kode item…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppTheme.primary, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                        ),
                ),
              ),
            ),
            // Filter chip
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final selected = _filter == i;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primary
                              : AppTheme.primaryLight.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _filters[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppTheme.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // List item
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 10),
                          Text(
                            'Tidak ada item ditemukan',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final it = _filtered[i];
                        final stock = it['stock'] as int;
                        final min = it['min'] as int;
                        final c = _color(stock, min);
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => _showDetail(it),
                            borderRadius: BorderRadius.circular(16),
                            splashColor: c.withOpacity(0.12),
                            child: Ink(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        it['id'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          it['name'] as String,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${it['category']} · ${it['location']}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: c.withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '$stock ${it['unit']} · '
                                                '${_label(stock, min)}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: c,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Min ${it['min']}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
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
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  2) MONTHLY STOCK UPDATE PAGE
// ═════════════════════════════════════════════════════════════════════════════
class MonthlyStockUpdatePage extends StatefulWidget {
  const MonthlyStockUpdatePage({super.key});

  @override
  State<MonthlyStockUpdatePage> createState() => _MonthlyStockUpdatePageState();
}

class _MonthlyStockUpdatePageState extends State<MonthlyStockUpdatePage> {
  // Map id → stok yang sedang diedit
  late Map<String, int> _draft;
  final _searchCtrl = TextEditingController();
  static const List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month - 1;
    _year = now.year;
    _draft = {
      for (final it in kSharedStockItems)
        it['id'] as String: it['stock'] as int,
    };
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int _changedCount() {
    int n = 0;
    for (final it in kSharedStockItems) {
      final id = it['id'] as String;
      if (_draft[id] != it['stock']) n++;
    }
    return n;
  }

  int _diff(Map<String, dynamic> it) {
    final id = it['id'] as String;
    return (_draft[id] ?? 0) - (it['stock'] as int);
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return kSharedStockItems.where((it) {
      return q.isEmpty ||
          (it['name'] as String).toLowerCase().contains(q) ||
          (it['id'] as String).toLowerCase().contains(q);
    }).toList();
  }

  void _adjust(Map<String, dynamic> it, int delta) {
    HapticFeedback.selectionClick();
    final id = it['id'] as String;
    final next = (_draft[id] ?? 0) + delta;
    if (next < 0) return;
    setState(() => _draft[id] = next);
  }

  void _editManually(Map<String, dynamic> it) {
    final id = it['id'] as String;
    final ctrl = TextEditingController(text: '${_draft[id] ?? 0}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(it['name'] as String,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Stok baru (${it['unit']})',
            prefixIcon: const Icon(Icons.numbers_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: AppTheme.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final v = int.tryParse(ctrl.text) ?? _draft[id] ?? 0;
              setState(() => _draft[id] = v);
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _resetAll() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Reset Perubahan?'),
        content: const Text(
            'Semua perubahan stok yang belum disimpan akan dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: AppTheme.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusRejected,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _draft = {
                  for (final it in kSharedStockItems)
                    it['id'] as String: it['stock'] as int,
                };
              });
              Navigator.pop(ctx);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final changed = _changedCount();
    if (changed == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada perubahan stok untuk disimpan.'),
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Simpan Update Bulanan?'),
        content: Text(
          '$changed item akan diperbarui untuk periode '
          '${_months[_month]} $_year.\n\n'
          'Aksi ini akan dicatat di audit log.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: AppTheme.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    HapticFeedback.mediumImpact();
    setState(() {
      for (final it in kSharedStockItems) {
        final id = it['id'] as String;
        it['stock'] = _draft[id] ?? it['stock'];
      }
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Berhasil menyimpan update untuk ${_months[_month]} $_year.'),
        backgroundColor: AppTheme.statusApproved,
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _pickPeriod() async {
    HapticFeedback.selectionClick();
    int month = _month;
    int year = _year;
    final years = List<int>.generate(5, (i) => DateTime.now().year - 2 + i);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) => SafeArea(
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
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Periode',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: month,
                          decoration: const InputDecoration(
                            labelText: 'Bulan',
                            prefixIcon: Icon(Icons.calendar_month_rounded),
                          ),
                          items: List.generate(
                            12,
                            (i) => DropdownMenuItem(
                              value: i,
                              child: Text(_months[i]),
                            ),
                          ),
                          onChanged: (v) =>
                              setSheet(() => month = v ?? month),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: year,
                          decoration: const InputDecoration(
                            labelText: 'Tahun',
                            prefixIcon: Icon(Icons.event_rounded),
                          ),
                          items: years
                              .map((y) => DropdownMenuItem(
                                    value: y,
                                    child: Text('$y'),
                                  ))
                              .toList(),
                          onChanged: (v) => setSheet(() => year = v ?? year),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _month = month;
                        _year = year;
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Gunakan Periode Ini'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final changed = _changedCount();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Update Stok Bulanan'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        actions: [
          IconButton(
            tooltip: 'Pilih periode',
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: _pickPeriod,
          ),
          IconButton(
            tooltip: 'Reset perubahan',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: _resetAll,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner periode
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_note_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Periode: ${_months[_month]} $_year',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$changed perubahan belum disimpan',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _pickPeriod,
                  child: const Text('Ubah'),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari item…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppTheme.primary, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          // List
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 100),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _stockRow(_filtered[i]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: Text(
                changed == 0
                    ? 'Tidak ada perubahan'
                    : 'Simpan $changed Perubahan',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stockRow(Map<String, dynamic> it) {
    final id = it['id'] as String;
    final cur = _draft[id] ?? 0;
    final orig = it['stock'] as int;
    final diff = cur - orig;
    final hasChange = diff != 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasChange
            ? Border.all(color: AppTheme.primary.withOpacity(0.4), width: 1.4)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                id,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  it['name'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Awal: $orig ${it['unit']}'
                  '${hasChange ? "  →  $cur" : ""}'
                  '${hasChange ? "  (${diff > 0 ? "+" : ""}$diff)" : ""}',
                  style: TextStyle(
                    fontSize: 11,
                    color: hasChange
                        ? (diff > 0
                            ? AppTheme.statusApproved
                            : AppTheme.statusRejected)
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Stepper
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _stepBtn(Icons.remove_rounded, () => _adjust(it, -1)),
              GestureDetector(
                onTap: () => _editManually(it),
                child: Container(
                  width: 44,
                  alignment: Alignment.center,
                  child: Text(
                    '$cur',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              _stepBtn(Icons.add_rounded, () => _adjust(it, 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppTheme.primary.withOpacity(0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: AppTheme.primary, size: 18),
        ),
      ),
    );
  }
}
