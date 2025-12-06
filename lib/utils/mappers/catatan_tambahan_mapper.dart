class CatatanTambahanMapper {
  static Map<String, dynamic> map(Map<String, dynamic> formData) {
    final result = <String, dynamic>{};

    // Basic form information
    if (formData['patient_id'] != null) result['patient_id'] = formData['patient_id'];
    if (formData['status'] != null) result['status'] = formData['status'];

    // Main fields that match the backend
    if (formData['tanggal_catatan'] != null) result['tanggal_catatan'] = formData['tanggal_catatan'];
    if (formData['waktu_catatan'] != null) result['waktu_catatan'] = formData['waktu_catatan'];
    if (formData['kategori'] != null) result['kategori'] = formData['kategori'];
    if (formData['isi_catatan'] != null) result['catatan'] = formData['isi_catatan']; // name mapping
    if (formData['tindak_lanjut'] != null) result['tindak_lanjut'] = formData['tindak_lanjut'];

    // Handle renpra section - if nursing care plan is provided, it might be saved separately
    // For now, we'll include it in the result with a different key that can be processed by the backend
    if (formData['diagnosis'] != null) {
      result['renpra'] = {
        'diagnosis': formData['diagnosis'],
        'intervensi': formData['intervensi'],
        'tujuan': formData['tujuan'],
        'kriteria': formData['kriteria'],
        'rasional': formData['rasional'],
      };
    }

    // Also handle tindak_lanjut logic similar to the original
    String? tindakLanjut = formData['tindak_lanjut'];
    final intervensi = formData['intervensi'];
    if ((tindakLanjut == null || tindakLanjut.isEmpty) &&
        intervensi is List &&
        intervensi.isNotEmpty) {
      tindakLanjut = 'Melakukan intervensi: ${intervensi.join(", ")}';
    }
    if (tindakLanjut != null) result['tindak_lanjut'] = tindakLanjut;

    return result;
  }
}