class ResumePoliklinikFormModel {
  final int? id;
  final int userId;
  final int patientId;
  final String status;
  
  final String? namaPasien;
  final String? noRm;
  final DateTime? tanggalKunjungan;
  final String? poliklinik;
  
  final String? keluhanUtama;
  final String? riwayatPenyakitSekarang;
  final String? riwayatPenyakitDahulu;
  final String? riwayatPengobatan;
  final String? riwayatAlergi;
  
  final String? kesadaran;
  final String? tekananDarah;
  final String? nadi;
  final String? suhu;
  final String? pernapasan;
  final String? beratBadan;
  final String? tinggiBadan;
  
  final String? penampilan;
  final String? perilaku;
  final String? moodAfek;
  final String? pikiran;
  
  final String? diagnosis;
  final String? terapiFarmakologi;
  final String? terapiNonFarmakologi;
  final String? edukasi;
  
  final DateTime? tanggalKontrolBerikutnya;
  final String? rencanaTindakLanjut;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ResumePoliklinikFormModel({
    this.id,
    required this.userId,
    required this.patientId,
    this.status = 'draft',
    this.namaPasien,
    this.noRm,
    this.tanggalKunjungan,
    this.poliklinik,
    this.keluhanUtama,
    this.riwayatPenyakitSekarang,
    this.riwayatPenyakitDahulu,
    this.riwayatPengobatan,
    this.riwayatAlergi,
    this.kesadaran,
    this.tekananDarah,
    this.nadi,
    this.suhu,
    this.pernapasan,
    this.beratBadan,
    this.tinggiBadan,
    this.penampilan,
    this.perilaku,
    this.moodAfek,
    this.pikiran,
    this.diagnosis,
    this.terapiFarmakologi,
    this.terapiNonFarmakologi,
    this.edukasi,
    this.tanggalKontrolBerikutnya,
    this.rencanaTindakLanjut,
    this.createdAt,
    this.updatedAt,
  });

  factory ResumePoliklinikFormModel.fromJson(Map<String, dynamic> json) {
    return ResumePoliklinikFormModel(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      patientId: json['patient_id'] ?? 0,
      status: json['status'] ?? 'draft',
      namaPasien: json['nama_pasien'],
      noRm: json['no_rm'],
      tanggalKunjungan: json['tanggal_kunjungan'] != null ? DateTime.parse(json['tanggal_kunjungan']) : null,
      poliklinik: json['poliklinik'],
      keluhanUtama: json['keluhan_utama'],
      riwayatPenyakitSekarang: json['riwayat_penyakit_sekarang'],
      riwayatPenyakitDahulu: json['riwayat_penyakit_dahulu'],
      riwayatPengobatan: json['riwayat_pengobatan'],
      riwayatAlergi: json['riwayat_alergi'],
      kesadaran: json['kesadaran'],
      tekananDarah: json['tekanan_darah'],
      nadi: json['nadi'],
      suhu: json['suhu'],
      pernapasan: json['pernapasan'],
      beratBadan: json['berat_badan'],
      tinggiBadan: json['tinggi_badan'],
      penampilan: json['penampilan'],
      perilaku: json['perilaku'],
      moodAfek: json['mood_afek'],
      pikiran: json['pikiran'],
      diagnosis: json['diagnosis'],
      terapiFarmakologi: json['terapi_farmakologi'],
      terapiNonFarmakologi: json['terapi_non_farmakologi'],
      edukasi: json['edukasi'],
      tanggalKontrolBerikutnya: json['tanggal_kontrol_berikutnya'] != null ? DateTime.parse(json['tanggal_kontrol_berikutnya']) : null,
      rencanaTindakLanjut: json['rencana_tindak_lanjut'],
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
      if (tanggalKunjungan != null) 'tanggal_kunjungan': tanggalKunjungan!.toIso8601String().split('T')[0],
      if (poliklinik != null) 'poliklinik': poliklinik,
      if (keluhanUtama != null) 'keluhan_utama': keluhanUtama,
      if (riwayatPenyakitSekarang != null) 'riwayat_penyakit_sekarang': riwayatPenyakitSekarang,
      if (riwayatPenyakitDahulu != null) 'riwayat_penyakit_dahulu': riwayatPenyakitDahulu,
      if (riwayatPengobatan != null) 'riwayat_pengobatan': riwayatPengobatan,
      if (riwayatAlergi != null) 'riwayat_alergi': riwayatAlergi,
      if (kesadaran != null) 'kesadaran': kesadaran,
      if (tekananDarah != null) 'tekanan_darah': tekananDarah,
      if (nadi != null) 'nadi': nadi,
      if (suhu != null) 'suhu': suhu,
      if (pernapasan != null) 'pernapasan': pernapasan,
      if (beratBadan != null) 'berat_badan': beratBadan,
      if (tinggiBadan != null) 'tinggi_badan': tinggiBadan,
      if (penampilan != null) 'penampilan': penampilan,
      if (perilaku != null) 'perilaku': perilaku,
      if (moodAfek != null) 'mood_afek': moodAfek,
      if (pikiran != null) 'pikiran': pikiran,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (terapiFarmakologi != null) 'terapi_farmakologi': terapiFarmakologi,
      if (terapiNonFarmakologi != null) 'terapi_non_farmakologi': terapiNonFarmakologi,
      if (edukasi != null) 'edukasi': edukasi,
      if (tanggalKontrolBerikutnya != null) 'tanggal_kontrol_berikutnya': tanggalKontrolBerikutnya!.toIso8601String().split('T')[0],
      if (rencanaTindakLanjut != null) 'rencana_tindak_lanjut': rencanaTindakLanjut,
    };
  }
}
