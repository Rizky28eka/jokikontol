class ResumePoliklinikMapper {
  static Map<String, dynamic> map(Map<String, dynamic> formData) {
    return {
      'section_1': {
        'nama_lengkap': formData['nama_lengkap'],
        'umur': formData['umur'],
        'jenis_kelamin': formData['jenis_kelamin'],
        'status_perkawinan': formData['status_perkawinan'],
      },
      'section_2': {
        'riwayat_pendidikan': formData['riwayat_pendidikan'],
        'pekerjaan': formData['pekerjaan'],
        'riwayat_keluarga': formData['riwayat_keluarga'],
      },
      'section_3': {
        'hubungan_sosial': formData['hubungan_sosial'],
        'dukungan_sosial': formData['dukungan_sosial'],
        'stresor_psikososial': formData['stresor_psikososial'],
      },
      'section_4': {
        'riwayat_gangguan_psikiatri': formData['riwayat_gangguan_psikiatri'],
        'riwayat_pengobatan': formData['riwayat_pengobatan'],
      },
      'section_5': {
        'kesadaran': formData['kesadaran'],
        'orientasi': formData['orientasi'],
        'penampilan': formData['penampilan'],
      },
      'section_6': {
        'mood': formData['mood'],
        'afect': formData['afect'],
        'alam_pikiran': formData['alam_pikiran'],
      },
      'section_7': {
        'fungsi_sosial': formData['fungsi_sosial'],
        'interaksi_sosial': formData['interaksi_sosial'],
      },
      'section_8': {
        'kepercayaan': formData['kepercayaan'],
        'praktik_ibadah': formData['praktik_ibadah'],
      },
      'section_9': formData['diagnosis'] != null
          ? {
              'diagnosis': formData['diagnosis'],
              'intervensi': formData['intervensi'],
              'tujuan': formData['tujuan'],
              'kriteria': formData['kriteria'],
              'rasional': formData['rasional'],
            }
          : null,
      'section_10': {
        'catatan_tambahan': formData['catatan_tambahan'],
        'tanggal_pengisian': formData['tanggal_pengisian'],
      },
      // flat mirror for BE compatibility
      'nama_lengkap': formData['nama_lengkap'],
      'umur': formData['umur'],
      'jenis_kelamin': formData['jenis_kelamin'],
      'status_perkawinan': formData['status_perkawinan'],
      'riwayat_pendidikan': formData['riwayat_pendidikan'],
      'pekerjaan': formData['pekerjaan'],
      'riwayat_keluarga': formData['riwayat_keluarga'],
      'hubungan_sosial': formData['hubungan_sosial'],
      'dukungan_sosial': formData['dukungan_sosial'],
      'stresor_psikososial': formData['stresor_psikososial'],
      'riwayat_gangguan_psikiatri': formData['riwayat_gangguan_psikiatri'],
      'riwayat_pengobatan': formData['riwayat_pengobatan'],
      'kesadaran': formData['kesadaran'],
      'orientasi': formData['orientasi'],
      'penampilan': formData['penampilan'],
      'mood': formData['mood'],
      'afect': formData['afect'],
      'alam_pikiran': formData['alam_pikiran'],
      'fungsi_sosial': formData['fungsi_sosial'],
      'interaksi_sosial': formData['interaksi_sosial'],
      'kepercayaan': formData['kepercayaan'],
      'praktik_ibadah': formData['praktik_ibadah'],
      'diagnosis': formData['diagnosis'],
      'intervensi': formData['intervensi'],
      'tujuan': formData['tujuan'],
      'kriteria': formData['kriteria'],
      'rasional': formData['rasional'],
      'catatan_tambahan': formData['catatan_tambahan'],
      'tanggal_pengisian': formData['tanggal_pengisian'],
    };
  }
}
