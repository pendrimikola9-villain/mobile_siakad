import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  final AuthService _authService = AuthService();

  // Helper untuk membuat header standard yang berisi token keamanan
  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET semua user
Future<List<UserModel>> getUsers() async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/users'),
    headers: await _headers(),
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);

    // 🟢 Cek apakah data dibungkus dalam key 'data' atau 'users'
    final List data = (body is Map && body.containsKey('data')) 
        ? body['data'] 
        : body;

    return data.map((json) => UserModel.fromJson(json)).toList();
  } else {
    throw Exception('Gagal mengambil data user');
  }
}
// CREATE user
Future<Map<String, dynamic>> createUser({
  required String name,
  required String email,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/users'),
    headers: await _headers(),
    body: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password, // 🟢 TAMBAHKAN BARIS INI
    },
  );

  final data = jsonDecode(response.body);
  if (response.statusCode == 201 || response.statusCode == 200) {
    return {'success': true, 'message': data['message'] ?? 'Berhasil menambah user'};
  }
  return {
    'success': false, 
    'message': data['message'] ?? 'Gagal menambah user', 
    'errors': data['errors']
  };
}

  // ================= UPDATE USER =================
  Future<Map<String, dynamic>> updateUser({
    required int id,
    required String name,
    required String email,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/users/$id'),
      headers: await _headers(),
      body: {
        'name': name,
        'email': email,
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'message': data['message']};
    }
    return {
      'success': false, 
      'message': data['message'] ?? 'Gagal memperbarui user',
      'errors': data['errors']
    };
  }

  // ================= DELETE USER =================
  Future<bool> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/users/$id'),
      headers: await _headers(),
    );

    return response.statusCode == 200;
  }
}