# Kalbe-Nutritional_Database-Administrator_VIProgram

Pada Final task , peserta akan diuji menggunakan proyek atau studi kasus yang biasa dihadapi oleh seorang Database Administrator di Kalbe. Salah satu tanggung jawab data entry yaitu mampu melakukan alerting, import&export data pada database dengan format CSV ataupun sebaliknya, membuat report recap ticket, monitoring performance database dan melakukan proses backup restore database yang bertujuan untuk pemeliharaan databases.

# Challenge
Di dalam PT Kalbe Nutritionals akan dibuat sebuah software manajemen distribusi produk. Software ini akan digunakan untuk mencatat dan mentracking status pengiriman barang dari gudang PT Kalbe nutritionals ke toko. Sebelum dibuatnya software ini, proses pencatatan dilakukan di dalam sebuah spreadsheet. File hasil pencatatan distribusi terlampir di dalam lampiran Berikut. <br> <br> 
[lampiran 1](https://docs.google.com/spreadsheets/d/1TOwnB6J1yN_ZibPF2541ZdLFSLO90ZtPZSD8aqQsULY/edit#gid=0) <br>

[lampiran 2](https://docs.google.com/spreadsheets/d/1ILNAy_AExkdU9v0LLz9LG60D0AWo8Ko2o8ZQj4J9ulo/edit#gid=0)

## Lakukanlah normalisasi dari hasil pencatatan distribusi barang tersebut
<pre>
● Buatlah ERD berdasarkan hasil dari normalisasi data distribusi barang 
● Buatlah database dan struktur table & relasi menggunakan RDBMS PostgreSQL 
  ○ Buatlah struktur table tersebut di dalam schema yang bernama app 
  ○ Untuk data produk, silahkan import dari file lampiran kedua
  ○ Buatlah sebuah user yang akan digunakan oleh backend programmer untuk melakukan operasi database dengan akses hanya dapat melakukan DML (INSERT, UPDATE, DELETE, SELECT)
  ○ Buatlah index di dalam table sesuai kebutuhan untuk mengoptimalkan query </pre>

## Buatlah query untuk kebutuhan - kebutuhan di bawah ini
<pre>  ○ Menampilkan 2 driver dengan pengiriman terbanyak bulan Mei 2023
  ○ Menampilkan 10 barang paling sering dikirim di bulan Mei 2023
  ○ Menampilkan semua pengiriman yang belum selesai <br>
● Buatlah sebuah user defined function
  ○ Untuk membuat ID Shipment dengan format yymmddxxx (contoh: 230519001, 230519002) <br>
● Buatlah 2 buah stored procedure
  ○ Untuk membuat shipment baru
  ○ Untuk menambahkan product ke dalam shipment <br>
● Buatlah Daily Backup
 ○ Buatlah task / job untuk melakukan backup database pukul 23:00 setiap hari
</pre>
