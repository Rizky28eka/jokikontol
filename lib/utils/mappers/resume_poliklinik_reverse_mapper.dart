class ResumePoliklinikReverseMapper {
  static Map<String, dynamic> reverse(Map<String, dynamic> data) {
    DateTime? parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    String? normalizeGender(dynamic value) {
      if (value == null) return null;
      final s = value.toString().toLowerCase();
      if (s == 'l' || s.contains('laki')) return 'L';
      if (s == 'p' || s.contains('perem')) return 'P';
      return 'P';
    }

    String? normalizeStatusPerkawinan(dynamic value) {
      if (value == null) return null;
      final s = value.toString().toLowerCase();
      if (s.contains('belum')) return 'belum_kawin';
      if (s.contains('menikah')) return 'menikah';
      if (s.contains('cerai')) return 'cerai';
      if (s.contains('duda')) return 'duda';
      if (s.contains('janda')) return 'janda';
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

    final s1 = data['section_1'] ?? data;
    final s2 = data['section_2'] ?? data;
    final s3 = data['section_3'] ?? data;
    final s4 = data['section_4'] ?? data;
    final s5 = data['section_5'] ?? data;
    final s6 = data['section_6'] ?? data;
    final s7 = data['section_7'] ?? data;
    final s8 = data['section_8'] ?? data;
    final s9 = data['section_9'] ?? data;
    final s10 = data['section_10'] ?? data;

    return {
      'nama_lengkap': s1['nama_lengkap'],
      'umur': s1['umur']?.toString(),
      'jenis_kelamin': normalizeGender(s1['jenis_kelamin']),
      'status_perkawinan': normalizeStatusPerkawinan(s1['status_perkawinan']),
      'riwayat_pendidikan': s2['riwayat_pendidikan'],
      'pekerjaan': s2['pekerjaan'],
      'riwayat_keluarga': s2['riwayat_keluarga'],
      'hubungan_sosial': s3['hubungan_sosial'],
      'dukungan_sosial': s3['dukungan_sosial'],
      'stresor_psikososial': s3['stresor_psikososial'],
      'riwayat_gangguan_psikiatri': s4['riwayat_gangguan_psikiatri'],
      'riwayat_pengobatan': s4['riwayat_pengobatan'],
      'kesadaran': s5['kesadaran'],
      'orientasi': s5['orientasi'],
      'penampilan': s5['penampilan'],
      'mood': s6['mood'],
      'afect': s6['afect'],
      'alam_pikiran': s6['alam_pikiran'],
      'fungsi_sosial': s7['fungsi_sosial'],
      'interaksi_sosial': s7['interaksi_sosial'],
      'kepercayaan': s8['kepercayaan'],
      'praktik_ibadah': s8['praktik_ibadah'],
      'diagnosis': parseId(s9['diagnosis']),
      'intervensi': parseIdList(s9['intervensi']),
      'tujuan': s9['tujuan'],
      'kriteria': s9['kriteria'],
      'rasional': s9['rasional'],
      'catatan_tambahan': s10['catatan_tambahan'],
      'tanggal_pengisian': parseDate(s10['tanggal_pengisian']),
    };
  }
}
