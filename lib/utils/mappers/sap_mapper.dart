class SapMapper {
  static Map<String, dynamic> map(Map<String, dynamic> formData) {
    final result = <String, dynamic>{};

    // Basic form information
    if (formData['patient_id'] != null) result['patient_id'] = formData['patient_id'];
    if (formData['status'] != null) result['status'] = formData['status'];

    // Identitas SAP
    if (formData['topik'] != null) result['topik'] = formData['topik'];
    if (formData['sub_topik'] != null) result['sub_topik'] = formData['sub_topik'];
    if (formData['sasaran'] != null) result['sasaran'] = formData['sasaran'];
    if (formData['tanggal_pelaksanaan'] != null) result['tanggal_pelaksanaan'] = formData['tanggal_pelaksanaan'];
    if (formData['waktu_pelaksanaan'] != null) result['waktu_pelaksanaan'] = formData['waktu_pelaksanaan'];
    if (formData['tempat'] != null) result['tempat'] = formData['tempat'];
    if (formData['durasi'] != null) result['durasi'] = formData['durasi'];

    // Tujuan
    if (formData['tujuan_umum'] != null) result['tujuan_umum'] = formData['tujuan_umum'];
    if (formData['tujuan_khusus'] != null) result['tujuan_khusus'] = formData['tujuan_khusus'];

    // Materi
    if (formData['materi'] != null) result['materi_penyuluhan'] = formData['materi']; // name mapping

    // Metode & Media - convert string to array for backend
    if (formData['metode'] != null) {
      result['metode'] = _toStringList(formData['metode']);
    }
    if (formData['media'] != null) {
      result['media'] = _toStringList(formData['media']);
    }

    // Kegiatan Penyuluhan - map table kegiatan to kegiatan array
    if (formData['tabel_kegiatan'] != null) {
      result['kegiatan'] = formData['tabel_kegiatan']; // already in correct format
    }

    // Evaluasi
    if (formData['evaluasi_input'] != null) result['evaluasi_struktur'] = formData['evaluasi_input']; // name mapping
    if (formData['evaluasi_proses'] != null) result['evaluasi_proses'] = formData['evaluasi_proses'];
    if (formData['evaluasi_hasil'] != null) result['evaluasi_hasil'] = formData['evaluasi_hasil'];

    // Pengorganisasian - map roles to a single json field if needed
    // For now, we'll add them as additional fields for completeness
    if (formData['penyuluh'] != null) result['penyuluh'] = formData['penyuluh'];
    if (formData['moderator'] != null) result['moderator'] = formData['moderator'];
    if (formData['fasilitator'] != null) result['fasilitator'] = formData['fasilitator'];
    if (formData['time_keeper'] != null) result['time_keeper'] = formData['time_keeper'];
    if (formData['dokumentator'] != null) result['dokumentator'] = formData['dokumentator'];
    if (formData['observer'] != null) result['observer'] = formData['observer'];

    // Joblist roles - convert to array format
    if (formData['joblist_roles'] != null) {
      result['joblist_roles'] = formData['joblist_roles'];
    }

    // Feedback
    if (formData['pertanyaan'] != null) result['pertanyaan'] = formData['pertanyaan'];
    if (formData['saran'] != null) result['saran'] = formData['saran'];

    // Renpra - nursing care plan
    if (formData['diagnosis'] != null) {
      result['renpra'] = {
        'diagnosis': formData['diagnosis'],
        'intervensi': formData['intervensi'],
        'tujuan': formData['tujuan'],
        'kriteria': formData['kriteria'],
        'rasional': formData['rasional'],
      };
    }

    return result;
  }

  static List<String> _toStringList(dynamic value) {
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
}