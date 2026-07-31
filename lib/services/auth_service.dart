import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  // Header standar untuk menyamar sebagai Browser dan menembus sistem proteksi/Ngrok
  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'ngrok-skip-browser-warning': 'true',
      };

  // ================= REGISTER =================
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: _defaultHeaders,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (!response.headers['content-type']!.contains('application/json')) {
        return {
          'success': false,
          'message': 'Server tidak mengembalikan response JSON valid.'
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (data['token'] != null) await _saveToken(data['token']);
        return {'success': true, 'message': data['message'] ?? 'Registrasi Berhasil'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal',
          'errors': data['errors']
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // ================= LOGIN MAHASISWA =================
  Future<Map<String, dynamic>> login(String nimOrEmail, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: _defaultHeaders,
        body: jsonEncode({
          'nim': nimOrEmail,
          'email': nimOrEmail,
          'password': password,
        }),
      );

      // 💡 Langsung decode response JSON dari Cloudflare Worker
      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && data['token'] != null) {
        await _saveToken(data['token']);

        if (data['user'] != null) {
          await _saveUserData(jsonEncode(data['user']));
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Login Berhasil'
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'NIM/Email atau Password salah'
      };
    } catch (e) {
      return {
        'success': false, 
        'message': 'Gagal terhubung atau format tidak valid: $e'
      };
    }
  }

  // ================= LOGOUT =================
  Future<bool> logout() async {
    final token = await getToken();

    try {
      final headers = _defaultHeaders;
      headers['Authorization'] = 'Bearer $token';

      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/logout'),
        headers: headers,
      );
    } catch (_) {}

    await _removeToken();
    return true;
  }

  // ================= FUNGSI UTILITAS TOKEN & USER =================

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveUserData(String jsonUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonUser);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_data');
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}