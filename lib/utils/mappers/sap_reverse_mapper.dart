class SapReverseMapper {
  static Map<String, dynamic> reverse(Map<String, dynamic> data) {
    return {
      'identitas': {
        'topik': data['topik'],
        'sasaran': data['sasaran'],
        'waktu': data['waktu_pelaksanaan'] ?? data['waktu'],
        'tempat': data['tempat'],
      },
      'tujuan': {
        'umum': data['tujuan_umum'],
        'khusus': data['tujuan_khusus'],
      },
      'materi_dan_metode': {
        'materi': data['materi_penyuluhan'] ?? data['materi'],
        'metode': data['metode'],
      },
      'joblist': {
        'roles': data['joblist_roles'] ?? []
      },
      'pengorganisasian': {
        'penyuluh': data['penyuluh'],
        'moderator': data['moderator'],
        'fasilitator': data['fasilitator'],
        'time_keeper': data['time_keeper'],
        'dokumentator': data['dokumentator'],
        'observer': data['observer'],
      },
      'tabel_kegiatan': data['kegiatan'] ?? [],
      'evaluasi': {
        'input': data['evaluasi_struktur'] ?? data['evaluasi_input'],
        'proses': data['evaluasi_proses'],
        'hasil': data['evaluasi_hasil'],
      },
      'feedback': {
        'pertanyaan': data['pertanyaan'],
        'saran': data['saran'],
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
