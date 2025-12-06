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

    // Get renpra data if available
    final renpra = data['renpra'] ?? data['care_plan'] ?? {};

    return {
      // Section 1: Identitas Klien
      'nama_lengkap': data['nama_pasien'] ?? data['nama_lengkap'],
      'umur': data['umur'],
      'jenis_kelamin': normalizeGender(data['jenis_kelamin']),
      'status_perkawinan': normalizeStatusPerkawinan(data['status_perkawinan']),

      // Section 2: Riwayat Kehidupan
      'riwayat_pendidikan': data['riwayat_pendidikan'],
      'pekerjaan': data['pekerjaan'],
      'riwayat_keluarga': data['riwayat_keluarga'],

      // Section 3: Riwayat Psikososial
      'hubungan_sosial': data['hubungan_sosial'],
      'dukungan_sosial': data['dukungan_sosial'],
      'stresor_psikososial': data['stresor_psikososial'],

      // Section 4: Riwayat Psikiatri
      'riwayat_gangguan_psikiatri': data['riwayat_gangguan_psikiatri'],
      'riwayat_pengobatan': data['riwayat_pengobatan'],

      // Section 5: Pemeriksaan Psikologis
      'kesadaran': data['kesadaran'],
      'orientasi': data['orientasi'],
      'penampilan': data['penampilan'],

      // Section 6: Fungsi Psikologis  
      'mood': data['mood_afek']?.split(' ')?.first, // Extract mood from combined field
      'afect': data['mood_afek']?.split(' ')?.last, // Extract afect from combined field
      'alam_pikiran': data['pikiran'], // Mapping from backend field

      // Section 7: Fungsi Sosial
      'fungsi_sosial': data['fungsi_sosial'],
      'interaksi_sosial': data['interaksi_sosial'],

      // Section 8: Fungsi Spiritual
      'kepercayaan': data['kepercayaan'],
      'praktik_ibadah': data['praktik_ibadah'],

      // Section 9: Rencana Perawatan (Renpra)
      'diagnosis': parseId(renpra['diagnosis'] ?? data['renpra_diagnosis'] ?? data['diagnosis']),
      'intervensi': parseIdList(renpra['intervensi'] ?? data['renpra_intervensi'] ?? data['intervensi']),
      'tujuan': renpra['tujuan'] ?? data['renpra_tujuan'] ?? data['tujuan'],
      'kriteria': renpra['kriteria'] ?? data['renpra_kriteria'] ?? data['kriteria'],
      'rasional': renpra['rasional'] ?? data['renpra_rasional'] ?? data['rasional'],

      // Section 10: Penutup
      'catatan_tambahan': data['catatan_tambahan'],
      'tanggal_pengisian': parseDate(data['tanggal_pengisian']),

      // Additional fields from backend
      'no_rm': data['no_rm'],
      'tanggal_kunjungan': parseDate(data['tanggal_kunjungan']),
      'poliklinik': data['poliklinik'],
      'keluhan_utama': data['keluhan_utama'],
      'riwayat_penyakit_sekarang': data['riwayat_penyakit_sekarang'],
      'riwayat_penyakit_dahulu': data['riwayat_penyakit_dahulu'],
      'riwayat_alergi': data['riwayat_alergi'],
      'tekanan_darah': data['tekanan_darah'],
      'nadi': data['nadi'],
      'suhu': data['suhu'],
      'pernapasan': data['pernapasan'],
      'berat_badan': data['berat_badan'],
      'tinggi_badan': data['tinggi_badan'],
      'perilaku': data['perilaku'],
      'terapi_farmakologi': data['terapi_farmakologi'],
      'terapi_non_farmakologi': data['terapi_non_farmakologi'],
      'edukasi': data['edukasi'],
      'tanggal_kontrol_berikutnya': parseDate(data['tanggal_kontrol_berikutnya']),
      'rencana_tindak_lanjut': data['rencana_tindak_lanjut'],
    };
  }
}