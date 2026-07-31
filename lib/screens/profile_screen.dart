import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _nama = 'Mahasiswa';
  String _nim = '-';
  String _email = '-';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final userData = await AuthService().getUserData();
    if (userData != null) {
      final user = jsonDecode(userData);
      setState(() {
        _nama = user['nama'] ?? user['name'] ?? 'Mahasiswa';
        _nim = user['nim'] ?? '-';
        _email = user['email'] ?? '-';
      });
    }
  }

  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(_nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('NIM: $_nim', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Email'),
              subtitle: Text(_email),
            ),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.blue),
              title: const Text('Program Studi'),
              subtitle: const Text('S1 Informatika'),
            ),
            ListTile(
              leading: const Icon(Icons.location_city, color: Colors.blue),
              title: const Text('Perguruan Tinggi'),
              subtitle: const Text('Universitas Muhammadiyah Banjarmasin'),
            ),
            const Divider(),
            const SizedBox(height: 20),

            // Tombol Logout
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text('KELUAR PORTAL', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}