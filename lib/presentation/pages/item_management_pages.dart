import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'stock_check_pages.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Item Management — Admin CRUD inventaris.
//
// Versi terhubung dengan halaman lain:
//   • Memakai dataset bersama `kSharedStockItems` (dari stock_check_pages.dart)
//     supaya perubahan stok terlihat di Beranda, Cek Stok, dan Update Bulanan.
//   • Tombol AppBar:
//       - Cek Stok      → buka StockCheckPage
//       - Update Bulanan → buka MonthlyStockUpdatePage
//       - QR Scanner    → bottom sheet simulasi pemindaian
//   • Tap kartu item   → bottom sheet detail dengan tombol Cek Stok/Edit/Hapus.
//   • Filter chip menampilkan jumlah item per kategori.
//   • Animasi list, swipe-to-delete, undo snackbar, pull-to-refresh.
// ─────────────────────────────────────────────────────────────────────────────

class ItemManagementPage extends StatefulWidget {
  const ItemManagementPage({super.key});

  @override
  State<ItemManagementPage> createState() => _ItemManagementPageState();
}

class _ItemManagementPageState extends State<ItemManagementPage> {
  final _searchCtrl = TextEditingController();
  String _category = 'Semua';

  final List<String> _categories = const [
    'Semua',
    'Pompa',
    'Filter',
    'Blower',
    'Panel',
    'Pipa',
  ];

