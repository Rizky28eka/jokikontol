class PengkajianFormModel {
  final int? id;
  final int userId;
  final int patientId;
  final String status;
  
  // Identitas Pasien
  final String? namaLengkap;
  final String? tempatLahir;
  final DateTime? tanggalLahir;
  final int? usia;
  final String? jenisKelamin;
  final String? agama;
  final String? suku;
  final String? pendidikan;
  final String? pekerjaan;
  final String? alamat;
  final String? noRm;
  final DateTime? tanggalMasuk;
  final String? diagnosaMedis;
  
  // Keluhan & Riwayat
  final String? keluhanUtama;
  final String? riwayatPenyakitSekarang;
  final String? riwayatPenyakitDahulu;
  final String? riwayatPenyakitKeluarga;
  final String? riwayatPengobatan;
  
  // Pemeriksaan Fisik
  final String? tekananDarah;
  final String? nadi;
  final String? suhu;
  final String? pernapasan;
  final String? tinggiBadan;
  final String? beratBadan;
  
  // Psikososial
  final String? konsepDiri;
  final String? hubunganSosial;
  final String? spiritual;
  
  // Genogram
  final Map<String, dynamic>? genogramStructure;
  final String? genogramNotes;
  
  // Status Mental
  final String? penampilan;
  final String? pembicaraan;
  final String? aktivitasMotorik;
  final String? alamPerasaan;
  final String? afek;
  final String? interaksi;
  final String? persepsi;
  final String? prosesPikir;
  final String? isiPikir;
  final String? tingkatKesadaran;
  final String? memori;
  final String? tingkatKonsentrasi;
  final String? orientasi;
  final String? dayaTilikDiri;
  
  // Kebutuhan Persiapan Pulang
  final bool? makanMandiri;
  final bool? babBakMandiri;
  final bool? mandiMandiri;
  final bool? berpakaianMandiri;
  final bool? istirahatTidurCukup;
  final String? kebutuhanPersiapanPulangLainnya;
  
  // Mekanisme Koping & Masalah
  final String? mekanismeKoping;
  final List<String>? masalahPsikososial;
  
  // Aspek Medik
  final String? diagnosaMedisLengkap;
  final String? terapiMedis;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PengkajianFormModel({
    this.id,
    required this.userId,
    required this.patientId,
    this.status = 'draft',
    this.namaLengkap,
    this.tempatLahir,
    this.tanggalLahir,
    this.usia,
    this.jenisKelamin,
    this.agama,
    this.suku,
    this.pendidikan,
    this.pekerjaan,
    this.alamat,
    this.noRm,
    this.tanggalMasuk,
    this.diagnosaMedis,
    this.keluhanUtama,
    this.riwayatPenyakitSekarang,
    this.riwayatPenyakitDahulu,
    this.riwayatPenyakitKeluarga,
    this.riwayatPengobatan,
    this.tekananDarah,
    this.nadi,
    this.suhu,
    this.pernapasan,
    this.tinggiBadan,
    this.beratBadan,
    this.konsepDiri,
    this.hubunganSosial,
    this.spiritual,
    this.genogramStructure,
    this.genogramNotes,
    this.penampilan,
    this.pembicaraan,
    this.aktivitasMotorik,
    this.alamPerasaan,
    this.afek,
    this.interaksi,
    this.persepsi,
    this.prosesPikir,
    this.isiPikir,
    this.tingkatKesadaran,
    this.memori,
    this.tingkatKonsentrasi,
    this.orientasi,
    this.dayaTilikDiri,
    this.makanMandiri,
    this.babBakMandiri,
    this.mandiMandiri,
    this.berpakaianMandiri,
    this.istirahatTidurCukup,
    this.kebutuhanPersiapanPulangLainnya,
    this.mekanismeKoping,
    this.masalahPsikososial,
    this.diagnosaMedisLengkap,
    this.terapiMedis,
    this.createdAt,
    this.updatedAt,
  });

  factory PengkajianFormModel.fromJson(Map<String, dynamic> json) {
    return PengkajianFormModel(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      patientId: json['patient_id'] ?? 0,
      status: json['status'] ?? 'draft',
      namaLengkap: json['nama_lengkap'],
      tempatLahir: json['tempat_lahir'],
      tanggalLahir: json['tanggal_lahir'] != null ? DateTime.parse(json['tanggal_lahir']) : null,
      usia: json['usia'],
      jenisKelamin: json['jenis_kelamin'],
      agama: json['agama'],
      suku: json['suku'],
      pendidikan: json['pendidikan'],
      pekerjaan: json['pekerjaan'],
      alamat: json['alamat'],
      noRm: json['no_rm'],
      tanggalMasuk: json['tanggal_masuk'] != null ? DateTime.parse(json['tanggal_masuk']) : null,
      diagnosaMedis: json['diagnosa_medis'],
      keluhanUtama: json['keluhan_utama'],
      riwayatPenyakitSekarang: json['riwayat_penyakit_sekarang'],
      riwayatPenyakitDahulu: json['riwayat_penyakit_dahulu'],
      riwayatPenyakitKeluarga: json['riwayat_penyakit_keluarga'],
      riwayatPengobatan: json['riwayat_pengobatan'],
      tekananDarah: json['tekanan_darah'],
      nadi: json['nadi'],
      suhu: json['suhu'],
      pernapasan: json['pernapasan'],
      tinggiBadan: json['tinggi_badan'],
      beratBadan: json['berat_badan'],
      konsepDiri: json['konsep_diri'],
      hubunganSosial: json['hubungan_sosial'],
      spiritual: json['spiritual'],
      genogramStructure: json['genogram_structure'],
      genogramNotes: json['genogram_notes'],
      penampilan: json['penampilan'],
      pembicaraan: json['pembicaraan'],
      aktivitasMotorik: json['aktivitas_motorik'],
      alamPerasaan: json['alam_perasaan'],
      afek: json['afek'],
      interaksi: json['interaksi'],
      persepsi: json['persepsi'],
      prosesPikir: json['proses_pikir'],
      isiPikir: json['isi_pikir'],
      tingkatKesadaran: json['tingkat_kesadaran'],
      memori: json['memori'],
      tingkatKonsentrasi: json['tingkat_konsentrasi'],
      orientasi: json['orientasi'],
      dayaTilikDiri: json['daya_tilik_diri'],
      makanMandiri: json['makan_mandiri'],
      babBakMandiri: json['bab_bak_mandiri'],
      mandiMandiri: json['mandi_mandiri'],
      berpakaianMandiri: json['berpakaian_mandiri'],
      istirahatTidurCukup: json['istirahat_tidur_cukup'],
      kebutuhanPersiapanPulangLainnya: json['kebutuhan_persiapan_pulang_lainnya'],
      mekanismeKoping: json['mekanisme_koping'],
      masalahPsikososial: json['masalah_psikososial'] != null 
          ? List<String>.from(json['masalah_psikososial']) 
          : null,
      diagnosaMedisLengkap: json['diagnosa_medis_lengkap'],
      terapiMedis: json['terapi_medis'],
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
      if (namaLengkap != null) 'nama_lengkap': namaLengkap,
      if (tempatLahir != null) 'tempat_lahir': tempatLahir,
      if (tanggalLahir != null) 'tanggal_lahir': tanggalLahir!.toIso8601String().split('T')[0],
      if (usia != null) 'usia': usia,
      if (jenisKelamin != null) 'jenis_kelamin': jenisKelamin,
      if (agama != null) 'agama': agama,
      if (suku != null) 'suku': suku,
      if (pendidikan != null) 'pendidikan': pendidikan,
      if (pekerjaan != null) 'pekerjaan': pekerjaan,
      if (alamat != null) 'alamat': alamat,
      if (noRm != null) 'no_rm': noRm,
      if (tanggalMasuk != null) 'tanggal_masuk': tanggalMasuk!.toIso8601String().split('T')[0],
      if (diagnosaMedis != null) 'diagnosa_medis': diagnosaMedis,
      if (keluhanUtama != null) 'keluhan_utama': keluhanUtama,
      if (riwayatPenyakitSekarang != null) 'riwayat_penyakit_sekarang': riwayatPenyakitSekarang,
      if (riwayatPenyakitDahulu != null) 'riwayat_penyakit_dahulu': riwayatPenyakitDahulu,
      if (riwayatPenyakitKeluarga != null) 'riwayat_penyakit_keluarga': riwayatPenyakitKeluarga,
      if (riwayatPengobatan != null) 'riwayat_pengobatan': riwayatPengobatan,
      if (tekananDarah != null) 'tekanan_darah': tekananDarah,
      if (nadi != null) 'nadi': nadi,
      if (suhu != null) 'suhu': suhu,
      if (pernapasan != null) 'pernapasan': pernapasan,
      if (tinggiBadan != null) 'tinggi_badan': tinggiBadan,
      if (beratBadan != null) 'berat_badan': beratBadan,
      if (konsepDiri != null) 'konsep_diri': konsepDiri,
      if (hubunganSosial != null) 'hubungan_sosial': hubunganSosial,
      if (spiritual != null) 'spiritual': spiritual,
      if (genogramStructure != null) 'genogram_structure': genogramStructure,
      if (genogramNotes != null) 'genogram_notes': genogramNotes,
      if (penampilan != null) 'penampilan': penampilan,
      if (pembicaraan != null) 'pembicaraan': pembicaraan,
      if (aktivitasMotorik != null) 'aktivitas_motorik': aktivitasMotorik,
      if (alamPerasaan != null) 'alam_perasaan': alamPerasaan,
      if (afek != null) 'afek': afek,
      if (interaksi != null) 'interaksi': interaksi,
      if (persepsi != null) 'persepsi': persepsi,
      if (prosesPikir != null) 'proses_pikir': prosesPikir,
      if (isiPikir != null) 'isi_pikir': isiPikir,
      if (tingkatKesadaran != null) 'tingkat_kesadaran': tingkatKesadaran,
      if (memori != null) 'memori': memori,
      if (tingkatKonsentrasi != null) 'tingkat_konsentrasi': tingkatKonsentrasi,
      if (orientasi != null) 'orientasi': orientasi,
      if (dayaTilikDiri != null) 'daya_tilik_diri': dayaTilikDiri,
      if (makanMandiri != null) 'makan_mandiri': makanMandiri,
      if (babBakMandiri != null) 'bab_bak_mandiri': babBakMandiri,
      if (mandiMandiri != null) 'mandi_mandiri': mandiMandiri,
      if (berpakaianMandiri != null) 'berpakaian_mandiri': berpakaianMandiri,
      if (istirahatTidurCukup != null) 'istirahat_tidur_cukup': istirahatTidurCukup,
      if (kebutuhanPersiapanPulangLainnya != null) 'kebutuhan_persiapan_pulang_lainnya': kebutuhanPersiapanPulangLainnya,
      if (mekanismeKoping != null) 'mekanisme_koping': mekanismeKoping,
      if (masalahPsikososial != null) 'masalah_psikososial': masalahPsikososial,
      if (diagnosaMedisLengkap != null) 'diagnosa_medis_lengkap': diagnosaMedisLengkap,
      if (terapiMedis != null) 'terapi_medis': terapiMedis,
    };
  }
}
