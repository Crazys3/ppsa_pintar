import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TUGAS ANDA: Ganti URL dan ANON_KEY di bawah ini dengan milik project Supabase Anda!
  await Supabase.initialize(
    url: 'https://XYZ_PROJECT_ID_ANDA.supabase.co',
    anonKey: 'MASUKKAN_ANON_PUBLIC_KEY_SUPABASE_ANDA_DI_SINI',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PPSA PINTAR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Segoe UI',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFF10B981),
        ),
      ),
      home: const DashboardUtama(),
    );
  }
}

// --- MODEL DATA SANTRI ONLINE ---
class SantriModel {
  final String id;
  final String namaLengkap;
  final String nik;
  final String nis;
  final String tempatLahir;
  final String jenisKelamin;
  final String desa;
  final String kecamatan;
  final String namaAyah;
  final String nomorTelepon;
  final String kelasFormal;
  final String kelasDiniyah;

  SantriModel({
    required this.id,
    required this.namaLengkap,
    required this.nik,
    required this.nis,
    required this.tempatLahir,
    required this.jenisKelamin,
    required this.desa,
    required this.kecamatan,
    required this.namaAyah,
    required this.nomorTelepon,
    required this.kelasFormal,
    required this.kelasDiniyah,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'nik': nik,
      'nis': nis,
      'tempat_lahir': tempatLahir,
      'jenis_kelamin': jenisKelamin,
      'desa': desa,
      'kecamatan': kecamatan,
      'nama_ayah': namaAyah,
      'nomor_telepon': nomorTelepon,
      'kelas_formal': kelasFormal,
      'kelas_diniyah': kelasDiniyah,
    };
  }

  factory SantriModel.fromMap(Map<String, dynamic> map) {
    return SantriModel(
      id: map['id'] ?? '',
      namaLengkap: map['nama_lengkap'] ?? '',
      nik: map['nik'] ?? '',
      nis: map['nis'] ?? '',
      tempatLahir: map['tempat_lahir'] ?? '',
      jenisKelamin: map['jenis_kelamin'] ?? 'Laki-laki',
      desa: map['desa'] ?? '',
      kecamatan: map['kecamatan'] ?? '',
      namaAyah: map['nama_ayah'] ?? '',
      nomorTelepon: map['nomor_telepon'] ?? '',
      kelasFormal: map['kelas_formal'] ?? '',
      kelasDiniyah: map['kelas_diniyah'] ?? '1 Ibtida\'',
    );
  }
}

// --- CONTROLLER KONEKSI SUPABASE ---
class PesantrenController {
  final ValueNotifier<List<SantriModel>> daftarSantriNotifier = ValueNotifier(
    [],
  );
  final ValueNotifier<String> pencarianNotifier = ValueNotifier('');
  final ValueNotifier<String> filterDiniyahNotifier = ValueNotifier('Semua');
  final ValueNotifier<Map<String, String>> logAbsensiNotifier = ValueNotifier(
    {},
  );

  PesantrenController() {
    muatSemuaData();
  }

  // Mengambil data Santri & Absen sekaligus dari Cloud Supabase
  Future<void> muatSemuaData() async {
    try {
      final resSantri = await supabase
          .from('santri')
          .select()
          .order('nama_lengkap', ascending: true);
      daftarSantriNotifier.value = (resSantri as List)
          .map((e) => SantriModel.fromMap(e))
          .toList();

      final resAbsen = await supabase.from('absensi').select();
      final Map<String, String> mapAbsen = {};
      for (var row in (resAbsen as List)) {
        final key =
            "${row['jenis_absen']}_${row['tanggal']}_${row['santri_id']}";
        mapAbsen[key] = row['status'];
      }
      logAbsensiNotifier.value = mapAbsen;
    } catch (e) {
      debugPrint("Gagal memuat data dari Supabase: $e");
    }
  }

  Future<void> tambahSantri(SantriModel santri) async {
    await supabase.from('santri').insert(santri.toMap());
    await muatSemuaData();
  }

  Future<void> editSantri(SantriModel santri) async {
    await supabase.from('santri').update(santri.toMap()).eq('id', santri.id);
    await muatSemuaData();
  }

  Future<void> hapusSantri(String id) async {
    await supabase.from('santri').delete().eq('id', id);
    await muatSemuaData();
  }

  Future<void> simpanAbsen(
    String jenis,
    String tanggal,
    String santriId,
    String status,
  ) async {
    try {
      // Upsert: Menyimpan data baru atau mengupdate jika data hari itu sudah ada
      await supabase.from('absensi').upsert({
        'jenis_absen': jenis,
        'tanggal': tanggal,
        'santri_id': santriId,
        'status': status,
      }, onConflict: 'jenis_absen,tanggal,santri_id');

      final mapBaru = Map<String, String>.from(logAbsensiNotifier.value);
      final key = "${jenis}_${tanggal}_$santriId";
      mapBaru[key] = status;
      logAbsensiNotifier.value = mapBaru;
    } catch (e) {
      debugPrint("Gagal simpan absen: $e");
    }
  }

