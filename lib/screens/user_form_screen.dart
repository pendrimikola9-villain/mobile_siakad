import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserFormScreen extends StatefulWidget {
  final UserModel? user; // Jika null = Mode Tambah, Jika ada isi = Mode Edit

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>(); // Key validasi form client-side
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _serverErrors; // Menampung error validasi dari Laravel

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    // Mengisi data awal jika masuk dalam mode Edit
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
  }

  void _handleSubmit() async {
    // 1. Cek validasi dasar di Flutter dulu
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _serverErrors = null;
      });

      Map<String, dynamic> result;

      if (isEdit) {
        // Eksekusi Update
        result = await _userService.updateUser(
          id: widget.user!.id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        );
      } else {
        // Eksekusi Create
        result = await _userService.createUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (result['success'] && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? 'User berhasil diperbarui' : 'User berhasil ditambah')),
        );
        Navigator.pop(context); // Kembali ke halaman list user
      } else if (mounted) {
        setState(() {
          // 2. Tangkap error spesifik per field dari Laravel jika ada (Tugas Poin 2)
          _serverErrors = result['errors'];
        });
        
        // Tampilkan pesan error umum jika pesan per field tidak ada
        if (_serverErrors == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Terjadi kesalahan')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit User' : 'Tambah User')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Field Nama
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: const OutlineInputBorder(),
                  errorText: _serverErrors?['name'] != null ? _serverErrors!['name'][0] : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Field Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  errorText: _serverErrors?['email'] != null ? _serverErrors!['email'][0] : null,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              
              // Field Password hanya muncul saat mode Tambah User
              if (!isEdit) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    errorText: _serverErrors?['password'] != null ? _serverErrors!['password'][0] : null,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah User'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}