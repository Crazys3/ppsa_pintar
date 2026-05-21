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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HalamanUtama(),
    );
  }
}

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  // Penyimpanan data lokal untuk simulasi tambah data
  final List<String> _daftarData = ['Data Awal 1', 'Data Awal 2'];
  final TextEditingController _controller = TextEditingController();

  void _tambahData() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _daftarData.add(_controller.text); // Memasukkan data baru ke list
        _controller.clear(); // Mengosongkan form input
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PPSA Pintar - Beranda'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Masukkan Data Baru',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _tambahData,
                  child: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _daftarData.isEmpty
                  ? const Center(child: Text('Data masih kosong.'))
                  : ListView.builder(
                      itemCount: _daftarData.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(title: Text(_daftarData[index])),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