  String ambilStatusAbsen(String jenis, String tanggal, String santriId) {
    final key = "${jenis}_${tanggal}_$santriId";
    return logAbsensiNotifier.value[key] ?? '-';
  }
}

// --- HUB DASHBOARD UTAMA ---
class DashboardUtama extends StatefulWidget {
  const DashboardUtama({super.key});

  @override
  State<DashboardUtama> createState() => _DashboardUtamaState();
}

class _DashboardUtamaState extends State<DashboardUtama> {
  final PesantrenController _controller = PesantrenController();
  final TextEditingController _searchController = TextEditingController();

  int _tabAktif = 0;
  String _subTabAbsenHarian = 'Formal';

  DateTime _tanggalTerpilih = DateTime.now();
  final List<String> _opsiDiniyah = [
    'Semua',
    '1 Ibtida\'',
    '2 Ibtida\'',
    '3 Ibtida\'',
    '4 Ibtida\'',
    '5 Ibtida\'',
    '6 Ibtida\'',
  ];
  final List<String> _opsiFormal = [
    '7 SMP',
    '8 SMP',
    '9 SMP',
    '10 SMA',
    '11 SMA',
    '12 SMA',
  ];

  String _formatTanggal(DateTime dt) => "${dt.day}-${dt.month}-${dt.year}";

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.mosque, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'PPSA PINTAR (ONLINE)',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller.muatSemuaData(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildNavButton(0, Icons.folder_shared, 'Master Santri'),
              _buildNavButton(1, Icons.view_headline, 'Absensi Harian'),
              _buildNavButton(2, Icons.time_to_leave, 'Absen Pulang'),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _controller.muatSemuaData(),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _controller.daftarSantriNotifier,
            _controller.pencarianNotifier,
            _controller.filterDiniyahNotifier,
            _controller.logAbsensiNotifier,
          ]),
          builder: (context, _) {
            final semuaSantri = _controller.daftarSantriNotifier.value;

            if (_tabAktif == 0) {
              return _buildHalamanMaster(semuaSantri, isDesktop);
            } else if (_tabAktif == 1) {
              return _buildHalamanAbsenHarian(semuaSantri);
            } else {
              return _buildHalamanAbsenPulang(semuaSantri);
            }
          },
        ),
      ),
    );
  }

  Widget _buildNavButton(int index, IconData icon, String label) {
    bool aktif = _tabAktif == index;
    return InkWell(
      onTap: () => setState(() => _tabAktif = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: aktif ? const Color(0xFF10B981) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: aktif ? Colors.white : Colors.white60, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: aktif ? Colors.white : Colors.white60,
                fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHalamanMaster(List<SantriModel> semuaSantri, bool isDesktop) {
    final kataKunci = _controller.pencarianNotifier.value.toLowerCase();
    final filterDiniyah = _controller.filterDiniyahNotifier.value;

    final dataTersaring = semuaSantri.where((s) {
      final cocokNama =
          s.namaLengkap.toLowerCase().contains(kataKunci) ||
          s.nis.contains(kataKunci);
      final cocokFilter =
          filterDiniyah == 'Semua' || s.kelasDiniyah == filterDiniyah;
      return cocokNama && cocokFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Database Validasi Santri (Cloud)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _tampilkanFormInput(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Tambah Santri Baru'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama / NIS...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (v) => _controller.pencarianNotifier.value = v,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: filterDiniyah,
                  decoration: InputDecoration(
                    labelText: 'Filter Diniyah',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _opsiDiniyah
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(
                    () => _controller.filterDiniyahNotifier.value = v!,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('NIS')),
                  DataColumn(label: Text('Nama Lengkap')),
                  DataColumn(label: Text('Madrasah Diniyah')),
                  DataColumn(label: Text('Sekolah Formal')),
                  DataColumn(label: Text('Alamat Rumah')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: dataTersaring.map((santri) {
                  return DataRow(
                    cells: [
                      DataCell(Text(santri.nis)),
                      DataCell(
                        Text(
                          santri.namaLengkap,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(Text(santri.kelasDiniyah)),
                      DataCell(Text(santri.kelasFormal)),
                      DataCell(
                        Text('Ds. ${santri.desa}, Kec. ${santri.kecamatan}'),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              onPressed: () => _tampilkanFormInput(
                                context,
                                santriEksisting: santri,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _controller.hapusSantri(santri.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHalamanAbsenHarian(List<SantriModel> semuaSantri) {
    String tglStr = _formatTanggal(_tanggalTerpilih);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lembar Absen Harian - Kategori: $_subTabAbsenHarian',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: Text('Tanggal: $tglStr'),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _tanggalTerpilih,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _tanggalTerpilih = picked);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: ['Formal', 'Diniyah', 'Syawir'].map((sub) {
              bool aktif = _subTabAbsenHarian == sub;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(sub),
                  selected: aktif,
                  onSelected: (_) => setState(() => _subTabAbsenHarian = sub),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: semuaSantri.length,
                itemBuilder: (context, i) {
                  final s = semuaSantri[i];
                  String statusSekarang = _controller.ambilStatusAbsen(
                    _subTabAbsenHarian,
                    tglStr,
                    s.id,
                  );

                  return ListTile(
                    title: Text(
                      s.namaLengkap,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'NIS: ${s.nis} | Diniyah: ${s.kelasDiniyah} | Formal: ${s.kelasFormal}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: ['Hadir', 'Sakit', 'Izin', 'Alpa'].map((st) {
                        bool cocok = statusSekarang == st;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cocok
                                  ? const Color(0xFF2563EB)
                                  : Colors.grey,
                              foregroundColor: cocok
                                  ? Colors.white
                                  : Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            onPressed: () => _controller.simpanAbsen(
                              _subTabAbsenHarian,
                              tglStr,
                              s.id,
                              st,
                            ),
                            child: Text(st),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHalamanAbsenPulang(List<SantriModel> semuaSantri) {
    String tglStr = _formatTanggal(_tanggalTerpilih);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Log Kepulangan Santri (Izin Keluar Pondok)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Tanggal Log: $tglStr',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: semuaSantri.length,
                itemBuilder: (context, i) {
                  final s = semuaSantri[i];
                  String statusPulang = _controller.ambilStatusAbsen(
                    'Pulang',
                    tglStr,
                    s.id,
                  );
                  bool sudahPulang = statusPulang == 'Pulang';

                  return ListTile(
                    title: Text(
                      s.namaLengkap,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Wali: ${s.namaAyah} | Telp: ${s.nomorTelepon}',
                    ),
                    trailing: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sudahPulang
                            ? Colors.deepOrange
                            : const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(sudahPulang ? Icons.home : Icons.logout),
                      label: Text(
                        sudahPulang ? 'Sedang Pulang' : 'Izinkan Pulang',
                      ),
                      onPressed: () {
                        String stBaru = sudahPulang ? '-' : 'Pulang';
                        _controller.simpanAbsen('Pulang', tglStr, s.id, stBaru);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _tampilkanFormInput(
    BuildContext context, {
    SantriModel? santriEksisting,
  }) {
    final formKey = GlobalKey<FormState>();
    final isEdit = santriEksisting != null;

    String nama = santriEksisting?.namaLengkap ?? '';
    String nik = santriEksisting?.nik ?? '';
    String nis = santriEksisting?.nis ?? '';
    String tempatLahir = santriEksisting?.tempatLahir ?? '';
    String jk = santriEksisting?.jenisKelamin ?? 'Laki-laki';
    String desa = santriEksisting?.desa ?? '';
    String kec = santriEksisting?.kecamatan ?? '';
    String ayah = santriEksisting?.namaAyah ?? '';
    String telp = santriEksisting?.nomorTelepon ?? '';
    String formal = santriEksisting?.kelasFormal ?? '10 SMA';
    String diniyah = santriEksisting?.kelasDiniyah ?? '1 Ibtida\'';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Profil Santri' : 'Registrasi Santri Baru'),
          content: SizedBox(
            width: 700,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: nama,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                      ),
                      onChanged: (v) => nama = v,
                      validator: (v) => v!.isEmpty ? 'Wajib' : null,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: nis,
                            decoration: const InputDecoration(labelText: 'NIS'),
                            onChanged: (v) => nis = v,
                            validator: (v) => v!.isEmpty ? 'Wajib' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: nik,
                            decoration: const InputDecoration(labelText: 'NIK'),
                            onChanged: (v) => nik = v,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: diniyah,
                            decoration: const InputDecoration(
                              labelText: 'Madrasah Diniyah',
                            ),
                            items: _opsiDiniyah
                                .where((e) => e != 'Semua')
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => diniyah = v!,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: formal,
                            decoration: const InputDecoration(
                              labelText: 'Sekolah Formal',
                            ),
                            items: _opsiFormal
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => formal = v!,
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      initialValue: desa,
                      decoration: const InputDecoration(
                        labelText: 'Desa/Kelurahan',
                      ),
                      onChanged: (v) => desa = v,
                    ),
                    TextFormField(
                      initialValue: kec,
                      decoration: const InputDecoration(labelText: 'Kecamatan'),
                      onChanged: (v) => kec = v,
                    ),
                    TextFormField(
                      initialValue: ayah,
                      decoration: const InputDecoration(
                        labelText: 'Nama Ayah Kandung',
                      ),
                      onChanged: (v) => ayah = v,
                    ),
                    TextFormField(
                      initialValue: telp,
                      decoration: const InputDecoration(
                        labelText: 'No HP Aktif Wali',
                      ),
                      onChanged: (v) => telp = v,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final data = SantriModel(
                    id: isEdit
                        ? santriEksisting.id
                        : DateTime.now().millisecondsSinceEpoch.toString(),
                    namaLengkap: nama,
                    nik: nik,
                    nis: nis,
                    tempatLahir: tempatLahir,
                    jenisKelamin: jk,
                    desa: desa,
                    kecamatan: kec,
                    namaAyah: ayah,
                    nomorTelepon: telp,
                    kelasFormal: formal,
                    kelasDiniyah: diniyah,
                  );
                  if (isEdit)
                    await _controller.editSantri(data);
                  else
                    await _controller.tambahSantri(data);
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
