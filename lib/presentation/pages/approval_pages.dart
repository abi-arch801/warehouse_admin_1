import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'stock_check_pages.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Approval Page — Admin meninjau permintaan barang dari user.
//
// Mendukung semua fitur terbaru dari User App:
//   • Sumber barang: 'gudang' (stok) atau 'luar' (pembelian eksternal)
//   • Multi-item (hingga 5 jenis barang dalam 1 request)
//   • Lampiran foto contoh barang per item
//   • Field eksternal: spesifikasi, link pembelian, estimasi harga
// ─────────────────────────────────────────────────────────────────────────────

/// Notifier global untuk meminta ApprovalPage memilih filter tertentu
/// dari halaman lain (mis. KPI di Beranda → langsung tab Pending/Disetujui).
/// 0 = Pending, 1 = Disetujui, 2 = Ditolak.
final ValueNotifier<int> kApprovalFilter = ValueNotifier<int>(0);

/// Daftar permintaan global. Dipakai sebagai sumber data untuk ApprovalPage
/// dan untuk perhitungan KPI di Beranda. Saat admin menyetujui / menolak,
/// list ini yang dimutasi sehingga semua halaman ikut sinkron.
final List<Map<String, dynamic>> kSharedApprovalRequests =
    _buildInitialApprovalRequests();

int kPendingCount() =>
    kSharedApprovalRequests.where((r) => r['status'] == 'pending').length;

int kApprovedCount() => kSharedApprovalRequests
    .where((r) => r['status'] == 'approved' || r['status'] == 'partial')
    .length;

int kRejectedCount() =>
    kSharedApprovalRequests.where((r) => r['status'] == 'rejected').length;

