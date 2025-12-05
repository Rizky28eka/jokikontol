class SapMapper {
  static Map<String, dynamic> map(Map<String, dynamic> data) {
    final result = <String, dynamic>{};

    if (data['topik'] != null) result['topik'] = data['topik'];
    if (data['sub_topik'] != null) result['sub_topik'] = data['sub_topik'];
    if (data['sasaran'] != null) result['sasaran'] = data['sasaran'];
    if (data['tanggal_pelaksanaan'] != null)
      result['tanggal_pelaksanaan'] = data['tanggal_pelaksanaan'];

    if (data['waktu'] != null && data['waktu_pelaksanaan'] == null) {
      result['waktu_pelaksanaan'] = data['waktu'];
    } else if (data['waktu_pelaksanaan'] != null) {
      result['waktu_pelaksanaan'] = data['waktu_pelaksanaan'];
    }

    if (data['tempat'] != null) result['tempat'] = data['tempat'];
    if (data['durasi'] != null) result['durasi'] = data['durasi'];

    final tujuan = data['tujuan'] ?? {};
    if (tujuan is Map && tujuan['umum'] != null) {
      result['tujuan_umum'] = tujuan['umum'];
    } else if (data['tujuan_umum'] != null) {
      result['tujuan_umum'] = data['tujuan_umum'];
    }

    if (tujuan is Map && tujuan['khusus'] != null) {
      result['tujuan_khusus'] = tujuan['khusus'];
    } else if (data['tujuan_khusus'] != null) {
      result['tujuan_khusus'] = data['tujuan_khusus'];
    }

    final materiDanMetode = data['materi_dan_metode'] ?? {};
    if (materiDanMetode is Map && materiDanMetode['materi'] != null) {
      result['materi_penyuluhan'] = materiDanMetode['materi'];
    } else if (data['materi'] != null) {
      result['materi_penyuluhan'] = data['materi'];
    }

    if (materiDanMetode is Map && materiDanMetode['metode'] != null) {
      final metode = materiDanMetode['metode'];
      result['metode'] = metode is List ? metode : [metode];
    } else if (data['metode'] != null) {
      final metode = data['metode'];
      result['metode'] = metode is List ? metode : [metode];
    }

    if (data['media'] != null) {
      final media = data['media'];
      result['media'] = media is List ? media : [media];
    }

    final tabelKegiatan = data['tabel_kegiatan'] ?? [];
    final kegiatan = data['kegiatan'] ?? tabelKegiatan;
    if (kegiatan is List && kegiatan.isNotEmpty) {
      result['kegiatan'] = kegiatan;
    } else if (kegiatan is List) {
      result['kegiatan'] = [];
    }

    final evaluasi = data['evaluasi'] ?? {};
    if (evaluasi is Map && evaluasi['input'] != null) {
      result['evaluasi_struktur'] = evaluasi['input'];
    } else if (data['evaluasi_struktur'] != null) {
      result['evaluasi_struktur'] = data['evaluasi_struktur'];
    } else if (data['input'] != null) {
      result['evaluasi_struktur'] = data['input'];
    }

    if (evaluasi is Map && evaluasi['proses'] != null) {
      result['evaluasi_proses'] = evaluasi['proses'];
    } else if (data['evaluasi_proses'] != null) {
      result['evaluasi_proses'] = data['evaluasi_proses'];
    } else if (data['proses'] != null) {
      result['evaluasi_proses'] = data['proses'];
    }

    if (evaluasi is Map && evaluasi['hasil'] != null) {
      result['evaluasi_hasil'] = evaluasi['hasil'];
    } else if (data['evaluasi_hasil'] != null) {
      result['evaluasi_hasil'] = data['evaluasi_hasil'];
    } else if (data['hasil'] != null) {
      result['evaluasi_hasil'] = data['hasil'];
    }

    final pengorganisasian = data['pengorganisasian'] ?? {};
    if (pengorganisasian is Map) {
      if (pengorganisasian['penyuluh'] != null)
        result['penyuluh'] = pengorganisasian['penyuluh'];
      if (pengorganisasian['moderator'] != null)
        result['moderator'] = pengorganisasian['moderator'];
      if (pengorganisasian['fasilitator'] != null)
        result['fasilitator'] = pengorganisasian['fasilitator'];
      if (pengorganisasian['time_keeper'] != null)
        result['time_keeper'] = pengorganisasian['time_keeper'];
      if (pengorganisasian['dokumentator'] != null)
        result['dokumentator'] = pengorganisasian['dokumentator'];
      if (pengorganisasian['observer'] != null)
        result['observer'] = pengorganisasian['observer'];
    }

    final renpra = data['renpra'] ?? {};
    if (renpra is Map) {
      if (renpra['diagnosis'] != null)
        result['renpra_diagnosis'] = renpra['diagnosis'];
      if (renpra['intervensi'] != null)
        result['renpra_intervensi'] = renpra['intervensi'];
      if (renpra['tujuan'] != null) result['renpra_tujuan'] = renpra['tujuan'];
      if (renpra['kriteria'] != null)
        result['renpra_kriteria'] = renpra['kriteria'];
      if (renpra['rasional'] != null)
        result['renpra_rasional'] = renpra['rasional'];
    }

    if (data['materi_file_path'] != null)
      result['materi_file_path'] = data['materi_file_path'];
    if (data['dokumentasi_foto_path'] != null)
      result['dokumentasi_foto_path'] = data['dokumentasi_foto_path'];

    final feedback = data['feedback'] ?? {};
    if (feedback is Map) {
      if (feedback['pertanyaan'] != null)
        result['pertanyaan'] = feedback['pertanyaan'];
      if (feedback['saran'] != null) result['saran'] = feedback['saran'];
    }

    return result;
  }
}
