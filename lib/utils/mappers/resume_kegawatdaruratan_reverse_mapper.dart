class ResumeKegawatdaruratanReverseMapper {
  static Map<String, dynamic> reverse(Map<String, dynamic> data) {
    return {
      'identitas': {
        'nama_lengkap': data['nama_lengkap'],
        'umur': data['umur'],
        'jenis_kelamin': data['jenis_kelamin'],
        'alamat': data['alamat'],
        'tanggal_masuk': data['tanggal_masuk'],
      },
      'riwayat_keluhan': {
        'keluhan_utama': data['keluhan_utama'],
        'riwayat_penyakit_sekarang': data['riwayat_penyakit_sekarang'],
        'faktor_pencetus': data['faktor_pencetus'],
      },
      'pemeriksaan_fisik': {
        'keadaan_umum': data['keadaan_umum'],
        'tanda_vital': data['tanda_vital'],
        'pemeriksaan_lain': data['pemeriksaan_lain'],
      },
      'status_mental': {
        'kesadaran': data['kesadaran'],
        'orientasi': data['orientasi'],
        'bentuk_pemikiran': data['bentuk_pemikiran'],
        'isi_pemikiran': data['isi_pemikiran'],
        'persepsi': data['persepsi'],
      },
      'diagnosis': {
        'diagnosis_utama': data['diagnosis_utama'],
        'diagnosis_banding': data['diagnosis_banding'],
        'diagnosis_tambahan': data['diagnosis_tambahan'],
      },
      'tindakan': {
        'tindakan_medis': data['tindakan_medis'],
        'tindakan_keperawatan': data['tindakan_keperawatan'],
        'terapi_psikososial': data['terapi_psikososial'],
      },
      'implementasi': {
        'pelaksanaan_intervensi': data['pelaksanaan_intervensi'],
        'kolaborasi_tim': data['kolaborasi_tim'],
        'edukasi': data['edukasi'],
      },
      'evaluasi': {
        'respon_intervensi': data['respon_intervensi'],
        'perubahan_klinis': data['perubahan_klinis'],
        'tujuan_tercapai': data['tujuan_tercapai'],
        'hambatan_perawatan': data['hambatan_perawatan'],
      },
      'rencana_lanjut': {
        'rencana_medis': data['rencana_medis'],
        'rencana_keperawatan': data['rencana_keperawatan'],
        'rencana_pemantauan': data['rencana_pemantauan'],
      },
      'rencana_keluarga': {
        'keterlibatan_keluarga': data['keterlibatan_keluarga'],
        'edukasi_keluarga': data['edukasi_keluarga'],
        'dukungan_keluarga': data['dukungan_keluarga'],
      },
      'renpra': data['renpra_diagnosis'] != null ? {
        'diagnosis': data['renpra_diagnosis'],
        'intervensi': data['renpra_intervensi'] is List
            ? (data['renpra_intervensi'] as List).cast<int>()
            : data['renpra_intervensi'],
        'tujuan': data['renpra_tujuan'],
        'kriteria': data['renpra_kriteria'],
        'rasional': data['renpra_rasional'],
      } : null,
    };
  }
}