List<Map<String, dynamic>> _buildInitialApprovalRequests() {
  return [
    // ── Multi-item dari Gudang dengan foto ─────────────────────────────
    {
      'code': 'REQ-20260420-001',
      'requester': 'Bagas Pratama',
      'role': 'Operator IPAL',
      'date': '20 Apr 2026',
      'time': '08:42',
      'status': 'pending',
      'priority': 'tinggi',
      'notes': 'Penggantian unit pompa & filter inlet yang rusak total.',
      'source': 'gudang',
      'items': [
        {
          'name': 'Pompa Submersible 7.5 kW',
          'code': 'PUMP-001',
          'qty': 1,
          'unit': 'unit',
          'photo': 'pompa_inlet.jpg',
        },
        {
          'name': 'Filter Cartridge 10" 5µm',
          'code': 'FLT-010-5',
          'qty': 12,
          'unit': 'pcs',
          'photo': null,
        },
        {
          'name': 'Seal Mekanis 25mm',
          'code': 'SEL-025',
          'qty': 4,
          'unit': 'pcs',
          'photo': 'seal_mekanis.jpg',
        },
      ],
    },

    // ── Single item dari Gudang dengan foto ────────────────────────────
    {
      'code': 'REQ-20260420-002',
      'requester': 'Dewi Lestari',
      'role': 'Teknisi IPAL',
      'date': '20 Apr 2026',
      'time': '09:15',
      'status': 'pending',
      'priority': 'sedang',
      'notes': 'Penggantian rutin bulanan filter sand RO unit 1.',
      'source': 'gudang',
      'items': [
        {
          'name': 'Filter Cartridge 10" 5µm',
          'code': 'FLT-010-5',
          'qty': 24,
          'unit': 'pcs',
          'photo': 'filter_cartridge.jpg',
        },
      ],
    },

    // ── Multi-item dari Luar (pembelian) ───────────────────────────────
    {
      'code': 'REQ-20260420-003',
      'requester': 'Reza Permana',
      'role': 'Supervisor',
      'date': '20 Apr 2026',
      'time': '10:30',
      'status': 'pending',
      'priority': 'tinggi',
      'notes':
          'Membran tersumbat di unit RO Plant 02 — perlu pembelian segera.',
      'source': 'luar',
      'items': [
        {
          'name': 'Membran RO 4040',
          'spec':
              'TFC Polyamide, kapasitas 2.500 GPD, tekanan kerja 250 psi, merk: DOW Filmtec.',
          'qty': 4,
          'unit': 'modul',
          'photo': 'membran_ro.jpg',
          'link': 'https://aqualab.id/produk/membran-ro-4040-dow',
          'price': 4250000,
        },
        {
          'name': 'Housing Membran Stainless',
          'spec':
              'Material: SUS304, ukuran 4040, tekanan kerja max 300 psi, kelengkapan flange.',
          'qty': 4,
          'unit': 'unit',
          'photo': 'housing_ss.jpg',
          'link': 'https://aqualab.id/produk/housing-ss-4040',
          'price': 1850000,
        },
      ],
    },

    // ── Single item dari Luar ──────────────────────────────────────────
    {
      'code': 'REQ-20260419-014',
      'requester': 'Budi Santoso',
      'role': 'Maintenance',
      'date': '19 Apr 2026',
      'time': '14:20',
      'status': 'approved',
      'priority': 'sedang',
      'notes': 'Penggantian panel kontrol blower #3.',
      'source': 'luar',
      'items': [
        {
          'name': 'MCB 3 Phase 16A',
          'spec':
              'MCB 3P 16A, 6kA, kurva C, brand Schneider Domae, dilengkapi terminal cover.',
          'qty': 3,
          'unit': 'unit',
          'photo': 'mcb_schneider.jpg',
          'link': 'https://elektrikmart.co.id/p/mcb-3p-16a',
          'price': 425000,
        },
      ],
    },

    // ── Single item dari Gudang (ditolak) ──────────────────────────────
    {
      'code': 'REQ-20260419-008',
      'requester': 'Siti Rahayu',
      'role': 'Operator IPAL',
      'date': '19 Apr 2026',
      'time': '11:00',
      'status': 'rejected',
      'priority': 'rendah',
      'notes': 'Permintaan terlalu besar untuk anggaran bulan ini.',
      'source': 'gudang',
      'items': [
        {
          'name': 'Diffuser Gelembung Halus 9"',
          'code': 'DIF-009',
          'qty': 30,
          'unit': 'unit',
          'photo': null,
        },
      ],
    },

    // ── Multi-item Gudang (disetujui) ──────────────────────────────────
    {
      'code': 'REQ-20260418-005',
      'requester': 'Bagas Pratama',
      'role': 'Operator IPAL',
      'date': '18 Apr 2026',
      'time': '15:40',
      'status': 'approved',
      'priority': 'sedang',
      'notes': 'Penambahan kapasitas aerasi tahap 2.',
      'source': 'gudang',
      'items': [
        {
          'name': 'Blower Roots 1 HP',
          'code': 'BLW-1HP',
          'qty': 2,
          'unit': 'unit',
          'photo': 'blower_roots.jpg',
        },
        {
          'name': 'Pipa PVC 4"',
          'code': 'PVC-004',
          'qty': 6,
          'unit': 'batang',
          'photo': null,
        },
      ],
    },
  ];
}

class ApprovalPage extends StatefulWidget {
  final void Function(int tabIndex)? onNavigate;

  /// Filter awal saat halaman dibuka.
  /// 0 = Pending, 1 = Disetujui, 2 = Ditolak.
  final int initialFilter;

