import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class FormBimbinganScreen extends StatefulWidget {
  const FormBimbinganScreen({super.key});

  @override
  State<FormBimbinganScreen> createState() => _FormBimbinganScreenState();
}

class _FormBimbinganScreenState extends State<FormBimbinganScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // State Dosen
  List<dynamic> _listDosen = [];
  String? _selectedDosenId;
  bool _isLoadingDosen = true;

  // Form Inputs
  String _jenisKonsultasi = 'Skripsi / TA';
  final TextEditingController _topikController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  String _requestPertemuan = 'Tidak';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default tanggal hari ini (YYYY-MM-DD)
    _tanggalController.text = DateTime.now().toString().split(' ')[0];
    // Ambil data dosen asli dari database saat screen dibuka
    _fetchDosen();
  }

  // 🟢 AMBIL DATA DOSEN ASLI DARI TABEL LECTURERS (LARAVEL)
  Future<void> _fetchDosen() async {
    try {
      final token = await _authService.getToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/get-dosen');

      debugPrint('🔎 MEMANGGIL API DOSEN: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📩 STATUS RESPONSE DOSEN: ${response.statusCode}');
      debugPrint('📩 ISI BODY DOSEN: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> fetchedList = body['data'] as List<dynamic>? ?? [];

        setState(() {
          _listDosen = fetchedList;
          if (_listDosen.isNotEmpty) {
            _selectedDosenId = _listDosen[0]['id'].toString();
          }
        });
      } else {
        debugPrint('❌ Gagal ambil dosen backend. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error exception fetch dosen: $e');
    } finally {
      if (mounted) setState(() => _isLoadingDosen = false);
    }
  }

  // 🟢 KIRIM PENGAJUAN BIMBINGAN KE API
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = await _authService.getToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/consultation-logs');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'dosen_id': _selectedDosenId,
          'jenis_konsultasi': _jenisKonsultasi,
          'topik_bimbingan': _topikController.text,
          'tanggal_bimbingan': _tanggalController.text,
          'request_pertemuan': _requestPertemuan,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message'] ?? 'Pengajuan bimbingan berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kembali & refresh halaman logbook
      } else {
        throw Exception(body['message'] ?? 'Gagal menyimpan data (${response.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Ajukan Konsultasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. DROPDOWN DOSEN PEMBIMBING
              const Text('Pilih Dosen Pembimbing / Konsultasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              _isLoadingDosen
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _selectedDosenId,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: _listDosen.map((dosen) {
                        final String namaDosen = dosen['name']?.toString() ?? 
                                                 dosen['nama']?.toString() ?? 
                                                 dosen['nama_dosen']?.toString() ?? 
                                                 'Dosen ${dosen['id']}';
                        return DropdownMenuItem<String>(
                          value: dosen['id'].toString(),
                          child: Text(namaDosen),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedDosenId = val),
                      validator: (val) => (val == null || val.isEmpty) ? 'Pilih Dosen terlebih dahulu' : null,
                    ),

              const SizedBox(height: 16),

              // 2. JENIS KONSULTASI
              const Text('Jenis Konsultasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _jenisKonsultasi,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: ['Skripsi / TA', 'PKL / Magang', 'Akademik / PA']
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (val) => setState(() => _jenisKonsultasi = val!),
              ),

              const SizedBox(height: 16),

              // 3. TOPIK BIMBINGAN
              const Text('Topik Bimbingan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _topikController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh: Diskusi Bab 1 dan Aturan Fuzzy',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Topik tidak boleh kosong' : null,
              ),

              const SizedBox(height: 16),

              // 4. TANGGAL BIMBINGAN
              const Text('Tanggal Bimbingan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tanggalController,
                readOnly: true,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.calendar_month),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _tanggalController.text = picked.toString().split(' ')[0];
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // 5. REQUEST PERTEMUAN
              const Text('Butuh Pertemuan / Janji Temu Hari Ini?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Tidak', style: TextStyle(fontSize: 13)),
                      value: 'Tidak',
                      groupValue: _requestPertemuan,
                      onChanged: (val) => setState(() => _requestPertemuan = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Ya', style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold)),
                      value: 'Ya',
                      groupValue: _requestPertemuan,
                      onChanged: (val) => setState(() => _requestPertemuan = val!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 6. TOMBOL SUBMIT
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Kirim Pengajuan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}