import 'dart:convert';
import 'package:flutter/material.dart';

// Import Service untuk membaca Session Login
import '../services/auth_service.dart';

// Import Screen Tujuan Navigasi
import 'jadwal_screen.dart';
import 'krs_screen.dart';
import 'evaluasi_screen.dart';
import 'profile_screen.dart';
import 'attendance_screen.dart'; // 👈 TAMBAHKAN IMPORT INI!
import 'bimbingan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 🟢 Membaca data user dari SharedPreferences/AuthService
  Future<void> _loadUserData() async {
    final jsonString = await _authService.getUserData();
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        setState(() {
          _userData = jsonDecode(jsonString);
          _isLoading = false;
        });
      } catch (_) {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  // 🟢 METHOD BUILD UTAMA
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'SIAKAD Mobile UMB',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Banner Profil Mahasiswa
                  _buildWelcomeCard(_userData),

                  const SizedBox(height: 16),

                  // 2. Ringkasan IPK & Dosen Wali
                  _buildAcademicSummaryCard(),

                  const SizedBox(height: 20),

                  // 3. Grid Menu Utama (Dengan Navigasi Aktif)
                  const Text(
                    'Fitur Akademik Utama',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuGrid(context),

                  const SizedBox(height: 20),

                  // 4. Ringkasan Jadwal Kuliah (SIPLAR)
                  _buildRecentSchedulesSection(),

                  const SizedBox(height: 16),

                  // 5. Ringkasan Log Bimbingan (SIBIMBING)
                  _buildRecentBimbinganSection(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // 🟢 WIDGET BANNER PROFIL
  Widget _buildWelcomeCard(Map<String, dynamic>? user) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selamat Datang,',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (user?['role'] ?? 'Mahasiswa').toString().toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 6),
          Text(
            user?['name']?.toString() ?? 'pendri',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'NIM: ${user?['nim']?.toString() ?? user?['email']?.toString() ?? '2455201110020'}',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // 🟢 WIDGET IPK & DOSEN WALI
  Widget _buildAcademicSummaryCard() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.cyan.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('IPK SEMENTARA', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('3.65', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: Colors.cyan.shade700, width: 4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DOSEN WALI (PA)', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('M. Musthofa, M.Cs.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                SizedBox(height: 2),
                Text('SIBIMBING Active', style: TextStyle(color: Colors.green, fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🟢 WIDGET GRID MENU (SUDAH DIPERBAIKI DENGAN HAK NAVIGASI PRESENSI)
  Widget _buildMenuGrid(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Pengisian KRS',
        'icon': Icons.assignment,
        'color': Colors.blue,
        'screen': const KrsScreen(),
      },
      {
        'title': 'Jadwal Kuliah',
        'icon': Icons.calendar_month,
        'color': Colors.orange,
        'screen': const JadwalScreen(),
      },
      {
        'title': 'Presensi',
        'icon': Icons.fact_check,
        'color': Colors.teal,
        'screen': const AttendanceScreen(), // 🟢 UBAH DARI NULL KEMARI!
      },
      {
        'title': 'Evaluasi / Nilai',
        'icon': Icons.bar_chart,
        'color': Colors.purple,
        'screen': const EvaluasiScreen(),
      },
 // 🟢 UBAH MENJADI:
{
  'title': 'Log Bimbingan',
  'icon': Icons.chat,
  'color': Colors.green,
  'screen': LogbookBimbinganScreen(), // 👈 Pakai nama LogbookBimbinganScreen
},
      {
        'title': 'Profil Mahasiswa',
        'icon': Icons.person,
        'color': Colors.indigo,
        'screen': const ProfileScreen(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: menuItems.length,
      // 🎯 DI SINI LETAK ITEMBUILDER-NYA:
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              print('=== BUTTON TAP DETECTED: ${item['title']} ===');
              if (item['screen'] != null) {
                // 🚀 Memaksa Navigasi Pindah Halaman
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => item['screen'] as Widget),
                );
              } else {
                // Menampilkan Modal Bottom Sheet jika screen null
                _showModalInfo(
                  context, 
                  item['title'].toString(), 
                  'Fitur ${item['title']} terintegrasi dengan backend SIAKAD UMB.'
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['title'].toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🟢 WIDGET RINGKASAN JADWAL
  Widget _buildRecentSchedulesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text('Jadwal Kuliah Terbaru (SIPLAR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          const Divider(height: 1),
          _scheduleTile('Pemrograman Web 2 (Praktikum)', 'Lab Komputer 3', 'Senin, 08:00'),
          _scheduleTile('Pemrograman Bergerak (Mobile)', 'Lab Komputer 1', 'Selasa, 10:30'),
        ],
      ),
    );
  }

  Widget _scheduleTile(String title, String room, String time) {
    return ListTile(
      dense: true,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      subtitle: Text(time, style: const TextStyle(fontSize: 11)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
        child: Text(room, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // 🟢 WIDGET RINGKASAN LOG BIMBINGAN
  Widget _buildRecentBimbinganSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Text('Log Bimbingan Terbaru (SIBIMBING)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          const Divider(height: 1),
          _bimbinganTile('Revisi Proposal Bab 1-3', 'ACC', Colors.green),
          _bimbinganTile('Pengajuan Judul Skripsi', 'Proses', Colors.orange),
        ],
      ),
    );
  }

  Widget _bimbinganTile(String topic, String status, Color statusColor) {
    return ListTile(
      dense: true,
      title: Text(topic, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
        child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // 🟢 MODAL BOTTOM SHEET
  void _showModalInfo(BuildContext context, String title, String desc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            )
          ],
        ),
      ),
    );
  }
}