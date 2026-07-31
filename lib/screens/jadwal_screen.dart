import 'package:flutter/material.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  // Dummy Data Jadwal (Sesuai dengan struktur tabel Blade Laravel kamu)
  final List<Map<String, dynamic>> _schedules = [
    {
      'id': 1,
      'hari': 'Senin',
      'jam_mulai': '08:00',
      'jam_selesai': '10:30',
      'kelas': '4A TI',
      'nama_mk': 'Pemrograman Web 2 (Praktikum)',
      'kode_mk': 'TIF-401',
      'sks': 3,
      'nama_dosen': 'M. Musthofa, M.Cs.',
      'nama_ruangan': 'Lab Komputer 3',
      'status_dosen': 'Berhadir',
      'keterangan_status': 'Kuliah tatap muka berlangsung tepat waktu.',
    },
    {
      'id': 2,
      'hari': 'Selasa',
      'jam_mulai': '10:30',
      'jam_selesai': '13:00',
      'kelas': '4A TI',
      'nama_mk': 'Pemrograman Bergerak (Mobile)',
      'kode_mk': 'TIF-405',
      'sks': 3,
      'nama_dosen': 'Hafizah, M.Kom.',
      'nama_ruangan': 'Lab Komputer 1',
      'status_dosen': 'Kelas Online',
      'keterangan_status': 'Silakan masuk ke Google Meet / Zoom link di e-learning.',
    },
    {
      'id': 3,
      'hari': 'Rabu',
      'jam_mulai': '13:30',
      'jam_selesai': '15:10',
      'kelas': '4A TI',
      'nama_mk': 'Kecerdasan Buatan (AI)',
      'kode_mk': 'TIF-408',
      'sks': 2,
      'nama_dosen': 'Ahmad, M.T.',
      'nama_ruangan': 'Ruang 204 Kampus Utama',
      'status_dosen': 'Berhalangan (Sakit)',
      'keterangan_status': 'Kuliah ditiadakan, silakan pelajari materi Bab 4.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Jadwal Kuliah (SIPLAR)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟢 1. BANNER HEADER JADWAL (Sama seperti Card Primary Laravel Web)
            _buildHeaderBanner(),

            const SizedBox(height: 16),

            // 🟢 2. DAFTAR JADWAL KULIAH
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Kelas & Ruangan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${_schedules.length} Kelas',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _schedules.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      return _buildScheduleCard(_schedules[index]);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Jadwal Perkuliahan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Plot kelas, waktu, dan lokasi ruangan.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.blue.shade800),
                const SizedBox(width: 4),
                Text(
                  'WITA',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> item) {
    final String status = item['status_dosen'] ?? 'Berhadir';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris 1: Hari, Jam, & Kelas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade800,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['hari'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${item['jam_mulai']} - ${item['jam_selesai']} WITA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Baris 2: Nama Mata Kuliah
            Text(
              item['nama_mk'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),

            // Kode MK & SKS
            Text(
              'Kode: ${item['kode_mk']}  •  ${item['sks']} SKS  •  Kelas ${item['kelas']}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),

            const Divider(height: 18),

            // Baris 3: Dosen & Ruangan
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item['nama_dosen'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.meeting_room_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  item['nama_ruangan'],
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Baris 4: Badge Status Dosen (Sama persis logika warna dengan Laravel Blade)
            _buildStatusBadge(status),

            // Catatan Instruksi jika ada
            if (item['keterangan_status'] != null &&
                item['keterangan_status'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'Catatan: ${item['keterangan_status']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade800,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    Color textColor;
    IconData icon;

    if (status.contains('Berhadir')) {
      badgeColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
      icon = Icons.check_circle_outline;
    } else if (status.contains('Online')) {
      badgeColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.laptop;
    } else {
      badgeColor = Colors.red.shade50;
      textColor = Colors.red.shade800;
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.calendar_today, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'Belum ada data jadwal kuliah reguler.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}