class SapFormModel {
  final int? id;
  final int userId;
  final int patientId;
  final String status;
  
  final String? topik;
  final String? subTopik;
  final String? sasaran;
  final DateTime? tanggalPelaksanaan;
  final String? waktuPelaksanaan;
  final String? tempat;
  final int? durasi;
  
  final String? tujuanUmum;
  final String? tujuanKhusus;
  final String? materiPenyuluhan;
  
  final List<String>? metode;
  final List<String>? media;
  final List<Map<String, dynamic>>? kegiatan;
  
  final String? evaluasiStruktur;
  final String? evaluasiProses;
  final String? evaluasiHasil;
  
  final String? materiFilePath;
  final String? dokumentasiFotoPath;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SapFormModel({
    this.id,
    required this.userId,
    required this.patientId,
    this.status = 'draft',
    this.topik,
    this.subTopik,
    this.sasaran,
    this.tanggalPelaksanaan,
    this.waktuPelaksanaan,
    this.tempat,
    this.durasi,
    this.tujuanUmum,
    this.tujuanKhusus,
    this.materiPenyuluhan,
    this.metode,
    this.media,
    this.kegiatan,
    this.evaluasiStruktur,
    this.evaluasiProses,
    this.evaluasiHasil,
    this.materiFilePath,
    this.dokumentasiFotoPath,
    this.createdAt,
    this.updatedAt,
  });

  factory SapFormModel.fromJson(Map<String, dynamic> json) {
    return SapFormModel(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      patientId: json['patient_id'] ?? 0,
      status: json['status'] ?? 'draft',
      topik: json['topik'],
      subTopik: json['sub_topik'],
      sasaran: json['sasaran'],
      tanggalPelaksanaan: json['tanggal_pelaksanaan'] != null ? DateTime.parse(json['tanggal_pelaksanaan']) : null,
      waktuPelaksanaan: json['waktu_pelaksanaan'],
      tempat: json['tempat'],
      durasi: json['durasi'],
      tujuanUmum: json['tujuan_umum'],
      tujuanKhusus: json['tujuan_khusus'],
      materiPenyuluhan: json['materi_penyuluhan'],
      metode: json['metode'] != null ? List<String>.from(json['metode']) : null,
      media: json['media'] != null ? List<String>.from(json['media']) : null,
      kegiatan: json['kegiatan'] != null ? List<Map<String, dynamic>>.from(json['kegiatan']) : null,
      evaluasiStruktur: json['evaluasi_struktur'],
      evaluasiProses: json['evaluasi_proses'],
      evaluasiHasil: json['evaluasi_hasil'],
      materiFilePath: json['materi_file_path'],
      dokumentasiFotoPath: json['dokumentasi_foto_path'],
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
      if (topik != null) 'topik': topik,
      if (subTopik != null) 'sub_topik': subTopik,
      if (sasaran != null) 'sasaran': sasaran,
      if (tanggalPelaksanaan != null) 'tanggal_pelaksanaan': tanggalPelaksanaan!.toIso8601String().split('T')[0],
      if (waktuPelaksanaan != null) 'waktu_pelaksanaan': waktuPelaksanaan,
      if (tempat != null) 'tempat': tempat,
      if (durasi != null) 'durasi': durasi,
      if (tujuanUmum != null) 'tujuan_umum': tujuanUmum,
      if (tujuanKhusus != null) 'tujuan_khusus': tujuanKhusus,
      if (materiPenyuluhan != null) 'materi_penyuluhan': materiPenyuluhan,
      if (metode != null) 'metode': metode,
      if (media != null) 'media': media,
      if (kegiatan != null) 'kegiatan': kegiatan,
      if (evaluasiStruktur != null) 'evaluasi_struktur': evaluasiStruktur,
      if (evaluasiProses != null) 'evaluasi_proses': evaluasiProses,
      if (evaluasiHasil != null) 'evaluasi_hasil': evaluasiHasil,
      if (materiFilePath != null) 'materi_file_path': materiFilePath,
      if (dokumentasiFotoPath != null) 'dokumentasi_foto_path': dokumentasiFotoPath,
    };
  }
}
