class ResumeKegawatdaruratanReverseMapper {
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
      if (s.startsWith('o') || s.contains('lain')) return 'O';
      return 'O';
    }

    int? parseId(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is double) return value.toInt();
      return null;
    }

    List<int> parseIntervensi(dynamic value) {
      if (value is List) {
        return value
            .map((v) => v is int ? v : (v is String ? int.tryParse(v) : null))
            .whereType<int>()
            .toList();
      }
      return [];
    }

    return {
      // Section 1: Identitas
      'nama_lengkap': data['nama_pasien'], // name mapping
      'umur': data['umur'], // might not be in backend, but kept for compatibility
      'jenis_kelamin': data['jenis_kelamin'], // might not be in backend, but kept for compatibility
      'alamat': data['alamat'], // might not be in backend, but kept for compatibility
      'no_rm': data['no_rm'],
      'tanggal_masuk': parseDate(data['tanggal_masuk']),
      'jam_masuk': data['jam_masuk'],
      'tanggal_keluar': parseDate(data['tanggal_keluar']),
      'jam_keluar': data['jam_keluar'],

      // Section 2: Riwayat Keluhan
      'keluhan_utama': data['keluhan_utama'],
      'riwayat_penyakit_sekarang': data['riwayat_penyakit_sekarang'],
      'riwayat_penyakit_dahulu': data['riwayat_penyakit_dahulu'],
      'riwayat_pengobatan': data['riwayat_pengobatan'],
      'faktor_pencetus': data['faktor_pencetus'],

      // Section 3: Pemeriksaan Fisik
      'keadaan_umum': data['keadaan_umum'],
      'tanda_vital': data['tanda_vital'],
      'pemeriksaan_lain': data['pemeriksaan_lain'],
      'kesadaran': data['kesadaran'],
      'gcs': data['gcs'],
      'tekanan_darah': data['tekanan_darah'],
      'nadi': data['nadi'],
      'suhu': data['suhu'],
      'pernapasan': data['pernapasan'],
      'spo2': data['spo2'],

      // Section 4: Status Mental
      'kesadaran': data['kesadaran'],
      'orientasi': data['orientasi'],
      'bentuk_pemikiran': data['bentuk_pemikiran'],
      'isi_pemikiran': data['isi_pemikiran'],
      'persepsi': data['persepsi'],
      'penampilan': data['penampilan'],
      'perilaku': data['perilaku'],
      'pembicaraan': data['pembicaraan'],
      'mood_afek': data['mood_afek'],
      'pikiran': data['pikiran'],
      'kognitif': data['kognitif'],

      // Section 5: Diagnosis
      'diagnosis_utama': data['diagnosis_kerja'], // name mapping
      'diagnosis_banding': data['diagnosis_banding'],
      'diagnosis_tambahan': data['diagnosis_tambahan'],

      // Section 6: Tindakan
      'tindakan_medis': data['tindakan_yang_dilakukan'], // name mapping
      'tindakan_keperawatan': data['tindakan_keperawatan'],
      'terapi_psikososial': data['terapi_psikososial'],
      'terapi_obat': data['terapi_obat'],

      // Section 7: Implementasi
      'pelaksanaan_intervensi': data['pelaksanaan_intervensi'],
      'kolaborasi_tim': data['kolaborasi_tim'],
      'edukasi': data['edukasi'],

      // Section 8: Evaluasi
      'respon_intervensi': data['respon_intervensi'],
      'perubahan_klinis': data['perubahan_klinis'],
      'tujuan_tercapai': data['tujuan_tercapai'],
      'hambatan_perawatan': data['hambatan_perawatan'],

      // Section 9: Rencana Lanjut
      'rencana_medis': data['anjuran'], // name mapping
      'rencana_keperawatan': data['rencana_keperawatan'],
      'rencana_pemantauan': data['rencana_pemantauan'],

      // Section 10: Rencana dengan Keluarga
      'keterlibatan_keluarga': data['keterlibatan_keluarga'],
      'edukasi_keluarga': data['edukasi_keluarga'],
      'dukungan_keluarga': data['dukungan_keluarga'],

      // Section 11: Renpra
      'diagnosis': parseId(data['diagnosis']),
      'intervensi': parseIntervensi(data['intervensi']),
      'tujuan': data['tujuan'],
      'kriteria': data['kriteria'],
      'rasional': data['rasional'],
      'evaluasi_renpra': data['evaluasi_renpra'],
    };
  }
}