import 'package:flutter/material.dart';
import 'main.dart'; // untuk class Barang

class DashboardPage extends StatelessWidget {
  final ValueNotifier<List<Barang>> daftar;
  final VoidCallback onLihatInventaris;

  const DashboardPage({
    super.key,
    required this.daftar,
    required this.onLihatInventaris,
  });

  static const int batasStok = 5; // peringatan jika stok < 5

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ValueListenableBuilder<List<Barang>>(
        valueListenable: daftar,
        builder: (context, barang, _) {
          final menipis = barang.where((b) => b.stok < batasStok).toList()
            ..sort((a, b) => a.stok.compareTo(b.stok));
          final totalStok = barang.fold<int>(0, (jumlah, b) => jumlah + b.stok);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                Expanded(
                  child: _KartuRingkasan(
                    judul: 'Total Barang',
                    nilai: '${barang.length}',
                    ikon: Icons.inventory_2,
                    warna: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KartuRingkasan(
                    judul: 'Stok < $batasStok',
                    nilai: '${menipis.length}',
                    ikon: Icons.warning_amber_rounded,
                    warna: menipis.isEmpty ? Colors.green : Colors.red,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              _KartuRingkasan(
                judul: 'Total Seluruh Stok',
                nilai: '$totalStok',
                ikon: Icons.stacked_bar_chart,
                warna: Colors.teal,
              ),
              const SizedBox(height: 24),
              Text('Peringatan Stok Menipis',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (menipis.isEmpty)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Semua stok aman'),
                  ),
                )
              else
                ...menipis.map((b) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.warning, color: Colors.red),
                        title: Text(b.nama),
                        subtitle: Text(b.kode),
                        trailing: Text(
                          'Stok: ${b.stok}',
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onLihatInventaris,
                icon: const Icon(Icons.list),
                label: const Text('Lihat Semua Barang'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KartuRingkasan extends StatelessWidget {
  final String judul;
  final String nilai;
  final IconData ikon;
  final Color warna;

  const _KartuRingkasan({
    required this.judul,
    required this.nilai,
    required this.ikon,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: warna.withOpacity(0.15),
            child: Icon(ikon, color: warna),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul, style: Theme.of(context).textTheme.bodySmall),
                Text(nilai,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}