import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';
import 'form_bimbingan_screen.dart';

class LogbookBimbinganScreen extends StatefulWidget {
  const LogbookBimbinganScreen({super.key});

  @override
  State<LogbookBimbinganScreen> createState() => _LogbookBimbinganScreenState();
}

class _LogbookBimbinganScreenState extends State<LogbookBimbinganScreen> {
  final AuthService _authService = AuthService();
  List<dynamic> _logs = [];
  bool _isLoading = true;

  // 1️⃣ DIPANGGIL SAAT LAYAR PERTAMA KALI DIBUKA
  @override
  void initState() {
    super.initState();
    _fetchLogs(); // 👈 Memanggil API otomatis begitu layar terbuka
  }

 // 🟢 Ambil Data Riwayat Logbook dari API Laravel
Future<void> _fetchLogs() async {
  if (!mounted) return;
  setState(() => _isLoading = true);

  try {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/consultation-logs');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // 🔍 PRINTS PENTING UNTUK CEK DI DEBUG CONSOLE:
    print("📩 STATUS RESPONSE LOGBOOK: ${response.statusCode}");
    print("📩 ISI BODY LOGBOOK: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      setState(() {
        // Cek struktur response dari Laravel
        if (body is Map<String, dynamic> && body.containsKey('data')) {
          _logs = body['data'] as List<dynamic>? ?? [];
        } else if (body is List) {
          _logs = body;
        } else {
          _logs = [];
        }
      });
    } else {
      print("❌ GAGAL FETCH LOGBOOK: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    debugPrint('Error fetch logbook: $e');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  // 3️⃣ TAMPILAN WIDGET
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('SIBIMBING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // 🟢 TOMBOL AJUKAN KONSULTASI DENGAN AWAIT REFRESH
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormBimbinganScreen()),
          );

          if (result == true) {
            _fetchLogs(); // 🔄 Otomatis Refresh setelah Submit
          }
        },
        backgroundColor: Colors.blue.shade800,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajukan Konsultasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLogs,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('SIBIMBING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Manajemen logbook bimbingan, verifikasi draf akademik, serta persetujuan janji temu.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Daftar Logbook & Request Janji Temu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Daftar Logbook / Loading / Empty
              _isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  : _logs.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final item = _logs[index];
                            return _buildLogCard(item);
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  // Card Item Logbook
  Widget _buildLogCard(Map<String, dynamic> item) {
    final String status = item['status_bimbingan'] ?? 'Menunggu Validasi';
    final String requestPertemuan = item['request_pertemuan'] ?? 'Tidak';
    final String? alasanPenolakan = item['alasan_penolakan'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['jenis_konsultasi'] ?? 'Skripsi / TA',
                    style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                Text(
                  item['tanggal_bimbingan'] ?? '',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              item['topik_bimbingan'] ?? '-',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 10),

            if (requestPertemuan == 'Ya')
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Butuh Pertemuan Hari Ini',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
              ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status Validasi:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                _buildStatusBadge(status),
              ],
            ),

            if (status == 'Ditolak' && alasanPenolakan != null && alasanPenolakan.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Alasan Ditolak: $alasanPenolakan',
                  style: TextStyle(color: Colors.red.shade900, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Badge Status
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label = status;

    if (status == 'ACC') {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
      icon = Icons.check_circle;
      label = 'Disetujui (ACC)';
    } else if (status == 'Ditolak') {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
      icon = Icons.cancel;
    } else {
      bgColor = Colors.amber.shade100;
      textColor = Colors.amber.shade900;
      icon = Icons.hourglass_top_rounded;
      label = 'Menunggu Validasi';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // Tampilan Kosong
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('Belum ada riwayat pendaftaran bimbingan.', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}