class CatatanTambahanReverseMapper {
  static Map<String, dynamic> reverse(Map<String, dynamic> data) {
    return {
      'catatan': {
        'isi_catatan': data['catatan'] ?? data['isi_catatan'],
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
