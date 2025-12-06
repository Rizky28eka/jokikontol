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

    final identitas = data['identitas'] ?? data;
    final tujuan = data['tujuan'] ?? data;
    final materiDanMetode = data['materi_dan_metode'] ?? data;
    final pengorganisasian = data['pengorganisasian'] ?? data;
    final evaluasi = data['evaluasi'] ?? data;
    final feedback = data['feedback'] ?? data;
    final renpra = data['renpra'] ?? {};

    return {
      'topik': identitas['topik'] ?? data['topik'],
      'sub_topik': identitas['sub_topik'] ?? data['sub_topik'],
      'sasaran': identitas['sasaran'] ?? data['sasaran'],
      'tanggal_pelaksanaan': identitas['tanggal_pelaksanaan'] ?? data['tanggal_pelaksanaan'],
      'waktu_pelaksanaan': identitas['waktu'] ?? identitas['waktu_pelaksanaan'] ?? data['waktu_pelaksanaan'],
      'tempat': identitas['tempat'] ?? data['tempat'],
      'durasi': identitas['durasi'] ?? data['durasi'],
      'tujuan_umum': tujuan['umum'] ?? data['tujuan_umum'],
      'tujuan_khusus': tujuan['khusus'] ?? data['tujuan_khusus'],
      'materi': materiDanMetode['materi'] ?? data['materi'] ?? data['materi_penyuluhan'],
      'metode': joinListToString(materiDanMetode['metode'] ?? data['metode']),
      'media': joinListToString(materiDanMetode['media'] ?? data['media']),
      'joblist_roles': parseStringList(data['joblist']?['roles'] ?? data['joblist_roles']),
      'penyuluh': pengorganisasian['penyuluh'] ?? data['penyuluh'],
      'moderator': pengorganisasian['moderator'] ?? data['moderator'],
      'fasilitator': pengorganisasian['fasilitator'] ?? data['fasilitator'],
      'time_keeper': pengorganisasian['time_keeper'] ?? data['time_keeper'],
      'dokumentator': pengorganisasian['dokumentator'] ?? data['dokumentator'],
      'observer': pengorganisasian['observer'] ?? data['observer'],
      'tabel_kegiatan': data['tabel_kegiatan'] ?? [],
      'evaluasi_input': evaluasi['input'] ?? data['evaluasi_struktur'],
      'evaluasi_proses': evaluasi['proses'] ?? data['evaluasi_proses'],
      'evaluasi_hasil': evaluasi['hasil'] ?? data['evaluasi_hasil'],
      'pertanyaan': feedback['pertanyaan'] ?? data['pertanyaan'],
      'saran': feedback['saran'] ?? data['saran'],
      'diagnosis': parseId(renpra['diagnosis'] ?? data['renpra_diagnosis']),
      'intervensi': parseIdList(renpra['intervensi'] ?? data['renpra_intervensi']),
      'tujuan': renpra['tujuan'] ?? data['renpra_tujuan'],
      'kriteria': renpra['kriteria'] ?? data['renpra_kriteria'],
      'rasional': renpra['rasional'] ?? data['renpra_rasional'],
    };
  }
}
