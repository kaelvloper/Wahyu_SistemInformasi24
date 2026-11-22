# TESTING REPORT

## Aplikasi Inventaris Laboratorium

**Nama Proyek:** Wahyu_SistemInformasi24  
**Platform:** Flutter (Dart)  
**Perangkat Pengujian:** Vivo 1901, Android 11  
**Metode Pengujian:** Black Box Testing dan Code Review  
**Tanggal Pengujian:** 21 November 2026

### 1. Tujuan Pengujian

Pengujian dilakukan untuk memastikan seluruh fitur aplikasi Inventaris Laboratorium dapat berjalan dengan baik sesuai kebutuhan. Pengujian mencakup proses pengelolaan data barang, validasi input, pencarian, navigasi, serta penyimpanan data lokal. Selain itu, dilakukan pemeriksaan kode program untuk meninjau penerapan fungsi dan logika aplikasi sebelum kode dikirim ke GitHub.

### 2. Metode Pengujian

Pengujian dilakukan menggunakan dua pendekatan, yaitu Black Box Testing dan Code Review.

**Black Box Testing** dilakukan dengan menjalankan aplikasi secara langsung pada perangkat Android dan mencoba setiap fitur untuk memastikan hasilnya sesuai dengan yang diharapkan.

**Code Review** dilakukan dengan memeriksa kode program Flutter dan Dart, termasuk bagian pengelolaan data, validasi input, serta fungsi yang digunakan dalam aplikasi.

### 3. Tabel Hasil Pengujian

| No | Fitur | Skenario Pengujian | Hasil Pengujian | Status |
|---|---|---|---|---|
| 1 | Menjalankan Aplikasi | Membuka aplikasi melalui Flutter pada perangkat Android | Aplikasi berhasil dijalankan | PASS |
| 2 | Tambah Barang | Memasukkan data barang baru dan menyimpannya | Data berhasil ditambahkan | PASS |
| 3 | Edit Barang | Mengubah informasi barang yang sudah tersimpan | Data berhasil diperbarui | PASS |
| 4 | Hapus Barang | Menghapus salah satu data barang | Data berhasil dihapus | PASS |
| 5 | Validasi Nama | Mengosongkan kolom nama barang | Sistem menampilkan pesan validasi | PASS |
| 6 | Validasi Jumlah | Memasukkan jumlah barang bernilai negatif | Sistem menolak input tidak valid | PASS |
| 7 | Pencarian Barang | Mencari barang berdasarkan nama | Hasil pencarian sesuai kata kunci | PASS |
| 8 | Penyimpanan Lokal | Menutup dan membuka kembali aplikasi | Data tetap tersimpan | PASS |
| 9 | Navigasi Halaman | Berpindah dari satu halaman ke halaman lainnya | Seluruh halaman dapat diakses | PASS |
| 10 | Stabilitas Aplikasi | Menggunakan seluruh fitur secara berulang | Aplikasi berjalan tanpa crash | PASS |

### 4. Pemeriksaan Kode Program (Code Review)

Pemeriksaan kode program dilakukan dengan meninjau kode Flutter dan Dart yang digunakan dalam pengembangan aplikasi Inventaris Laboratorium. Pemeriksaan mencakup struktur kode, fungsi pengelolaan data barang, proses penyimpanan lokal, serta penerapan validasi input. Pemeriksaan ini dilakukan untuk membantu memastikan kode yang digunakan sesuai dengan kebutuhan aplikasi dan mendukung fitur yang telah diuji.

### 5. Pengujian Validasi Input

Pengujian validasi input dilakukan untuk memastikan aplikasi dapat mencegah penyimpanan data yang tidak sesuai. Pengujian dilakukan dengan mengosongkan kolom nama barang dan memasukkan jumlah barang bernilai negatif. Berdasarkan hasil pengujian, aplikasi berhasil menampilkan pesan kesalahan dan menolak data yang tidak valid. Dengan demikian, validasi input yang telah diterapkan dapat berjalan sesuai dengan fungsinya.

### 6. Rekapitulasi Hasil Pengujian

| Keterangan | Jumlah |
|---|---|
| Total Pengujian | 10 |
| Pengujian Berhasil (PASS) | 10 |
| Pengujian Gagal (FAIL) | 0 |
| Persentase Keberhasilan | 100% |

### 7. Kesimpulan

Berdasarkan hasil pengujian yang telah dilakukan, seluruh fitur aplikasi Inventaris Laboratorium berhasil berjalan sesuai dengan fungsinya. Pengujian dilakukan melalui perangkat Android menggunakan metode Black Box Testing serta pemeriksaan kode program melalui Code Review. Fitur tambah, edit, hapus, pencarian, validasi input, navigasi, dan penyimpanan data lokal menunjukkan hasil yang sesuai dengan harapan. Dari 10 skenario pengujian, seluruhnya memperoleh status PASS dengan tingkat keberhasilan 100%. Dengan demikian, aplikasi telah menyelesaikan pengujian fungsional yang dilakukan dan siap dilanjutkan ke proses commit dan push ke GitHub.