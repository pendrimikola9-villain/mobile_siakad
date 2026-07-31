import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // State internal aplikasi
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  Map<String, dynamic>? _validationErrors;

  // Getter agar UI bisa membaca state
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  Map<String, dynamic>? get validationErrors => _validationErrors;

  // ================= LOGIKA LOGIN MAHASISWA =================
  Future<bool> login(String nimOrEmail, String password) async {
    _setLoading(true);
    _clearErrors();

    // 🟢 Memanggil fungsi login dari AuthService (Bukan nulis http.post lagi di sini)
    final result = await _authService.login(nimOrEmail, password);

    _setLoading(false);

    if (result['success']) {
      _errorMessage = null;
      // Ambil token yang tersimpan jika ada
      _token = await _authService.getToken();
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // ================= LOGIKA REGISTER =================
  Future<bool> register(
      String name, String email, String password, String confirmPassword) async {
    _setLoading(true);
    _clearErrors();

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: confirmPassword,
    );

    _setLoading(false);

    if (result['success']) {
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
      _validationErrors = result['errors'];
    }

    notifyListeners();
    return result['success'];
  }

  // ================= LOGIKA LOGOUT =================
  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _clearErrors();
  }

  // ================= FUNGSI UTILITY (State Helpers) =================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearErrors() {
    _errorMessage = null;
    _validationErrors = null;
  }
}