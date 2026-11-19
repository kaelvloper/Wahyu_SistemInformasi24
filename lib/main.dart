import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(const InventarisApp());
}

class InventarisApp extends StatelessWidget {
  const InventarisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventaris Laboratorium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
      home: const InventarisPage(),
    );
  }
}

// MODEL DATA BARANG
class Barang {
  final String kode;
  final String nama;
  final int stok;

  const Barang({
    required this.kode,
    required this.nama,
    required this.stok,
  });

  Barang copyWith({String? nama, int? stok}) {
    return Barang(
      kode: kode,
      nama: nama ?? this.nama,
      stok: stok ?? this.stok,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode': kode,
      'nama': nama,
      'stok': stok,
    };
  }

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      kode: json['kode'] as String,
      nama: json['nama'] as String,
      stok: (json['stok'] as num).toInt(),
    );
  }
}

// HALAMAN UTAMA INVENTARIS
class InventarisPage extends StatefulWidget {
  const InventarisPage({super.key});

  @override
  State<InventarisPage> createState() => _InventarisPageState();
}

class _InventarisPageState extends State<InventarisPage> {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F7FC);

  final List<Barang> _barang = [];
  bool _loading = true;
  final BarangDb _db = BarangDb();
  String _pencarian = '';

  @override
  void initState() {
    super.initState();
    _muat();
  }

  // MEMUAT DATA LOKAL DARI SQLITE
  Future<void> _muat() async {
    try {
      final rows = await _db.baca();
      if (!mounted) return;
      setState(() {
        _barang
          ..clear()
          ..addAll(rows.map((e) => Barang.fromJson(Map<String, dynamic>.from(e))));
      });
    } catch (e) {
      if (mounted) {
        _pesan('Gagal memuat data: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _pesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // TAMBAH BARANG KE SQLITE
  Future<void> _tambah() async {
    final baru = await Navigator.push<Barang>(
      context,
      MaterialPageRoute(
        builder: (_) => const FormBarangPage(),
      ),
    );

    if (!mounted || baru == null) return;

    if (_barang.any(
      (item) => item.kode.toLowerCase() == baru.kode.toLowerCase(),
    )) {
      _pesan('Kode barang sudah digunakan');
      return;
    }

    try {
      await _db.tambah(baru.kode, baru.nama, baru.stok);
      await _muat();
      if (mounted) _pesan('Barang berhasil ditambahkan');
    } catch (e) {
      if (mounted) _pesan('Gagal menambah barang: $e');
    }
  }

  // EDIT BARANG DI SQLITE
  Future<void> _ubah(Barang asal) async {
    final hasil = await Navigator.push<Barang>(
      context,
      MaterialPageRoute(
        builder: (_) => FormBarangPage(barang: asal),
      ),
    );

    if (!mounted || hasil == null) return;

    try {
      await _db.ubah(asal.kode, hasil.nama, hasil.stok);
      await _muat();
      if (mounted) _pesan('Barang berhasil diperbarui');
    } catch (e) {
      if (mounted) _pesan('Gagal mengubah barang: $e');
    }
  }

  // HAPUS BARANG DARI SQLITE
  Future<void> _hapus(Barang barang) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Hapus Barang?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus '
          '${barang.nama} (${barang.kode})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (!mounted || setuju != true) return;

    try {
      await _db.hapus(barang.kode);
      await _muat();
      if (mounted) _pesan('Barang berhasil dihapus');
    } catch (e) {
      if (mounted) _pesan('Gagal menghapus barang: $e');
    }
  }

  // KARTU STATISTIK
  Widget _kartuStatistik(
    String judul,
    String nilai,
    IconData ikon,
    Color warna,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(ikon, color: warna, size: 25),
          ),
          const SizedBox(height: 13),
          Text(
            nilai,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: warna,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            judul,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // KARTU BARANG
  Widget _kartuBarang(Barang barang) {
    final tersedia = barang.stok > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.devices_other_rounded,
              color: primary,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barang.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kode: ${barang.kode}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: tersedia
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Stok: ${barang.stok}',
                    style: TextStyle(
                      color: tersedia
                          ? const Color(0xFF15803D)
                          : const Color(0xFFDC2626),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: 'Edit Barang',
                onPressed: () => _ubah(barang),
                icon: const Icon(
                  Icons.edit_rounded,
                  color: primary,
                ),
              ),
              IconButton(
                tooltip: 'Hapus Barang',
                onPressed: () => _hapus(barang),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAMPILAN HALAMAN UTAMA
  @override
  Widget build(BuildContext context) {
    final totalStok = _barang.fold<int>(
      0,
      (total, item) => total + item.stok,
    );

    final hasilPencarian = _barang.where((barang) {
      final keyword = _pencarian.toLowerCase();

      return barang.nama.toLowerCase().contains(keyword) ||
          barang.kode.toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventaris Laboratorium',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Sistem Manajemen Inventaris',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat Ulang',
            onPressed: _muat,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                // HEADER DASHBOARD
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1D4ED8),
                        Color(0xFF60A5FA),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Dashboard Inventaris',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Kelola dan pantau seluruh perlengkapan '
                        'laboratorium dengan lebih mudah.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // RINGKASAN STATISTIK
                Row(
                  children: [
                    Expanded(
                      child: _kartuStatistik(
                        'Jenis Barang',
                        '${_barang.length}',
                        Icons.category_rounded,
                        primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _kartuStatistik(
                        'Total Stok',
                        '$totalStok',
                        Icons.inventory_rounded,
                        const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 27),

                const Text(
                  'Daftar Inventaris',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Daftar barang yang tersedia di laboratorium',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 17),

                // PENCARIAN BARANG
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _pencarian = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau kode barang...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: primary,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // DAFTAR BARANG
                if (hasilPencarian.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(35),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _barang.isEmpty
                              ? 'Belum ada barang'
                              : 'Barang tidak ditemukan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _barang.isEmpty
                              ? 'Tekan tombol tambah untuk mulai'
                              : 'Coba kata kunci pencarian lain',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...hasilPencarian.map(_kartuBarang),

                const SizedBox(height: 75),
              ],
            ),

      // TOMBOL TAMBAH BARANG
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambah,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Barang',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// HALAMAN FORM TAMBAH DAN EDIT BARANG
class FormBarangPage extends StatefulWidget {
  final Barang? barang;

  const FormBarangPage({
    super.key,
    this.barang,
  });

  @override
  State<FormBarangPage> createState() => _FormBarangPageState();
}

class _FormBarangPageState extends State<FormBarangPage> {
  final _form = GlobalKey<FormState>();

  late final TextEditingController _kode;
  late final TextEditingController _nama;
  late final TextEditingController _stok;

  @override
  void initState() {
    super.initState();

    _kode = TextEditingController(
      text: widget.barang?.kode ?? '',
    );

    _nama = TextEditingController(
      text: widget.barang?.nama ?? '',
    );

    _stok = TextEditingController(
      text: widget.barang?.stok.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _kode.dispose();
    _nama.dispose();
    _stok.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.barang != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Barang' : 'Tambah Barang',
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),

            const Icon(
              Icons.inventory_2_rounded,
              color: Color(0xFF2563EB),
              size: 55,
            ),

            const SizedBox(height: 15),

            Text(
              isEdit
                  ? 'Perbarui Data Barang'
                  : 'Masukkan Data Barang',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            TextFormField(
              controller: _kode,
              readOnly: isEdit,
              decoration: const InputDecoration(
                labelText: 'Kode Barang',
                prefixIcon: Icon(Icons.qr_code_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kode barang wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 17),

            TextFormField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama Barang',
                prefixIcon: Icon(Icons.inventory_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama barang wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 17),

            TextFormField(
              controller: _stok,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Stok',
                prefixIcon: Icon(Icons.numbers_rounded),
              ),
              validator: (value) {
                final jumlah = int.tryParse(value?.trim() ?? '');

                if (jumlah == null) {
                  return 'Stok harus berupa angka bulat';
                }

                if (jumlah < 0) {
                  return 'Stok tidak boleh negatif';
                }

                return null;
              },
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (!_form.currentState!.validate()) {
                    return;
                  }

                  Navigator.pop(
                    context,
                    Barang(
                      kode: _kode.text.trim(),
                      nama: _nama.text.trim(),
                      stok: int.parse(_stok.text.trim()),
                    ),
                  );
                },
                icon: const Icon(Icons.save_rounded),
                label: Text(
                  isEdit ? 'Simpan Perubahan' : 'Simpan Barang',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
