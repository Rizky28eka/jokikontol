class SapMapper {
  static Map<String, dynamic> map(Map<String, dynamic> formData) {
    List<String> toStringList(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) {
        return value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [];
    }

    final metodeList = toStringList(formData['metode']);
    final mediaList = toStringList(formData['media']);

    return {
      'identitas': {
        'topik': formData['topik'],
        'sub_topik': formData['sub_topik'],
        'sasaran': formData['sasaran'],
        'tanggal_pelaksanaan': formData['tanggal_pelaksanaan'],
        'waktu': formData['waktu_pelaksanaan'],
        'tempat': formData['tempat'],
        'durasi': formData['durasi'],
      },
      'tujuan': {
        'umum': formData['tujuan_umum'],
        'khusus': formData['tujuan_khusus'],
      },
      'materi_dan_metode': {
        'materi': formData['materi'],
        'metode': metodeList,
        'media': mediaList,
      },
      'joblist': {'roles': formData['joblist_roles'] ?? []},
      'pengorganisasian': {
        'penyuluh': formData['penyuluh'],
        'moderator': formData['moderator'],
        'fasilitator': formData['fasilitator'],
        'time_keeper': formData['time_keeper'],
        'dokumentator': formData['dokumentator'],
        'observer': formData['observer'],
      },
      'tabel_kegiatan': formData['tabel_kegiatan'] ?? [],
      'evaluasi': {
        'input': formData['evaluasi_input'],
        'proses': formData['evaluasi_proses'],
        'hasil': formData['evaluasi_hasil'],
      },
      'feedback': {
        'pertanyaan': formData['pertanyaan'],
        'saran': formData['saran'],
      },
      'renpra': formData['diagnosis'] != null
          ? {
              'diagnosis': formData['diagnosis'],
              'intervensi': formData['intervensi'],
              'tujuan': formData['tujuan'],
              'kriteria': formData['kriteria'],
              'rasional': formData['rasional'],
              'evaluasi': formData['evaluasi_renpra'],
            }
          : null,
    };
  }
}
