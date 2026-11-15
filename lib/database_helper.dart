// REFERENSI OPSIONAL: SQLite untuk Android/iOS/macOS. BUKAN untuk flutter run -d chrome.
// Jalankan: flutter pub add sqflite path
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BarangDb {
  Database? _db;
  Future<Database> get db async {
    if (_db != null) return _db!;
    final lokasi = join(await getDatabasesPath(), 'inventaris.db');
    _db = await openDatabase(lokasi, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE barang (
          kode TEXT PRIMARY KEY,
          nama TEXT NOT NULL,
          stok INTEGER NOT NULL CHECK (stok >= 0)
        )
      ''');
    });
    return _db!;
  }

  Future<List<Map<String, Object?>>> baca() async => (await db).query('barang', orderBy: 'nama ASC');
  Future<int> tambah(String kode, String nama, int stok) async => (await db)
      .insert('barang', {'kode': kode, 'nama': nama, 'stok': stok});
  Future<int> ubah(String kode, String nama, int stok) async => (await db)
      .update('barang', {'nama': nama, 'stok': stok}, where: 'kode = ?', whereArgs: [kode]);
  Future<int> hapus(String kode) async => (await db)
      .delete('barang', where: 'kode = ?', whereArgs: [kode]);
}
