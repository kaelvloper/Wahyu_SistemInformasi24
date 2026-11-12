import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: InventarisPage(),
));

class Barang {
  final String kode;
  final String nama;
  final int stok;
  const Barang({required this.kode, required this.nama, required this.stok});
  Barang copyWith({String? nama, int? stok}) => Barang(
    kode: kode, nama: nama ?? this.nama, stok: stok ?? this.stok,
  );
  Map<String, dynamic> toJson() => {'kode': kode, 'nama': nama, 'stok': stok};
  factory Barang.fromJson(Map<String, dynamic> j) => Barang(
    kode: j['kode'] as String,
    nama: j['nama'] as String,
    stok: (j['stok'] as num).toInt(),
  );
}

class InventarisPage extends StatefulWidget {
  const InventarisPage({super.key});
  @override
  State<InventarisPage> createState() => _InventarisPageState();
}

class _InventarisPageState extends State<InventarisPage> {
  final List<Barang> _barang = [
    const Barang(kode: 'BRG001', nama: 'Mouse', stok: 5),
    const Barang(kode: 'BRG002', nama: 'Keyboard', stok: 3),
  ];

  bool _loading = true;
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  static const String _key = 'inventaris_v1';

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final saved = await _prefs.getString(_key);
      if (!mounted) return;
      if (saved != null) {
        final raw = jsonDecode(saved) as List<dynamic>;
        setState(() {
          _barang
            ..clear()
            ..addAll(raw.map((e) => Barang.fromJson(e as Map<String, dynamic>)));
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _simpan() async {
    final data = jsonEncode(_barang.map((e) => e.toJson()).toList());
    try {
      await _prefs.setString(_key, data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }

  Future<void> _tambah() async {
    final baru = await Navigator.push<Barang>(context,
      MaterialPageRoute(builder: (_) => const FormBarangPage()));
    if (!mounted || baru == null) return;
    if (_barang.any((item) => item.kode.toLowerCase() == baru.kode.toLowerCase())) {
      _pesan('Kode barang sudah digunakan');
      return;
    }
    setState(() => _barang.add(baru));
    await _simpan();
  }

  void _pesan(String pesan) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(pesan)));

  Future<void> _ubah(Barang asal) async {
    final hasil = await Navigator.push<Barang>(context,
      MaterialPageRoute(builder: (_) => FormBarangPage(barang: asal)));
    if (!mounted || hasil == null) return;
    final index = _barang.indexWhere((item) => item.kode == asal.kode);
    if (index < 0) return;
    setState(() => _barang[index] = hasil);
    await _simpan();
  }

  Future<void> _hapus(Barang barang) async {
    final setuju = await showDialog<bool>(context: context, builder: (ctx) =>
      AlertDialog(
        title: const Text('Hapus barang?'),
        content: Text('Hapus ${barang.nama} (${barang.kode})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (!mounted || setuju != true) return;
    setState(() => _barang.removeWhere((item) => item.kode == barang.kode));
    await _simpan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventaris Laboratorium')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
          itemCount: _barang.length,
          itemBuilder: (context, i) {
            final b = _barang[i];
            return Card(child: ListTile(
              title: Text(b.nama),
              subtitle: Text('${b.kode} • Stok: ${b.stok}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(tooltip: 'Edit', onPressed: () => _ubah(b), icon: const Icon(Icons.edit)),
IconButton(tooltip: 'Hapus', onPressed: () => _hapus(b), icon: const Icon(Icons.delete)),
]),
            ));
          },
        ),
      floatingActionButton: FloatingActionButton(onPressed: _tambah, child: const Icon(Icons.add)),
    );
  }
}

class FormBarangPage extends StatefulWidget {
  final Barang? barang;
  const FormBarangPage({super.key, this.barang});
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
    _kode = TextEditingController(text: widget.barang?.kode ?? '');
    _nama = TextEditingController(text: widget.barang?.nama ?? '');
    _stok = TextEditingController(text: widget.barang?.stok.toString() ?? '');
  }

  @override
  void dispose() {
    _kode.dispose();
    _nama.dispose();
    _stok.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.barang == null ? 'Tambah Barang' : 'Ubah Barang')),
    body: Form(
      key: _form,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(
          controller: _kode,
          readOnly: widget.barang != null,
          decoration: const InputDecoration(labelText: 'Kode barang'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Kode wajib diisi' : null,
        ),
        TextFormField(
          controller: _nama,
          decoration: const InputDecoration(labelText: 'Nama barang'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
        ),
        TextFormField(
          controller: _stok,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Stok'),
          validator: (v) {
            final n = int.tryParse(v?.trim() ?? '');
            if (n == null) return 'Stok harus angka bulat';
            if (n < 0) return 'Stok tidak boleh negatif';
            return null;
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: () {
          if (!_form.currentState!.validate()) return;
          Navigator.pop(context, Barang(
            kode: _kode.text.trim(),
            nama: _nama.text.trim(),
            stok: int.parse(_stok.text.trim()),
          ));
        }, child: const Text('Simpan')),
      ]),
    ),
  );
}

