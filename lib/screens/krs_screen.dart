import 'package:flutter/material.dart';
import '../models/krs_model.dart';
import '../services/krs_service.dart';

class KrsScreen extends StatefulWidget {
  const KrsScreen({super.key});

  @override
  State<KrsScreen> createState() => _KrsScreenState();
}

class _KrsScreenState extends State<KrsScreen> {
  final KrsService _krsService = KrsService();
  late Future<List<MatakuliahModel>> _futureMatkul;
  List<MatakuliahModel> _matkulList = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureMatkul = _krsService.getMatakuliah().then((list) {
        _matkulList = list;
        return list;
      });
    });
  }

  int get _totalSks {
    return _matkulList
        .where((m) => m.isSelected)
        .fold(0, (sum, item) => sum + item.sks);
  }

  void _submitKrs() async {
    final selectedIds = _matkulList
        .where((m) => m.isSelected)
        .map((m) => m.id)
        .toList();

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu mata kuliah!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_totalSks > 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batas maksimal pengisian adalah 24 SKS!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _krsService.submitKrs(selectedIds);

      if (mounted) {
        setState(() => _isSubmitting = false);
        
        // Ambil pesan dari response API (fallback jika key 'message' tidak ada)
        final msg = result['message'] ?? result['msg'] ?? 'Pengajuan KRS Berhasil!';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg.toString()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengajukan KRS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengisian KRS'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<MatakuliahModel>>(
        future: _futureMatkul,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Memuat daftar mata kuliah...'),
                ],
              ),
            );
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat mata kuliah:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    )
                  ],
                ),
              ),
            );
          }

          // 3. Empty Data State
          if (_matkulList.isEmpty) {
            return const Center(
              child: Text('Belum ada data mata kuliah yang tersedia.'),
            );
          }

          // 4. Main UI Display
          return Column(
            children: [
              // Banner Info SKS
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total SKS Dipilih:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '$_totalSks / 24 SKS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _totalSks > 24 ? Colors.red : Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),

              // Daftar Mata Kuliah
              Expanded(
                child: ListView.separated(
                  itemCount: _matkulList.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final matkul = _matkulList[index];
                    return CheckboxListTile(
                      activeColor: Colors.blue.shade800,
                      title: Text(
                        matkul.nama,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text('${matkul.kode} • ${matkul.sks} SKS'),
                      value: matkul.isSelected,
                      onChanged: (bool? val) {
                        setState(() {
                          matkul.isSelected = val ?? false;
                        });
                      },
                    );
                  },
                ),
              ),

              // Tombol Submit
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    )
                  ],
                ),
                child: _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _submitKrs,
                        child: const Text(
                          'SIMPAN & AJUKAN KRS',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}