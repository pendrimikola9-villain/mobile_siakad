import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Provider & Services
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';

// Import Semua Screen
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'SIAKAD Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: false,
        ),
        home: const SplashDecider(),
      ),
    );
  }
}

// Widget Penentu Halaman Awal
class SplashDecider extends StatelessWidget {
  const SplashDecider({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      // 🟢 Menggunakan AuthService langsung untuk mengecek status login di Local Storage
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        // Tampilkan Loading Spinner saat pengecekan
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Jika token ditemukan (true) -> Masuk ke MainNavigation (Dashboard + Tab Navigasi)
        // Jika tidak ada token (false) -> Masuk ke LoginScreen
        if (snapshot.data == true) {
          return const MainNavigation();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}