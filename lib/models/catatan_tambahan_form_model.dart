class CatatanTambahanFormModel {
  final int? id;
  final int userId;
  final int patientId;
  final String status;
  
  final DateTime? tanggalCatatan;
  final String? waktuCatatan;
  final String? kategori;
  final String? catatan;
  final String? tindakLanjut;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CatatanTambahanFormModel({
    this.id,
    required this.userId,
    required this.patientId,
    this.status = 'draft',
    this.tanggalCatatan,
    this.waktuCatatan,
    this.kategori,
    this.catatan,
    this.tindakLanjut,
    this.createdAt,
    this.updatedAt,
  });

  factory CatatanTambahanFormModel.fromJson(Map<String, dynamic> json) {
    return CatatanTambahanFormModel(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      patientId: json['patient_id'] ?? 0,
      status: json['status'] ?? 'draft',
      tanggalCatatan: json['tanggal_catatan'] != null ? DateTime.parse(json['tanggal_catatan']) : null,
      waktuCatatan: json['waktu_catatan'],
      kategori: json['kategori'],
      catatan: json['catatan'],
      tindakLanjut: json['tindak_lanjut'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'patient_id': patientId,
      'status': status,
      if (tanggalCatatan != null) 'tanggal_catatan': tanggalCatatan!.toIso8601String().split('T')[0],
      if (waktuCatatan != null) 'waktu_catatan': waktuCatatan,
      if (kategori != null) 'kategori': kategori,
      if (catatan != null) 'catatan': catatan,
      if (tindakLanjut != null) 'tindak_lanjut': tindakLanjut,
    };
  }
}