  const ApprovalPage({
    super.key,
    this.onNavigate,
    this.initialFilter = 0,
  });

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage>
    with SingleTickerProviderStateMixin {
  late int _filter = widget.initialFilter;
  final List<String> _filters = const [
    'Pending',
    'Disetujui',
    'Ditolak',
  ];

  // Alias agar kode lama (yang merujuk `_requests`) tetap bekerja.
  List<Map<String, dynamic>> get _requests => kSharedApprovalRequests;

  @override
  void initState() {
    super.initState();
    kApprovalFilter.addListener(_onExternalFilterChange);
  }

  @override
  void dispose() {
    kApprovalFilter.removeListener(_onExternalFilterChange);
    super.dispose();
  }

  void _onExternalFilterChange() {
    final v = kApprovalFilter.value;
    if (!mounted || v == _filter) return;
    setState(() => _filter = v);
  }

  // ─── Helpers status / sumber / prioritas ────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    if (_filter == 1) {
      // "Disetujui" mencakup approved penuh dan parsial.
      return _requests
          .where((r) =>
              r['status'] == 'approved' || r['status'] == 'partial')
          .toList();
    }
    final map = ['pending', 'approved', 'rejected'];
    return _requests.where((r) => r['status'] == map[_filter]).toList();
  }

  int _filterCount(int filterIndex) {
    if (filterIndex == 1) {
      return _requests
          .where((r) =>
              r['status'] == 'approved' || r['status'] == 'partial')
          .length;
    }
    final map = ['pending', 'approved', 'rejected'];
    return _requests
        .where((r) => r['status'] == map[filterIndex])
        .length;
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':
        return AppTheme.statusPending;
      case 'approved':
        return AppTheme.statusApproved;
      case 'rejected':
        return AppTheme.statusRejected;
      case 'partial':
        return AppTheme.primary;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'pending':
        return 'PENDING';
      case 'approved':
        return 'DISETUJUI';
      case 'rejected':
        return 'DITOLAK';
      case 'partial':
        return 'PARSIAL';
      default:
        return s.toUpperCase();
    }
  }

  // Decision per item — disimpan di req['itemDecisions'] sebagai List<String>.
  String _itemDecision(Map<String, dynamic> req, int index) {
    final dec = req['itemDecisions'] as List?;
    if (dec != null && index < dec.length) return dec[index] as String;
    switch (req['status']) {
      case 'approved':
        return 'approved';
      case 'rejected':
        return 'rejected';
      default:
        return 'pending';
    }
  }

  int _approvedItemCount(Map<String, dynamic> req) {
    final items = _items(req);
    var n = 0;
    for (var i = 0; i < items.length; i++) {
      if (_itemDecision(req, i) == 'approved') n++;
    }
    return n;
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'tinggi':
        return AppTheme.statusRejected;
      case 'sedang':
        return AppTheme.statusPending;
      default:
        return Colors.grey;
    }
  }

  bool _isExternal(Map<String, dynamic> req) => req['source'] == 'luar';

  List<Map<String, dynamic>> _items(Map<String, dynamic> req) {
    final raw = req['items'] as List?;
    if (raw == null) return const [];
    return raw.cast<Map<String, dynamic>>();
  }

  int _photoCount(Map<String, dynamic> req) =>
      _items(req).where((it) => it['photo'] != null).length;

  int _totalEstimate(Map<String, dynamic> req) {
    if (!_isExternal(req)) return 0;
    var total = 0;
    for (final it in _items(req)) {
      final price = (it['price'] as num?)?.toInt() ?? 0;
      final qty = (it['qty'] as num?)?.toInt() ?? 0;
      total += price * qty;
    }
    return total;
  }

  String _formatRupiah(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  // ─── Aksi keputusan ──────────────────────────────────────────────────────
  // [decision] dipakai untuk single-item / "tolak semua" / "setujui semua".
  // [approvedIndexes] dipakai untuk per-item: index yang masuk = di-ACC,
  // sisanya otomatis ditolak. Status request menjadi:
  //   • 'approved'  jika semua item di-ACC
  //   • 'rejected'  jika tidak ada item di-ACC
  //   • 'partial'   jika sebagian saja
  void _decide(
    Map<String, dynamic> req,
    String decision, {
    Set<int>? approvedIndexes,
  }) {
    HapticFeedback.lightImpact();
    final items = _items(req);
    String finalStatus = decision;
    List<String> itemDecisions;

    if (approvedIndexes != null && items.isNotEmpty) {
      final n = approvedIndexes.length;
      itemDecisions = List.generate(items.length,
          (i) => approvedIndexes.contains(i) ? 'approved' : 'rejected');
      if (n == 0) {
        finalStatus = 'rejected';
      } else if (n == items.length) {
        finalStatus = 'approved';
      } else {
        finalStatus = 'partial';
      }
    } else {
      itemDecisions =
          List.generate(items.length, (_) => decision);
    }

    setState(() {
      req['status'] = finalStatus;
      req['itemDecisions'] = itemDecisions;
    });
    Navigator.pop(context);

    String msg;
    Color bg;
    switch (finalStatus) {
      case 'approved':
        msg = items.length > 1
            ? 'Semua ${items.length} barang di ${req['code']} disetujui.'
            : 'Permintaan ${req['code']} disetujui.';
        bg = AppTheme.statusApproved;
        break;
      case 'rejected':
        msg = 'Permintaan ${req['code']} ditolak.';
        bg = AppTheme.statusRejected;
        break;
      case 'partial':
        final n = approvedIndexes!.length;
        msg =
            '$n dari ${items.length} barang di ${req['code']} disetujui.';
        bg = AppTheme.primary;
        break;
      default:
        msg = 'Keputusan tersimpan.';
        bg = AppTheme.primary;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }

  // ─── Bottom-sheet detail permintaan ─────────────────────────────────────
  void _showDetail(Map<String, dynamic> req) {
    final reasonCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scroll) {
            final color = _statusColor(req['status'] as String);
            final isPending = req['status'] == 'pending';
            final external = _isExternal(req);
            final items = _items(req);
            final totalEst = _totalEstimate(req);

            // Set index item yang dicentang admin (default: semua di-ACC).
            final selected = <int>{
              for (var i = 0; i < items.length; i++) i,
            };

            return StatefulBuilder(
              builder: (ctx, setSheetState) {
            return Container(
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
                  Expanded(
                    child: ListView(
                      controller: scroll,
                      padding:
                          const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      children: [
                        // ── Baris status + source + code
                        Row(
                          children: [
                            _pill(
                              text: _statusLabel(req['status'] as String),
                              color: color,
                            ),
                            const SizedBox(width: 6),
                            _pill(
                              text: external ? 'DARI LUAR' : 'DARI GUDANG',
                              color: external
                                  ? AppTheme.primary
                                  : AppTheme.statusApproved,
                              icon: external
                                  ? Icons.storefront_rounded
                                  : Icons.warehouse_rounded,
                            ),
                            const Spacer(),
                            Text(
                              req['code'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── Judul ringkasan
                        Text(
                          items.isEmpty
                              ? '-'
                              : (items.length == 1
                                  ? items.first['name'] as String
                                  : '${items.first['name']}  +${items.length - 1} jenis lainnya'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${items.length} jenis barang  •  ${_photoCount(req)} foto terlampir',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ── Info pemohon
                        _detailRow(
                          Icons.person_outline_rounded,
                          'Pemohon',
                          '${req['requester']} · ${req['role']}',
                        ),
                        _detailRow(
                          Icons.calendar_today_rounded,
                          'Tanggal',
                          '${req['date']} · ${req['time']}',
                        ),
                        _detailRow(
                          Icons.flag_rounded,
                          'Prioritas',
                          (req['priority'] as String).toUpperCase(),
                          color: _priorityColor(req['priority'] as String),
                        ),
                        _detailRow(
                          Icons.notes_rounded,
                          'Catatan',
                          req['notes'] as String,
                        ),

                        // ── Total estimasi (luar saja)
                        if (external && totalEst > 0) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    AppTheme.primary.withOpacity(0.18),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.payments_rounded,
                                    size: 22,
                                    color: AppTheme.primary),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Total Estimasi Pembelian',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatRupiah(totalEst),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        // ── Daftar item lengkap
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Daftar Barang',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${items.length} jenis',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        for (var i = 0; i < items.length; i++) ...[
                          _itemDetailCard(
                            index: i,
                            item: items[i],
                            isExternal: external,
                            isPending: isPending,
                            multiItem: items.length > 1,
                            isSelected: selected.contains(i),
                            onToggle: () => setSheetState(() {
                              if (selected.contains(i)) {
                                selected.remove(i);
                              } else {
                                selected.add(i);
                              }
                            }),
                            finalDecision: !isPending
                                ? _itemDecision(req, i)
                                : null,
                          ),
                          if (i != items.length - 1)
                            const SizedBox(height: 10),
                        ],

                        const SizedBox(height: 22),

                        // ── Aksi keputusan / banner read-only
                        if (isPending) ...[
                          const Text(
                            'Catatan Keputusan (opsional)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: reasonCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText:
                                  'Tulis alasan persetujuan / penolakan…',
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Banner ringkas pemilihan (multi-item saja)
                          if (items.length > 1) ...[
                            _selectionSummary(
                                selected: selected, total: items.length),
                            const SizedBox(height: 8),
                            Text(
                              'Tap kartu barang untuk pilih / batal pilih.',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _decide(req, 'rejected'),
                                  icon: const Icon(Icons.close_rounded,
                                      color: AppTheme.statusRejected),
                                  label: Text(
                                    items.length > 1
                                        ? 'Tolak Semua'
                                        : 'Tolak',
                                    style: const TextStyle(
                                      color: AppTheme.statusRejected,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize:
                                        const Size.fromHeight(50),
                                    side: const BorderSide(
                                      color: AppTheme.statusRejected,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: items.length > 1
                                      ? (selected.isEmpty
                                          ? null
                                          : () => _decide(req, 'approved',
                                              approvedIndexes:
                                                  selected.toSet()))
                                      : () => _decide(req, 'approved'),
                                  icon: Icon(
                                    items.length > 1 &&
                                            selected.length !=
                                                items.length &&
                                            selected.isNotEmpty
                                        ? Icons.fact_check_rounded
                                        : Icons.check_rounded,
                                  ),
                                  label: Text(
                                    items.length > 1
                                        ? (selected.isEmpty
                                            ? 'Pilih Min. 1'
                                            : (selected.length ==
                                                    items.length
                                                ? 'Setujui Semua'
                                                : 'Setujui Pilihan (${selected.length})'))
                                        : 'Setujui',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: items.length > 1 &&
                                            selected.length !=
                                                items.length &&
                                            selected.isNotEmpty
                                        ? AppTheme.primary
                                        : AppTheme.statusApproved,
                                    disabledBackgroundColor:
                                        Colors.grey.shade300,
                                    minimumSize:
                                        const Size.fromHeight(50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    color: color, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    req['status'] == 'partial'
                                        ? 'Permintaan diproses sebagian: ${_approvedItemCount(req)} dari ${items.length} barang disetujui.'
                                        : 'Permintaan ini sudah diproses dan tidak bisa diubah lagi.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
              },
            );
          },
        );
      },
    );
  }

  // ─── Banner ringkas hasil pemilihan per item ────────────────────────────
  Widget _selectionSummary({
    required Set<int> selected,
    required int total,
  }) {
    final isNone = selected.isEmpty;
    final isAll = selected.length == total;
    final color = isNone
        ? AppTheme.statusRejected
        : (isAll ? AppTheme.statusApproved : AppTheme.primary);
    final icon = isNone
        ? Icons.cancel_rounded
        : (isAll
            ? Icons.check_circle_rounded
            : Icons.fact_check_rounded);
    final text = isNone
        ? 'Tidak ada barang dipilih untuk disetujui'
        : (isAll
            ? 'Semua $total barang akan disetujui'
            : '${selected.length} dari $total barang akan disetujui, ${total - selected.length} ditolak');
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Kartu detail per item ──────────────────────────────────────────────
  Widget _itemDetailCard({
    required int index,
    required Map<String, dynamic> item,
    required bool isExternal,
    bool isPending = false,
    bool multiItem = false,
    bool isSelected = true,
    VoidCallback? onToggle,
    String? finalDecision,
  }) {
    final qty = item['qty'];
    final unit = item['unit'] ?? '';
    final photo = item['photo'] as String?;

    final selectable = isPending && multiItem;
    final dimmed = selectable && !isSelected;
    final processedAcc = finalDecision == 'approved';
    final processedRej = finalDecision == 'rejected';

    // Header leading: checkbox saat selectable, nomor saat tidak.
    final Widget headerLeading = selectable
        ? Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.statusApproved : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppTheme.statusApproved
                    : Colors.grey.shade400,
                width: 1.6,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 16)
                : null,
          )
        : Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: processedRej
                  ? AppTheme.statusRejected
                  : AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );

    final headerBg = dimmed
        ? Colors.grey.shade100
        : (processedRej
            ? AppTheme.statusRejected.withOpacity(0.05)
            : (processedAcc
                ? AppTheme.statusApproved.withOpacity(0.06)
                : AppTheme.primary.withOpacity(0.06)));

    final borderColor = dimmed
        ? Colors.grey.shade200
        : (selectable && isSelected
            ? AppTheme.statusApproved.withOpacity(0.6)
            : (processedAcc
                ? AppTheme.statusApproved.withOpacity(0.4)
                : (processedRej
                    ? AppTheme.statusRejected.withOpacity(0.4)
                    : Colors.grey.shade200)));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: (selectable && isSelected) ||
                  processedAcc ||
                  processedRej
              ? 1.6
              : 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header item — tappable kalau selectable
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: selectable ? onToggle : null,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: headerBg,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(13)),
                ),
                child: Row(
                  children: [
                    headerLeading,
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item['name'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: dimmed
                              ? Colors.grey.shade500
                              : AppTheme.textPrimary,
                          decoration: dimmed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    // Pill keputusan (mode read-only)
                    if (processedAcc || processedRej) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: (processedAcc
                                  ? AppTheme.statusApproved
                                  : AppTheme.statusRejected)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: processedAcc
                                ? AppTheme.statusApproved
                                : AppTheme.statusRejected,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              processedAcc
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              size: 11,
                              color: processedAcc
                                  ? AppTheme.statusApproved
                                  : AppTheme.statusRejected,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              processedAcc ? 'ACC' : 'TOLAK',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: processedAcc
                                    ? AppTheme.statusApproved
                                    : AppTheme.statusRejected,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: dimmed
                            ? Colors.grey.shade400
                            : AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$qty $unit',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Body item — di-dim saat unselected
          Opacity(
            opacity: dimmed ? 0.45 : 1.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                if (!isExternal) ...[
                  _miniInfoRow(
                    Icons.qr_code_rounded,
                    'Kode',
                    (item['code'] as String?)?.isNotEmpty == true
                        ? item['code'] as String
                        : '-',
                  ),
                ] else ...[
                  _miniInfoLabel('Spesifikasi'),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      (item['spec'] as String?) ?? '-',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _miniInfoRow(
                          Icons.payments_rounded,
                          'Estimasi Harga',
                          item['price'] != null
                              ? _formatRupiah(
                                  (item['price'] as num).toInt())
                              : '-',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _miniInfoRow(
                          Icons.calculate_rounded,
                          'Subtotal',
                          item['price'] != null
                              ? _formatRupiah(((item['price'] as num) *
                                      (item['qty'] as num))
                                  .toInt())
                              : '-',
                          highlight: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Link pembelian (placeholder, tap = snackbar)
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Link: ${item['link'] ?? '-'}  (demo)'),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.link_rounded,
                              size: 16, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (item['link'] as String?) ?? '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Icon(Icons.open_in_new_rounded,
                              size: 14, color: AppTheme.primary),
                        ],
                      ),
                    ),
                  ),
                ],

                // Foto terlampir / placeholder kosong
                const SizedBox(height: 10),
                _photoPreview(photo),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _photoPreview(String? photo) {
    final hasPhoto = photo != null;
    return GestureDetector(
      onTap: hasPhoto
          ? () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: Colors.grey.shade200),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_rounded,
                                    size: 60,
                                    color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  photo,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '(preview foto contoh — demo)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                            child: const Text('Tutup',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: hasPhoto
              ? AppTheme.primary.withOpacity(0.06)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasPhoto
                ? AppTheme.primary.withOpacity(0.25)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: hasPhoto
                    ? AppTheme.primary
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasPhoto
                    ? Icons.image_rounded
                    : Icons.image_not_supported_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasPhoto ? 'Foto Contoh Terlampir' : 'Tanpa Foto',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    hasPhoto
                        ? '${photo}  •  ketuk untuk pratinjau'
                        : 'User tidak melampirkan foto contoh',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasPhoto)
              const Icon(Icons.zoom_in_rounded,
                  size: 18, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  // ─── Helpers UI kecil ────────────────────────────────────────────────────
  Widget _pill({
    required String text,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color ?? AppTheme.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color ?? AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfoLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _miniInfoRow(IconData icon, String label, String value,
      {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? AppTheme.primary.withOpacity(0.08)
            : AppTheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 14,
              color:
                  highlight ? AppTheme.primary : Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: highlight
                        ? AppTheme.primary
                        : AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Persetujuan Permintaan'),
        flexibleSpace: Container(
          decoration:
              const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        actions: [
          IconButton(
            tooltip: 'Cek Stok',
            icon: const Icon(Icons.fact_check_rounded),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const StockCheckPage()),
              );
            },
          ),
          IconButton(
            tooltip: 'Update Bulanan',
            icon: const Icon(Icons.edit_calendar_rounded),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MonthlyStockUpdatePage()),
              );
            },
          ),
          IconButton(
            tooltip: 'Inventaris',
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () {
              HapticFeedback.selectionClick();
              if (widget.onNavigate != null) {
                widget.onNavigate!(2);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Buka tab "Inventaris" di bawah.'),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _filters.asMap().entries.map((e) {
                final selected = _filter == e.key;
                final count = _filterCount(e.key);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            e.value,
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
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),

          // List
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
                          'Tidak ada permintaan',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(14),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _buildRequestCard(_filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Kartu ringkas di list ──────────────────────────────────────────────
  Widget _buildRequestCard(Map<String, dynamic> req) {
    final color = _statusColor(req['status'] as String);
    final external = _isExternal(req);
    final items = _items(req);
    final firstItem =
        items.isNotEmpty ? items.first : <String, dynamic>{};
    final extraCount = items.length - 1;
    final photoCount = _photoCount(req);
    final totalEst = _totalEstimate(req);

    return GestureDetector(
      onTap: () => _showDetail(req),
      child: Container(
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
            // Baris badge
            Row(
              children: [
                _pill(
                    text: _statusLabel(req['status'] as String),
                    color: color),
                const SizedBox(width: 6),
                _pill(
                  text: external ? 'LUAR' : 'GUDANG',
                  color: external
                      ? AppTheme.primary
                      : AppTheme.statusApproved,
                  icon: external
                      ? Icons.storefront_rounded
                      : Icons.warehouse_rounded,
                ),
                const SizedBox(width: 6),
                _pill(
                  text:
                      'PRIO ${(req['priority'] as String).toUpperCase()}',
                  color: _priorityColor(req['priority'] as String),
                ),
                const Spacer(),
                Text(
                  req['code'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Nama item utama
            Text(
              (firstItem['name'] as String?) ?? '-',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${firstItem['qty'] ?? '-'} ${firstItem['unit'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (extraCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+$extraCount jenis lain',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
                if (photoCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          AppTheme.statusApproved.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.image_rounded,
                            size: 10,
                            color: AppTheme.statusApproved),
                        const SizedBox(width: 3),
                        Text(
                          '$photoCount',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.statusApproved,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Breakdown ACC untuk request parsial
                if (req['status'] == 'partial') ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fact_check_rounded,
                            size: 10, color: AppTheme.primary),
                        const SizedBox(width: 3),
                        Text(
                          '${_approvedItemCount(req)}/${items.length} ACC',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            // Estimasi pembelian (luar saja)
            if (external && totalEst > 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.payments_rounded,
                      size: 13, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Est. ${_formatRupiah(totalEst)}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            // Pemohon + tanggal
            Row(
              children: [
                Icon(Icons.person_outline_rounded,
                    size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${req['requester']} · ${req['role']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${req['date']} · ${req['time']}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
