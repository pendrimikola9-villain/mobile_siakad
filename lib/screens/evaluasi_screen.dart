import 'package:flutter/material.dart';
import '../services/evaluasi_service.dart';

class EvaluasiScreen extends StatefulWidget {
  const EvaluasiScreen({super.key});

  @override
  State<EvaluasiScreen> createState() => _EvaluasiScreenState();
}

class _EvaluasiScreenState extends State<EvaluasiScreen> {
  final EvaluasiService _evaluasiService = EvaluasiService();
  late Future<Map<String, dynamic>> _futureEvaluasi;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureEvaluasi = _evaluasiService.getEvaluasiData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Evaluasi Beban SKS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureEvaluasi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Fallback Data Dummy jika API belum disambungkan / snapshot error
          final data = snapshot.data ?? {};

          // 🟢 Konversi angka fleksibel (mencegah error casting int vs double dari JSON)
         int parseToInt(dynamic value, int defaultValue) {
  if (value == null) return defaultValue;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? defaultValue;
  return defaultValue;
}

final int jatahSks = parseToInt(data['jatahSksMaksimal'], 24);
final int persenHadir = parseToInt(data['persenHadir'], 100);
final int nilaiTugas = parseToInt(data['nilaiTugas'], 90);
final int keaktifan = parseToInt(data['keaktifan'], 85);

          final String kategori = data['kategori']?.toString() ?? 'Sangat Baik';
          final List<dynamic> riwayat =
              data['riwayatFuzzy'] as List<dynamic>? ??
              [
                {
                  'name': 'Pendri Mikola',
                  'kehadiran_input': 100,
                  'tugas_input': 90,
                  'keaktifan_input': 85,
                  'hasil_sks_crisp': 24,
                  'kategori_rekomendasi': 'Sangat Baik',
                  'updated_at': '2026-07-30',
                },
              ];

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. BANNER UTAMA HASIL REKOMENDASI
                _buildMainBanner(jatahSks),

                const SizedBox(height: 16),

                // 2. CARD INDIKATOR PERFORMA (3 Kolom Aman Overflow & Icon Valid)
                Row(
                  children: [
                    Expanded(
                      child: _buildIndicatorCard(
                        'Presensi',
                        '$persenHadir%',
                        'Rajin',
                        Colors.cyan.shade700,
                        Icons.calendar_month,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildIndicatorCard(
                        'Rata Nilai',
                        '$nilaiTugas',
                        'Tinggi',
                        Colors.green,
                        Icons.assignment_turned_in,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildIndicatorCard(
                        'Keaktifan',
                        '$keaktifan Pn',
                        'Aktif',
                        Colors.orange,
                        Icons.chat_bubble_outline,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 3. HASIL REKOMENDASI SKS (CARD DARK)
                _buildResultSummaryCard(kategori, jatahSks),

                const SizedBox(height: 20),

                // 4. MATRIKS ATURAN EVALUASI (RULE BASE)
                _buildRuleBaseSection(),

                const SizedBox(height: 20),

                // 5. RIWAYAT LOG PERSISTENSI DATABASE (fuzzy_results)
                _buildHistorySection(riwayat),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🟢 WIDGET BANNER GRADIENT
  Widget _buildMainBanner(int jatahSks) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Rekomendasi SKS (Fuzzy)',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Modul Evaluasi Beban Belajar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Perhitungan Otomatis Batas Kuota SKS Semester Depan',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$jatahSks SKS',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🟢 WIDGET CARD INDIKATOR (DILENGKAPI FITTEDBOX AGAR TIDAK OVERFLOW)
  Widget _buildIndicatorCard(
    String title,
    String value,
    String status,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🟢 WIDGET CARD DARK HASIL REKOMENDASI
  Widget _buildResultSummaryCard(String kategori, int jatahSks) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF212529),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HASIL REKOMENDASI SKS',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Kategori Status: $kategori',
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kuota SKS Dapat Diambil: $jatahSks SKS',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white24, height: 20),
          const Text(
            'Perhitungan ini dilakukan secara otomatis oleh sistem Fuzzy Logic berdasarkan pencapaian tugas, keaktifan, dan kehadiran kamu.',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // 🟢 WIDGET MATRIKS ATURAN (RULE BASE)
  Widget _buildRuleBaseSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aturan Evaluasi (Rule Base)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          _ruleTile('R1', 'Rajin & Tinggi & Aktif', '24 SKS', Colors.green),
          _ruleTile('R2', 'Rajin & Sedang & Cukup', '21 SKS', Colors.blue),
          _ruleTile('R3', 'Standar & Tinggi & Aktif', '21 SKS', Colors.blue),
          _ruleTile('R4', 'Jarang & Rendah & Pasif', '12 SKS', Colors.red),
        ],
      ),
    );
  }

  Widget _ruleTile(String code, String condition, String result, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(condition, style: const TextStyle(fontSize: 11)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              result,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🟢 WIDGET RIWAYAT TABEL (fuzzy_results)
  Widget _buildHistorySection(List<dynamic> riwayat) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Log Perhitungan (fuzzy_results)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: riwayat.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final item = riwayat[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  item['name']?.toString() ?? 'Mahasiswa',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Hadir: ${item['kehadiran_input']}% | Tugas: ${item['tugas_input']} | Aktif: ${item['keaktifan_input']}',
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item['hasil_sks_crisp']} SKS',
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
