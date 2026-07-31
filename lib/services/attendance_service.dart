import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class AttendanceService {
  final AuthService _authService = AuthService();

  Future<List<dynamic>> getAttendanceHistory() async {
    final token = await _authService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/presensi'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // Cek apakah data dibungkus dalam key 'data' atau 'mahasiswa'
      if (body is Map<String, dynamic>) {
        if (body.containsKey('data') && body['data'] is List) {
          return body['data'];
        } else if (body.containsKey('mahasiswa') && body['mahasiswa'] is List) {
          return body['mahasiswa'];
        }
      } else if (body is List) {
        return body;
      }
      return [];
    } else {
      throw Exception('Gagal memuat data presensi (Status: ${response.statusCode})');
    }
  }
}