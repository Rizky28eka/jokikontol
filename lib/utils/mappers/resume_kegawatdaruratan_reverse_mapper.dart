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

    final identitas = data['identitas'] ?? data;
    final riwayatKeluhan = data['riwayat_keluhan'] ?? data;
    final pemeriksaanFisik = data['pemeriksaan_fisik'] ?? data;
    final statusMental = data['status_mental'] ?? data;
    final diagnosis = data['diagnosis'] ?? data;
    final tindakan = data['tindakan'] ?? data;
    final implementasi = data['implementasi'] ?? data;
    final evaluasi = data['evaluasi'] ?? data;
    final rencanaLanjut = data['rencana_lanjut'] ?? data;
    final rencanaKeluarga = data['rencana_keluarga'] ?? data;
    final renpra = data['renpra'] ?? {};

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

    final renpraDiagnosis = parseId(renpra['diagnosis'] ?? data['renpra_diagnosis']);
    final renpraIntervensi = renpra['intervensi'] ?? data['renpra_intervensi'];
    final renpraTujuan = renpra['tujuan'] ?? data['renpra_tujuan'];
    final renpraKriteria = renpra['kriteria'] ?? data['renpra_kriteria'];
    final renpraRasional = renpra['rasional'] ?? data['renpra_rasional'];
    final renpraEvaluasi = renpra['evaluasi'] ?? data['renpra_evaluasi'];

    return {
      // Section 1: Identitas
      'nama_lengkap': identitas['nama_lengkap'],
      'umur': identitas['umur']?.toString(),
      'jenis_kelamin': normalizeGender(identitas['jenis_kelamin']),
      'alamat': identitas['alamat'],
      'tanggal_masuk': parseDate(identitas['tanggal_masuk']),
      // Section 2: Riwayat Keluhan
      'keluhan_utama': riwayatKeluhan['keluhan_utama'],
      'riwayat_penyakit_sekarang': riwayatKeluhan['riwayat_penyakit_sekarang'],
      'faktor_pencetus': riwayatKeluhan['faktor_pencetus'],
      // Section 3: Pemeriksaan Fisik
      'keadaan_umum': pemeriksaanFisik['keadaan_umum'],
      'tanda_vital': pemeriksaanFisik['tanda_vital'],
      'pemeriksaan_lain': pemeriksaanFisik['pemeriksaan_lain'],
      // Section 4: Status Mental
      'kesadaran': statusMental['kesadaran'],
      'orientasi': statusMental['orientasi'],
      'bentuk_pemikiran': statusMental['bentuk_pemikiran'],
      'isi_pemikiran': statusMental['isi_pemikiran'],
      'persepsi': statusMental['persepsi'],
      // Section 5: Diagnosis
      'diagnosis_utama': diagnosis['diagnosis_utama'],
      'diagnosis_banding': diagnosis['diagnosis_banding'],
      'diagnosis_tambahan': diagnosis['diagnosis_tambahan'],
      // Section 6: Tindakan
      'tindakan_medis': tindakan['tindakan_medis'],
      'tindakan_keperawatan': tindakan['tindakan_keperawatan'],
      'terapi_psikososial': tindakan['terapi_psikososial'],
      // Section 7: Implementasi
      'pelaksanaan_intervensi': implementasi['pelaksanaan_intervensi'],
      'kolaborasi_tim': implementasi['kolaborasi_tim'],
      'edukasi': implementasi['edukasi'],
      // Section 8: Evaluasi
      'respon_intervensi': evaluasi['respon_intervensi'],
      'perubahan_klinis': evaluasi['perubahan_klinis'],
      'tujuan_tercapai': evaluasi['tujuan_tercapai'],
      'hambatan_perawatan': evaluasi['hambatan_perawatan'],
      // Section 9: Rencana Lanjut
      'rencana_medis': rencanaLanjut['rencana_medis'],
      'rencana_keperawatan': rencanaLanjut['rencana_keperawatan'],
      'rencana_pemantauan': rencanaLanjut['rencana_pemantauan'],
      // Section 10: Rencana Keluarga
      'keterlibatan_keluarga': rencanaKeluarga['keterlibatan_keluarga'],
      'edukasi_keluarga': rencanaKeluarga['edukasi_keluarga'],
      'dukungan_keluarga': rencanaKeluarga['dukungan_keluarga'],
      // Section 11: Renpra
      'diagnosis': renpraDiagnosis,
      'intervensi': parseIntervensi(renpraIntervensi),
      'tujuan': renpraTujuan,
      'kriteria': renpraKriteria,
      'rasional': renpraRasional,
      'evaluasi_renpra': renpraEvaluasi,
    };
  }
}
