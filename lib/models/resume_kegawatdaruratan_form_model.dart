class ResumeKegawatdaruratanFormModel {
  final int? id;
  final int userId;
  final int patientId;
  final String status;
  
  final String? namaPasien;
  final String? noRm;
  final DateTime? tanggalMasuk;
  final String? jamMasuk;
  final DateTime? tanggalKeluar;
  final String? jamKeluar;
  
  final String? keluhanUtama;
  final String? riwayatPenyakitSekarang;
  final String? riwayatPenyakitDahulu;
  final String? riwayatPengobatan;
  
  final String? kesadaran;
  final String? gcs;
  final String? tekananDarah;
  final String? nadi;
  final String? suhu;
  final String? pernapasan;
  final String? spo2;
  
  final String? penampilan;
  final String? perilaku;
  final String? pembicaraan;
  final String? moodAfek;
  final String? pikiran;
  final String? persepsi;
  final String? kognitif;
  
  final String? diagnosisKerja;
  final String? tindakanYangDilakukan;
  final String? terapiObat;
  final String? kondisiKeluar;
  final String? anjuran;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ResumeKegawatdaruratanFormModel({
    this.id,
    required this.userId,
    required this.patientId,
    this.status = 'draft',
    this.namaPasien,
    this.noRm,
    this.tanggalMasuk,
    this.jamMasuk,
    this.tanggalKeluar,
    this.jamKeluar,
    this.keluhanUtama,
    this.riwayatPenyakitSekarang,
    this.riwayatPenyakitDahulu,
    this.riwayatPengobatan,
    this.kesadaran,
    this.gcs,
    this.tekananDarah,
    this.nadi,
    this.suhu,
    this.pernapasan,
    this.spo2,
    this.penampilan,
    this.perilaku,
    this.pembicaraan,
    this.moodAfek,
    this.pikiran,
    this.persepsi,
    this.kognitif,
    this.diagnosisKerja,
    this.tindakanYangDilakukan,
    this.terapiObat,
    this.kondisiKeluar,
    this.anjuran,
    this.createdAt,
    this.updatedAt,
  });

  factory ResumeKegawatdaruratanFormModel.fromJson(Map<String, dynamic> json) {
    return ResumeKegawatdaruratanFormModel(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      patientId: json['patient_id'] ?? 0,
      status: json['status'] ?? 'draft',
      namaPasien: json['nama_pasien'],
      noRm: json['no_rm'],
      tanggalMasuk: json['tanggal_masuk'] != null ? DateTime.parse(json['tanggal_masuk']) : null,
      jamMasuk: json['jam_masuk'],
      tanggalKeluar: json['tanggal_keluar'] != null ? DateTime.parse(json['tanggal_keluar']) : null,
      jamKeluar: json['jam_keluar'],
      keluhanUtama: json['keluhan_utama'],
      riwayatPenyakitSekarang: json['riwayat_penyakit_sekarang'],
      riwayatPenyakitDahulu: json['riwayat_penyakit_dahulu'],
      riwayatPengobatan: json['riwayat_pengobatan'],
      kesadaran: json['kesadaran'],
      gcs: json['gcs'],
      tekananDarah: json['tekanan_darah'],
      nadi: json['nadi'],
      suhu: json['suhu'],
      pernapasan: json['pernapasan'],
      spo2: json['spo2'],
      penampilan: json['penampilan'],
      perilaku: json['perilaku'],
      pembicaraan: json['pembicaraan'],
      moodAfek: json['mood_afek'],
      pikiran: json['pikiran'],
      persepsi: json['persepsi'],
      kognitif: json['kognitif'],
      diagnosisKerja: json['diagnosis_kerja'],
      tindakanYangDilakukan: json['tindakan_yang_dilakukan'],
      terapiObat: json['terapi_obat'],
      kondisiKeluar: json['kondisi_keluar'],
      anjuran: json['anjuran'],
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
      if (namaPasien != null) 'nama_pasien': namaPasien,
      if (noRm != null) 'no_rm': noRm,
      if (tanggalMasuk != null) 'tanggal_masuk': tanggalMasuk!.toIso8601String().split('T')[0],
      if (jamMasuk != null) 'jam_masuk': jamMasuk,
      if (tanggalKeluar != null) 'tanggal_keluar': tanggalKeluar!.toIso8601String().split('T')[0],
      if (jamKeluar != null) 'jam_keluar': jamKeluar,
      if (keluhanUtama != null) 'keluhan_utama': keluhanUtama,
      if (riwayatPenyakitSekarang != null) 'riwayat_penyakit_sekarang': riwayatPenyakitSekarang,
      if (riwayatPenyakitDahulu != null) 'riwayat_penyakit_dahulu': riwayatPenyakitDahulu,
      if (riwayatPengobatan != null) 'riwayat_pengobatan': riwayatPengobatan,
      if (kesadaran != null) 'kesadaran': kesadaran,
      if (gcs != null) 'gcs': gcs,
      if (tekananDarah != null) 'tekanan_darah': tekananDarah,
      if (nadi != null) 'nadi': nadi,
      if (suhu != null) 'suhu': suhu,
      if (pernapasan != null) 'pernapasan': pernapasan,
      if (spo2 != null) 'spo2': spo2,
      if (penampilan != null) 'penampilan': penampilan,
      if (perilaku != null) 'perilaku': perilaku,
      if (pembicaraan != null) 'pembicaraan': pembicaraan,
      if (moodAfek != null) 'mood_afek': moodAfek,
      if (pikiran != null) 'pikiran': pikiran,
      if (persepsi != null) 'persepsi': persepsi,
      if (kognitif != null) 'kognitif': kognitif,
      if (diagnosisKerja != null) 'diagnosis_kerja': diagnosisKerja,
      if (tindakanYangDilakukan != null) 'tindakan_yang_dilakukan': tindakanYangDilakukan,
      if (terapiObat != null) 'terapi_obat': terapiObat,
      if (kondisiKeluar != null) 'kondisi_keluar': kondisiKeluar,
      if (anjuran != null) 'anjuran': anjuran,
    };
  }
}
