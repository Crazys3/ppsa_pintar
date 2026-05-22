import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PPSA Pintar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Segoe UI', // Font modern default web
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Deep Blue
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF10B981), // Emerald Green
        ),
      ),
      home: const HalamanUtama(),
    );
  }
}

class ItemData {
  final String nama;
  final String kategori;
  final DateTime tanggal;

  ItemData({required this.nama, required this.kategori, required this.tanggal});
}

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  // Simulasi database lokal dengan data awal
  final List<ItemData> _daftarData = [
    ItemData(
      nama: "Sistem Pemantauan Awal",
      kategori: "Utama",
      tanggal: DateTime.now(),
    ),
    ItemData(
      nama: "Modul Analisis Data",
      kategori: "Tambahan",
      tanggal: DateTime.now(),
    ),
  ];

  final TextEditingController _namaController = TextEditingController();
  String _kategoriTerpilih = 'Utama'; // Dropdown value

  void _tambahDataBaru() {
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama data tidak boleh kosong!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // UPDATE STATE: Menambahkan objek baru ke list dan memperbarui UI instan
    setState(() {
      _daftarData.insert(
        0, // Agar data terbaru selalu muncul paling atas
        ItemData(
          nama: _namaController.text.trim(),
          kategori: _kategoriTerpilih,
          tanggal: DateTime.now(),
        ),
      );
      _namaController.clear(); // Reset form input nama
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil ditambahkan ke dashboard!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menghitung jumlah data untuk komponen ringkasan (counter cards)
    int totalUtama = _daftarData.where((d) => d.kategori == 'Utama').length;
    int totalTambahan = _daftarData
        .where((d) => d.kategori == 'Tambahan')
        .length;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFC,
      ), // Background abu-abu sangat muda (Slate)
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.insights, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'PPSA PINTAR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A8A),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN 1: STATISTIK RINGKASAN (MODERN COUNTER CARDS) ---
            const Text(
              'Ringkasan Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Komponen Utama',
                    value: '$totalUtama',
                    icon: Icons.layers,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Komponen Tambahan',
                    value: '$totalTambahan',
                    icon: Icons.extension,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- BAGIAN 2: PANEL INPUT DATA ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  const Text(
                    'Tambah Data Komponen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Input Nama
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _namaController,
                          decoration: InputDecoration(
                            labelText: 'Nama Komponen / Data',
                            prefixIcon: const Icon(Icons.edit_note),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Dropdown Kategori
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _kategoriTerpilih,
                          decoration: InputDecoration(
                            labelText: 'Pilih Kategori',
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                          items: <String>['Utama', 'Tambahan'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _kategoriTerpilih = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Tombol Tambah
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _tambahDataBaru,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Tambah',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- BAGIAN 3: TABEL / LIST DATA UTAMA ---
            const Text(
              'Daftar Komponen Terdaftar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),
            _daftarData.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Belum ada data komponen yang diinput.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _daftarData.length,
                    itemBuilder: (context, index) {
                      final item = _daftarData[index];
                      final isUtama = item.kategori == 'Utama';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isUtama
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFECFDF5),
                            child: Icon(
                              isUtama ? Icons.layers : Icons.extension,
                              color: isUtama
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFF10B981),
                            ),
                          ),
                          title: Text(
                            item.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: Text(
                            'Diinput pada: ${item.tanggal.hour}:${item.tanggal.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isUtama
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.kategori,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk membuat Card Ringkasan Statistik
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Icon(icon, size: 36, color: color.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}