  List<Map<String, dynamic>> get _items => kSharedStockItems;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _items.where((it) {
      final byCat = _category == 'Semua' || it['category'] == _category;
      final byQuery = q.isEmpty ||
          (it['name'] as String).toLowerCase().contains(q) ||
          (it['id'] as String).toLowerCase().contains(q);
      return byCat && byQuery;
    }).toList();
  }

  int _categoryCount(String cat) {
    if (cat == 'Semua') return _items.length;
    return _items.where((it) => it['category'] == cat).length;
  }

  Color _stockColor(int stock, int min) {
    if (stock == 0) return AppTheme.statusRejected;
    if (stock < min) return AppTheme.statusPending;
    return AppTheme.statusApproved;
  }

  String _stockLabel(int stock, int min) {
    if (stock == 0) return 'Habis';
    if (stock < min) return 'Rendah';
    return 'Tersedia';
  }

  Future<void> _refresh() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {});
  }

  // ─────────────────────────── Add/Edit form ───────────────────────────
  void _showItemForm({Map<String, dynamic>? edit}) {
    HapticFeedback.selectionClick();
    final isEdit = edit != null;
    final idCtrl = TextEditingController(text: edit?['id'] as String? ?? '');
    final nameCtrl =
        TextEditingController(text: edit?['name'] as String? ?? '');
    final stockCtrl =
        TextEditingController(text: (edit?['stock'] ?? 0).toString());
    final unitCtrl =
        TextEditingController(text: edit?['unit'] as String? ?? 'unit');
    final minCtrl =
        TextEditingController(text: (edit?['min'] ?? 0).toString());
    final locCtrl =
        TextEditingController(text: edit?['location'] as String? ?? '');
    String selectedCat = edit?['category'] as String? ?? _categories[1];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scroll) => StatefulBuilder(
            builder: (ctx, setSheet) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
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
                        Expanded(
                          child: Text(
                            isEdit ? 'Edit Item' : 'Tambah Item Baru',
                            style: const TextStyle(
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
                        TextField(
                          controller: idCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Kode Item',
                            prefixIcon: Icon(Icons.qr_code_2_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nama Item',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: selectedCat,
                          items: _categories
                              .where((c) => c != 'Semua')
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setSheet(() => selectedCat = v ?? selectedCat),
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: stockCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Stok',
                                  prefixIcon: Icon(Icons.numbers_rounded),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: unitCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Satuan',
                                  prefixIcon:
                                      Icon(Icons.straighten_rounded),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: minCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Stok Minimum',
                            prefixIcon: Icon(Icons.warning_amber_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: locCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Lokasi (Rak)',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final newItem = {
                                'id': idCtrl.text.trim(),
                                'name': nameCtrl.text.trim(),
                                'category': selectedCat,
                                'stock': int.tryParse(stockCtrl.text) ?? 0,
                                'unit': unitCtrl.text.trim(),
                                'min': int.tryParse(minCtrl.text) ?? 0,
                                'location': locCtrl.text.trim(),
                              };
                              setState(() {
                                if (isEdit) {
                                  final idx = _items.indexOf(edit);
                                  _items[idx] = newItem;
                                } else {
                                  _items.insert(0, newItem);
                                }
                              });
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEdit
                                      ? 'Item berhasil diperbarui.'
                                      : 'Item baru berhasil ditambahkan.'),
                                  backgroundColor: AppTheme.statusApproved,
                                ),
                              );
                            },
                            icon: Icon(isEdit
                                ? Icons.save_rounded
                                : Icons.add_rounded),
                            label: Text(
                              isEdit ? 'Simpan Perubahan' : 'Tambah Item',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
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
      },
    );
  }

  // ─────────────────────────── Detail sheet ───────────────────────────
  void _showItemDetail(Map<String, dynamic> it) {
    HapticFeedback.selectionClick();
    final stock = it['stock'] as int;
    final min = it['min'] as int;
    final c = _stockColor(stock, min);
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      it['id'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: c.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$stock ${it['unit']} · '
                          '${_stockLabel(stock, min)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: c,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow('Kategori', it['category'] as String),
            _detailRow('Lokasi', it['location'] as String),
            _detailRow('Stok minimum', '$min ${it['unit']}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.statusRejected,
                      side: const BorderSide(
                          color: AppTheme.statusRejected),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmDelete(it);
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showItemForm(edit: it);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MonthlyStockUpdatePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                label: const Text('Update Stok Bulanan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── Delete ───────────────────────────
  void _confirmDelete(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Item?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Item "${item['name']}" akan dihapus permanen dari inventaris. Lanjutkan?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: AppTheme.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              final removed = Map<String, dynamic>.from(item);
              final removedIndex = _items.indexOf(item);
              setState(() => _items.remove(item));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Item ${item['name']} dihapus.'),
                  backgroundColor: AppTheme.statusRejected,
                  action: SnackBarAction(
                    label: 'URUNG',
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        if (removedIndex >= 0 &&
                            removedIndex <= _items.length) {
                          _items.insert(removedIndex, removed);
                        } else {
                          _items.add(removed);
                        }
                      });
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusRejected,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── QR scanner sheet ───────────────────────────
  void _showQRScanner() {
    HapticFeedback.lightImpact();
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
            const Text('Scan QR Item',
                style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Arahkan kamera ke barcode/QR pada label item.',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 18),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3), width: 2),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_scanner_rounded,
                    color: AppTheme.primary, size: 80),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  // Demo: cari item pertama
                  if (_items.isNotEmpty) {
                    _showItemDetail(_items.first);
                  }
                },
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: const Text('Simulasi Pemindaian'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openStockCheck() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StockCheckPage()),
    );
  }

  void _openMonthlyUpdate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MonthlyStockUpdatePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Manajemen Inventaris'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        actions: [
          IconButton(
            tooltip: 'Cek Stok Semua',
            icon: const Icon(Icons.fact_check_rounded),
            onPressed: _openStockCheck,
          ),
          IconButton(
            tooltip: 'Update Bulanan',
            icon: const Icon(Icons.edit_calendar_rounded),
            onPressed: _openMonthlyUpdate,
          ),
          IconButton(
            tooltip: 'Scan QR',
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: _showQRScanner,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemForm(),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Tambah Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppTheme.primary,
        child: Column(
          children: [
            // Search + filter
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  TextField(
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
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = _categories[i];
                        final selected = _category == cat;
                        final count = _categoryCount(cat);
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _category = cat);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.primary
                                    : AppTheme.primaryLight
                                        .withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? Colors.white
                                        : AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white.withOpacity(0.25)
                                        : AppTheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: selected
                                          ? Colors.white
                                          : AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade100),

            // List items
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_rounded,
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
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final it = _filtered[i];
                        final stock = it['stock'] as int;
                        final min = it['min'] as int;
                        final stColor = _stockColor(stock, min);
                        return Dismissible(
                          key: ValueKey(it['id']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppTheme.statusRejected,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete_rounded,
                                color: Colors.white),
                          ),
                          confirmDismiss: (_) async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                title: const Text('Hapus Item?'),
                                content: Text('Hapus ${it['name']}?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Batal',
                                          style: TextStyle(
                                              color: AppTheme.primary))),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppTheme.statusRejected,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            return ok ?? false;
                          },
                          onDismissed: (_) {
                            final removed = Map<String, dynamic>.from(it);
                            final removedIdx = _items.indexOf(it);
                            setState(() => _items.remove(it));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Item ${it['name']} dihapus.'),
                                backgroundColor: AppTheme.statusRejected,
                                action: SnackBarAction(
                                  label: 'URUNG',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      if (removedIdx >= 0 &&
                                          removedIdx <= _items.length) {
                                        _items.insert(
                                            removedIdx, removed);
                                      } else {
                                        _items.add(removed);
                                      }
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () => _showItemDetail(it),
                              onLongPress: () {
                                HapticFeedback.mediumImpact();
                                _showItemForm(edit: it);
                              },
                              borderRadius: BorderRadius.circular(16),
                              splashColor: stColor.withOpacity(0.12),
                              child: Ink(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppTheme.primary.withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                        borderRadius:
                                            BorderRadius.circular(14),
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
                                                  color: stColor
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6),
                                                ),
                                                child: Text(
                                                  '$stock ${it['unit']} · '
                                                  '${_stockLabel(stock, min)}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    color: stColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert_rounded,
                                          color: Colors.grey.shade500),
                                      onSelected: (v) {
                                        if (v == 'edit') {
                                          _showItemForm(edit: it);
                                        }
                                        if (v == 'delete') {
                                          _confirmDelete(it);
                                        }
                                        if (v == 'check') {
                                          _openStockCheck();
                                        }
                                        if (v == 'monthly') {
                                          _openMonthlyUpdate();
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit_outlined,
                                                  color: AppTheme.primary,
                                                  size: 18),
                                              SizedBox(width: 10),
                                              Text('Edit Item'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'check',
                                          child: Row(
                                            children: [
                                              Icon(
                                                  Icons.fact_check_rounded,
                                                  color: AppTheme.primary,
                                                  size: 18),
                                              SizedBox(width: 10),
                                              Text('Cek Semua Stok'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'monthly',
                                          child: Row(
                                            children: [
                                              Icon(
                                                  Icons
                                                      .edit_calendar_rounded,
                                                  color: AppTheme.primary,
                                                  size: 18),
                                              SizedBox(width: 10),
                                              Text('Update Bulanan'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline,
                                                  color: AppTheme
                                                      .statusRejected,
                                                  size: 18),
                                              SizedBox(width: 10),
                                              Text('Hapus Item'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
}
