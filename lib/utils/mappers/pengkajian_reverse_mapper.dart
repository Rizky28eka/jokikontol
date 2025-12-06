class PengkajianReverseMapper {
  static Map<String, dynamic> reverse(Map<String, dynamic> data) {
    return {
      // Section 1: Identitas Klien
      'nama_lengkap': data['nama_lengkap'],
      'umur': data['usia'], // usia -> umur mapping
      'jenis_kelamin': data['jenis_kelamin'],
      'tempat_lahir': data['tempat_lahir'],
      'tanggal_lahir': data['tanggal_lahir'],
      'agama': data['agama'],
      'suku': data['suku'],
      'pendidikan': data['pendidikan'],
      'pekerjaan': data['pekerjaan'],
      'alamat': data['alamat'],
      'no_rm': data['no_rm'],
      'tanggal_masuk': data['tanggal_masuk'],
      'diagnosa_medis': data['diagnosa_medis'],
      'status_perkawinan': data['status_perkawinan'],

      // Section 2: Riwayat Kehidupan  
      'riwayat_pendidikan': data['riwayat_pendidikan'],
      'riwayat_keluarga': data['riwayat_keluarga'],
      
      // Additional health history fields
      'keluhan_utama': data['keluhan_utama'],
      'riwayat_penyakit_sekarang': data['riwayat_penyakit_sekarang'],
      'riwayat_penyakit_dahulu': data['riwayat_penyakit_dahulu'],
      'riwayat_pengobatan': data['riwayat_pengobatan'],

      // Section 3: Riwayat Psikososial
      'hubungan_sosial': data['hubungan_sosial'],
      'dukungan_sosial': data['dukungan_sosial'],
      'stresor_psikososial': data['stresor_psikososial'],
      'konsep_diri': data['konsep_diri'], // Adding backend field
      'spiritual': data['spiritual'], // Adding backend field
      'fungsi_sosial': data['fungsi_sosial'],

      // Section 4: Riwayat Psikiatri
      'riwayat_gangguan_psikiatri': data['riwayat_gangguan_psikiatri'],

      // Section 5: Pemeriksaan Psikologis
      'kesadaran': data['tingkat_kesadaran'], // tingkat_kesadaran -> kesadaran mapping
      'orientasi': data['orientasi'],
      'penampilan': data['penampilan'],

      // Section 6: Fungsi Psikologis
      'mood': data['alam_perasaan'], // alam_perasaan -> mood mapping
      'afect': data['afek'], // afek -> afect mapping (for frontend compatibility)
      'alam_pikiran': data['alam_pikiran'],

      // Section 7: Fungsi Sosial
      'fungsi_sosial': data['fungsi_sosial'],

      // Section 8: Fungsi Spiritual
      'kepercayaan': data['kepercayaan'],
      'praktik_ibadah': data['praktik_ibadah'],

      // Section 9: Genogram
      'genogram_structure': data['genogram_structure'],
      'genogram_notes': data['genogram_notes'],

      // Section 10: Rencana Perawatan (Renpra)
      'diagnosis': data['diagnosis'],
      'intervensi': data['intervensi'],
      'tujuan': data['tujuan'],
      'kriteria': data['kriteria'],
      'rasional': data['rasional'],

      // Physical examination fields
      'tekanan_darah': data['tekanan_darah'],
      'nadi': data['nadi'],
      'suhu': data['suhu'],
      'pernapasan': data['pernapasan'],
      'tinggi_badan': data['tinggi_badan'],
      'berat_badan': data['berat_badan'],
      'pembicaraan': data['pembicaraan'],
      'aktivitas_motorik': data['aktivitas_motorik'],
      'alam_perasaan': data['alam_perasaan'],
      'interaksi': data['interaksi'],
      'persepsi': data['persepsi'],
      'proses_pikir': data['proses_pikir'],
      'isi_pikir': data['isi_pikir'],
      'memori': data['memori'],
      'tingkat_konsentrasi': data['tingkat_konsentrasi'],
      'daya_tilik_diri': data['daya_tilik_diri'],

      // Discharge planning fields
      'makan_mandiri': data['makan_mandiri'],
      'bab_bak_mandiri': data['bab_bak_mandiri'],
      'mandi_mandiri': data['mandi_mandiri'],
      'berpakaian_mandiri': data['berpakaian_mandiri'],
      'istirahat_tidur_cukup': data['istirahat_tidur_cukup'],
      'kebutuhan_persiapan_pulang_lainnya': data['kebutuhan_persiapan_pulang_lainnya'],

      // Coping and psychosocial fields
      'mekanisme_koping': data['mekanisme_koping'],
      'masalah_psikososial': data['masalah_psikososial'],

      // Medical aspects
      'diagnosa_medis_lengkap': data['diagnosa_medis_lengkap'],
      'terapi_medis': data['terapi_medis'],

      // Section 11: Penutup
      'catatan_tambahan': data['catatan_tambahan'],
      'tanggal_pengisian': data['tanggal_pengisian'],
    };
  }
}