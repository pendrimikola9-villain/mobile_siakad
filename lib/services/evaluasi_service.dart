import 'dart:convert'; // 👈 Angka '0' sudah dihapus
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class EvaluasiService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getEvaluasiData() async {
    final token = await _authService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/evaluasi-fuzzy'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat data evaluasi fuzzy (Status: ${response.statusCode})');
    }
  }
}