class CatatanTambahanMapper {
  static Map<String, dynamic> map(Map<String, dynamic> formData) {
    final renpra = formData['diagnosis'] != null && formData['diagnosis'] != ''
        ? {
            'diagnosis': formData['diagnosis'],
            'intervensi': formData['intervensi'],
            'tujuan': formData['tujuan'],
            'kriteria': formData['kriteria'],
            'rasional': formData['rasional'],
          }
        : null;

    String? tindakLanjut = formData['tindak_lanjut'];
    final intervensi = formData['intervensi'];
    if ((tindakLanjut == null || tindakLanjut.isEmpty) &&
        intervensi is List &&
        intervensi.isNotEmpty) {
      tindakLanjut = 'Melakukan intervensi: ${intervensi.join(", ")}';
    }

    return {
      'tanggal_catatan': formData['tanggal_catatan'],
      'waktu_catatan': formData['waktu_catatan'],
      'kategori': formData['kategori'],
      'catatan': formData['isi_catatan'],
      'tindak_lanjut': tindakLanjut,
      if (renpra != null) 'renpra': renpra,
    };
  }
}
