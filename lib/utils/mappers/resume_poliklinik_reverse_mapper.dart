class ResumePoliklinikReverseMapper {
  static Map<String, dynamic> reverse(Map<String, dynamic> data) {
    return {
      'section_1': {
        'nama_lengkap': data['nama_lengkap'],
        'umur': data['umur'],
        'jenis_kelamin': data['jenis_kelamin'],
        'status_perkawinan': data['status_perkawinan'],
      },
      'section_2': {
        'riwayat_pendidikan': data['riwayat_pendidikan'],
        'pekerjaan': data['pekerjaan'],
        'riwayat_keluarga': data['riwayat_keluarga'],
      },
      'section_3': {
        'hubungan_sosial': data['hubungan_sosial'],
        'dukungan_sosial': data['dukungan_sosial'],
        'stresor_psikososial': data['stresor_psikososial'],
      },
      'section_4': {
        'riwayat_gangguan_psikiatri': data['riwayat_gangguan_psikiatri'],
        'riwayat_pengobatan': data['riwayat_pengobatan'],
      },
      'section_5': {
        'kesadaran': data['kesadaran'],
        'orientasi': data['orientasi'],
        'penampilan': data['penampilan'],
      },
      'section_6': {
        'mood': data['mood'],
        'afect': data['afect'],
        'alam_pikiran': data['alam_pikiran'],
      },
      'section_7': {
        'fungsi_sosial': data['fungsi_sosial'],
        'interaksi_sosial': data['interaksi_sosial'],
      },
      'section_8': {
        'kepercayaan': data['kepercayaan'],
        'praktik_ibadah': data['praktik_ibadah'],
      },
      'section_9': data['diagnosis'] != null ? {
        'diagnosis': data['diagnosis'],
        'intervensi': data['intervensi'] is List
            ? (data['intervensi'] as List).cast<int>()
            : data['intervensi'],
        'tujuan': data['tujuan'],
        'kriteria': data['kriteria'],
        'rasional': data['rasional'],
      } : null,
      'section_10': {
        'catatan_tambahan': data['catatan_tambahan'],
        'tanggal_pengisian': data['tanggal_pengisian'],
      },
    };
  }
}
