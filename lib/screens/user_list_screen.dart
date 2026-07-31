import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserService _userService = UserService();
  late Future<List<UserModel>> _futureUsers;
  bool _isDeleting = false; // State untuk mendeteksi proses delete (Tugas Poin 5)

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Fungsi untuk memicu pengambilan data dari API
  Future<void> _loadUsers() async {
    setState(() {
      _futureUsers = _userService.getUsers();
    });
  }

  // Fungsi hapus user dengan indikator loading
  void _deleteUser(int id) async {
    setState(() {
      _isDeleting = true; // 1. Mulai loading delete
    });

    final success = await _userService.deleteUser(id);

    setState(() {
      _isDeleting = false; // 2. Matikan loading delete
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User berhasil dihapus')),
      );
      _loadUsers(); // Refresh data setelah berhasil dihapus
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Daftar User')),
          // 3. Mengimplementasikan Pull to Refresh (Tugas Poin 3)
          body: RefreshIndicator(
            onRefresh: _loadUsers, // Panggil fungsi load data saat ditarik ke bawah
            child: FutureBuilder<List<UserModel>>(
              future: _futureUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Center(child: Text('Terjadi error: ${snapshot.error}')),
                      ],
                    ),
                  );
                }
                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text('Belum ada data user')),
                    ],
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(user.name[0].toUpperCase())),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserFormScreen(user: user),
                                ),
                              );
                              _loadUsers(); // Refresh daftar setelah kembali dari form edit
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // Tampilkan dialog konfirmasi sebelum hapus
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Hapus User'),
                                  content: Text('Apakah kamu yakin ingin menghapus ${user.name}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _deleteUser(user.id);
                                      },
                                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserFormScreen()),
              );
              _loadUsers(); // Refresh daftar setelah kembali dari form tambah
            },
          ),
        ),
        
        // 4. Lapisan Loading Overlay saat proses delete sedang berjalan
        if (_isDeleting)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}