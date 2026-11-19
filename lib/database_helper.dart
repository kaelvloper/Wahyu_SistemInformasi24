// SQLite untuk inventaris laboratorium
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BarangDb {
  Database? _db;
  Future<Database> get db async {
    if (_db != null) return _db!;
    final lokasi = join(await getDatabasesPath(), 'inventaris.db');
    _db = await openDatabase(
      lokasi,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE barang (
            kode TEXT PRIMARY KEY,
            nama TEXT NOT NULL,
            stok INTEGER NOT NULL CHECK (stok >= 0),
            kategori TEXT NOT NULL DEFAULT 'Lainnya'
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE barang ADD COLUMN kategori TEXT NOT NULL DEFAULT 'Lainnya'");
        }
      },
    );
    return _db!;
  }

  Future<List<Map<String, Object?>>> baca() async =>
      (await db).query('barang', orderBy: 'nama ASC');

  Future<int> tambah(String kode, String nama, int stok, [String kategori = 'Lainnya']) async =>
      (await db).insert('barang', {
        'kode': kode,
        'nama': nama,
        'stok': stok,
        'kategori': kategori,
      });

  Future<int> ubah(String kode, String nama, int stok, [String kategori = 'Lainnya']) async =>
      (await db).update(
        'barang',
        {'nama': nama, 'stok': stok, 'kategori': kategori},
        where: 'kode = ?',
        whereArgs: [kode],
      );

  Future<int> hapus(String kode) async =>
      (await db).delete('barang', where: 'kode = ?', whereArgs: [kode]);
}
