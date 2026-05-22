import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PPSA Pintar Ultra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Segoe UI',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A), // Slate Dark
          primary: const Color(0xFF2563EB), // Royal Blue Accent
          secondary: const Color(0xFF10B981), // Emerald Green
          background: const Color(0xFFF1F5F9), // Light Gray Slate
        ),
      ),
      home: const HalamanUtama(),
    );
  }
}

class ItemData {
  final String id;
  final String nama;
  final String kategori;
  final DateTime tanggal;

  ItemData({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.tanggal,
  });

  // Konversi ke Map untuk disimpan ke Local Storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'kategori': kategori,
      'tanggal': tanggal.toIso8601String(),
    };
  }

  // Ambil dari Map Local Storage
  factory ItemData.fromMap(Map<String, dynamic> map) {
    return ItemData(
      id: map['id'],
      nama: map['nama'],
      kategori: map['kategori'],
      tanggal: DateTime.parse(map['tanggal']),
    );
  }
}

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  List<ItemData> _daftarData = [];
  bool _sedangMemuat = true;
  final TextEditingController _namaController = TextEditingController();
  String _kategoriTerpilih = 'Utama';

  @override
  void initState() {
    super.initState();
    _muatDataDariStorage();
  }

  // FUNGSI 1: Membaca data yang tersimpan di browser
  Future<void> _muatDataDariStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('ppsa_data');
    if (dataString != null) {
      final List<dynamic> decodedList = jsonDecode(dataString);
      setState(() {
        _daftarData = decodedList
            .map((item) => ItemData.fromMap(item))
            .toList();
        _sedangMemuat = false;
      });
    } else {
      setState(() {
        _daftarData = [
          ItemData(
            id: '1',
            nama: "Sistem Manajemen Inti",
            kategori: "Utama",
            tanggal: DateTime.now(),
          ),
          ItemData(
            id: '2',
            nama: "Plugin Ekstensi Web",
            kategori: "Tambahan",
            tanggal: DateTime.now(),
          ),
        ];
        _sedangMemuat = false;
      });
      _simpanDataKeStorage();
    }
  }

  // FUNGSI 2: Menyimpan data secara permanen ke browser
  Future<void> _simpanDataKeStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _daftarData.map((item) => item.toMap()).toList(),
    );
    await prefs.setString('ppsa_data', encodedData);
  }

  // FUNGSI 3: Tambah Data Instan
  void _tambahDataBaru() {
    if (_namaController.text.trim().isEmpty) {
      _tampilkanNotifikasi('Nama data tidak boleh kosong!', Colors.redAccent);
      return;
    }

    setState(() {
      _daftarData.insert(
        0,
        ItemData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nama: _namaController.text.trim(),
          kategori: _kategoriTerpilih,
          tanggal: DateTime.now(),
        ),
      );
      _namaController.clear();
    });
    _simpanDataKeStorage();
    _tampilkanNotifikasi(
      'Komponen baru berhasil dideploy!',
      const Color(0xFF10B981),
    );
  }

  // FUNGSI 4: Hapus Data
  void _hapusData(String id) {
    setState(() {
      _daftarData.removeWhere((item) => item.id == id);
    });
    _simpanDataKeStorage();
    _tampilkanNotifikasi('Komponen berhasil dihapus.', Colors.amber);
  }

  void _tampilkanNotifikasi(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pesan,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: warna,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
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
    int totalUtama = _daftarData.where((d) => d.kategori == 'Utama').length;
    int totalTambahan = _daftarData
        .where((d) => d.kategori == 'Tambahan')
        .length;
    int totalSemua = _daftarData.length;
    double rasioUtama = totalSemua == 0 ? 0.0 : totalUtama / totalSemua;

    if (_sedangMemuat) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.terminal, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text(
              'PPSA PINTAR ULTRA',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
        elevation: 4,
        shadowColor: Colors.black26,
        backgroundColor: const Color(0xFF0F172A), // Premium Dark Slate AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GRID UTAMA: STATISTIK & GRAFIK LINGKARAN ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildStatCard(
                        'Komponen Utama',
                        '$totalUtama',
                        Icons.layers,
                        const Color(0xFF2563EB),
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        'Komponen Tambahan',
                        '$totalTambahan',
                        Icons.extension,
                        const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Visual Analytics Chart Card
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 184,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Rasio Struktur',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Perbandingan\nUtama vs Tambahan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: CircularProgressIndicator(
                                value: rasioUtama,
                                strokeWidth: 10,
                                backgroundColor: const Color(0xFF10B981),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            Text(
                              '${(rasioUtama * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- PANEL CONTROL INPUT DATA (GLASSMORPHISM STYLE) ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Modul / Komponen Kerja',
                        labelStyle: const TextStyle(color: Color(0xFF64748B)),
                        prefixIcon: const Icon(
                          Icons.token,
                          color: Color(0xFF2563EB),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF2563EB),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _kategoriTerpilih,
                      decoration: InputDecoration(
                        labelText: 'Klasifikasi',
                        prefixIcon: const Icon(Icons.schema_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                      items: <String>['Utama', 'Tambahan'].map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                      onChanged: (newVal) =>
                          setState(() => _kategoriTerpilih = newVal!),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _tambahDataBaru,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        elevation: 2,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.bolt, color: Colors.amber, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'DEPLOI DATA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // --- DAFTAR LIST VIEW DENGAN FITUR HAPUS ---
            const Text(
              'Database Log Arsitektur',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _daftarData.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'Belum ada modul yang terpasang.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _daftarData.length,
                    itemBuilder: (context, index) {
                      final item = _daftarData[index];
                      final isUtama = item.kategori == 'Utama';

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUtama
                                  ? const Color(0xFFEEF2F6)
                                  : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isUtama ? Icons.layers : Icons.extension,
                              color: isUtama
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF10B981),
                            ),
                          ),
                          title: Text(
                            item.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'ID-${item.id} • Terdaftar Jam ${item.tanggal.hour.toString().padLeft(2, '0')}:${item.tanggal.minute.toString().padLeft(2, '0')} WIB',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(
                                  item.kategori,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                backgroundColor: isUtama
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF10B981),
                                padding: EdgeInsets.zero,
                              ),
                              const SizedBox(width: 16),
                              // TOMBOL HAPUS DATA
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _hapusData(item.id),
                              ),
                            ],
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFFCBD5E1),
          ),
        ],
      ),
    );
  }
}
