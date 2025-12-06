class SapReverseMapper {
  static Map<String, dynamic> reverse(Map<String, dynamic> data) {
    List<String> parseStringList(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      return <String>[];
    }

    String? joinListToString(dynamic value) {
      if (value is List) return value.whereType<Object>().map((e) => e.toString()).join(', ');
      if (value is String) return value;
      return null;
    }

    int? parseId(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is double) return value.toInt();
      return null;
    }

    List<int> parseIdList(dynamic value) {
      if (value is List) {
        return value
            .map((v) => v is int ? v : (v is String ? int.tryParse(v) : null))
            .whereType<int>()
            .toList();
      }
      return <int>[];
    }

    // Get renpra data from the response
    final renpra = data['renpra'] ?? data['care_plan'] ?? {};

    return {
      // Identitas SAP
      'topik': data['topik'] ?? data['identitas']?['topik'],
      'sub_topik': data['sub_topik'] ?? data['identitas']?['sub_topik'],
      'sasaran': data['sasaran'] ?? data['identitas']?['sasaran'],
      'tanggal_pelaksanaan': data['tanggal_pelaksanaan'] ?? data['identitas']?['tanggal_pelaksanaan'],
      'waktu_pelaksanaan': data['waktu_pelaksanaan'] ?? data['identitas']?['waktu_pelaksanaan'] ?? data['identitas']?['waktu'],
      'tempat': data['tempat'] ?? data['identitas']?['tempat'],
      'durasi': data['durasi'] ?? data['identitas']?['durasi'],

      // Tujuan
      'tujuan_umum': data['tujuan_umum'] ?? data['tujuan']?['umum'],
      'tujuan_khusus': data['tujuan_khusus'] ?? data['tujuan']?['khusus'],

      // Materi
      'materi': data['materi_penyuluhan'] ?? data['materi'] ?? data['materi_dan_metode']?['materi'],

      // Metode & Media - convert array to string for frontend
      'metode': joinListToString(data['metode'] ?? data['materi_dan_metode']?['metode']),
      'media': joinListToString(data['media'] ?? data['materi_dan_metode']?['media']),

      // Joblist roles
      'joblist_roles': parseStringList(data['joblist']?['roles'] ?? data['joblist_roles']),

      // Pengorganisasian
      'penyuluh': data['penyuluh'] ?? data['pengorganisasian']?['penyuluh'],
      'moderator': data['moderator'] ?? data['pengorganisasian']?['moderator'],
      'fasilitator': data['fasilitator'] ?? data['pengorganisasian']?['fasilitator'],
      'time_keeper': data['time_keeper'] ?? data['pengorganisasian']?['time_keeper'],
      'dokumentator': data['dokumentator'] ?? data['pengorganisasian']?['dokumentator'],
      'observer': data['observer'] ?? data['pengorganisasian']?['observer'],

      // Kegiatan Penyuluhan
      'tabel_kegiatan': data['kegiatan'] ?? data['tabel_kegiatan'] ?? [],

      // Evaluasi
      'evaluasi_input': data['evaluasi_struktur'] ?? data['evaluasi']?['input'],
      'evaluasi_proses': data['evaluasi_proses'] ?? data['evaluasi']?['proses'],
      'evaluasi_hasil': data['evaluasi_hasil'] ?? data['evaluasi']?['hasil'],

      // Feedback
      'pertanyaan': data['pertanyaan'] ?? data['feedback']?['pertanyaan'],
      'saran': data['saran'] ?? data['feedback']?['saran'],

      // Renpra - nursing care plan
      'diagnosis': parseId(renpra['diagnosis'] ?? data['renpra_diagnosis'] ?? data['diagnosis']),
      'intervensi': parseIdList(renpra['intervensi'] ?? data['renpra_intervensi'] ?? data['intervensi']),
      'tujuan': renpra['tujuan'] ?? data['renpra_tujuan'] ?? data['tujuan_renpra'] ?? data['tujuan'],
      'kriteria': renpra['kriteria'] ?? data['renpra_kriteria'] ?? data['kriteria'],
      'rasional': renpra['rasional'] ?? data['renpra_rasional'] ?? data['rasional'],
    };
  }
}