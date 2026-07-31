class MahasiswaModel {
  final int id;
  final String nim;
  final String nama;
  final String prodi;
  final double ipk;

  MahasiswaModel({
    required this.id,
    required this.nim,
    required this.nama,
    required this.prodi,
    required this.ipk,
  });

  factory MahasiswaModel.fromJson(Map<String, dynamic> json) {
    return MahasiswaModel(
      id: json['id'] ?? 0,
      nim: json['nim'] ?? '',
      nama: json['nama'] ?? json['name'] ?? '',
      prodi: json['prodi'] ?? 'Informatika',
      ipk: (json['ipk'] ?? 0.0).toDouble(),
    );
  }
}