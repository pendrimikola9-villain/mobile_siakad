import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController(); // Controller NIM
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // PERBAIKAN: Mengirim data lengkap termasuk NIM ke backend
      final success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _confirmController.text,
        // Jika di AuthProvider nanti kamu butuh parameter nim terpisah, kamu bisa menambahkannya di sana.
        // Untuk saat ini, kita pastikan parameter standard-nya berjalan lancar.
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (mounted && authProvider.errorMessage != null) {
        if (authProvider.validationErrors == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.errorMessage!)),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    // Membersihkan semua controller dari memori HP saat halaman ditutup
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serverErrors = authProvider.validationErrors;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi Portal')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: const OutlineInputBorder(),
                  errorText: serverErrors?['name'] != null ? serverErrors!['name'][0] : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama lengkap tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Field NIM sesuai form HTML SIAKAD
              TextFormField(
                controller: _nimController,
                decoration: InputDecoration(
                  labelText: 'Nomor Induk Mahasiswa (NIM)',
                  border: const OutlineInputBorder(),
                  errorText: serverErrors?['username'] != null ? serverErrors!['username'][0] : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'NIM tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Kampus / Aktif',
                  border: const OutlineInputBorder(),
                  errorText: serverErrors?['email'] != null ? serverErrors!['email'][0] : null,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Sandi Baru',
                  border: const OutlineInputBorder(),
                  errorText: serverErrors?['password'] != null ? serverErrors!['password'][0] : null,
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sandi baru tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Sandi Baru',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi sandi tidak boleh kosong';
                  }
                  if (value != _passwordController.text) {
                    return 'Kata sandi konfirmasi tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              authProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        child: const Text('AKTIVASI AKUN'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}