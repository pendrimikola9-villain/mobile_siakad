import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/krs_model.dart';
import 'auth_service.dart'; // Untuk ambil token

class KrsService {
  final AuthService _authService = AuthService();

  Future<List<MatakuliahModel>> getMatakuliah() async {
    final token = await _authService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/courses'), // Nembak ke /courses
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // Cek apakah data dibungkus dalam key 'data'
      List<dynamic> listData = [];
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        listData = body['data'];
      } else if (body is List) {
        listData = body;
      }

      return listData.map((item) => MatakuliahModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data mata kuliah (Status: ${response.statusCode})');
    }
  }

  // Fungsi Submit KRS
  Future<Map<String, dynamic>> submitKrs(List<int> selectedIds) async {
    final token = await _authService.getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/krs'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'matkul_ids': selectedIds,
      }),
    );

    return jsonDecode(response.body);
  }
}