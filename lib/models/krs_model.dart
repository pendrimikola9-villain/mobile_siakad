class MatakuliahModel {
  final int id;
  final String kode;
  final String nama;
  final int sks;
  bool isSelected;

  MatakuliahModel({
    required this.id,
    required this.kode,
    required this.nama,
    required this.sks,
    this.isSelected = false,
  });

  factory MatakuliahModel.fromJson(Map<String, dynamic> json) {
    return MatakuliahModel(
      id: json['id'] ?? 0,
      // Sesuaikan key jika di DB nama kolomnya 'kode_mk' atau 'kode'
      kode: json['kode_mk'] ?? json['kode'] ?? '', 
      // Sesuaikan key jika di DB nama kolomnya 'nama_mk' atau 'nama' atau 'name'
      nama: json['nama_mk'] ?? json['nama'] ?? json['name'] ?? '', 
      sks: json['sks'] is int ? json['sks'] : int.tryParse(json['sks'].toString()) ?? 0,
    );
  }
}