class PengkajianMapper {
  static Map<String, dynamic> map(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    
    // Section 1: Identitas Klien
    if (data['nama_lengkap'] != null) result['nama_lengkap'] = data['nama_lengkap'];
    if (data['umur'] != null) result['umur'] = data['umur'];
    if (data['jenis_kelamin'] != null) result['jenis_kelamin'] = data['jenis_kelamin'];
    if (data['status_perkawinan'] != null) result['status_perkawinan'] = data['status_perkawinan'];
    
    // Section 2: Riwayat Kehidupan
    if (data['riwayat_pendidikan'] != null) result['riwayat_pendidikan'] = data['riwayat_pendidikan'];
    if (data['pekerjaan'] != null) result['pekerjaan'] = data['pekerjaan'];
    if (data['riwayat_keluarga'] != null) result['riwayat_keluarga'] = data['riwayat_keluarga'];
    
    // Section 3: Riwayat Psikososial
    if (data['hubungan_sosial'] != null) result['hubungan_sosial'] = data['hubungan_sosial'];
    if (data['dukungan_sosial'] != null) result['dukungan_sosial'] = data['dukungan_sosial'];
    if (data['stresor_psikososial'] != null) result['stresor_psikososial'] = data['stresor_psikososial'];
    
    // Section 4: Riwayat Psikiatri
    if (data['riwayat_gangguan_psikiatri'] != null) result['riwayat_gangguan_psikiatri'] = data['riwayat_gangguan_psikiatri'];
    
    // Section 5: Pemeriksaan Psikologis
    if (data['kesadaran'] != null) result['kesadaran'] = data['kesadaran'];
    if (data['orientasi'] != null) result['orientasi'] = data['orientasi'];
    if (data['penampilan'] != null) result['penampilan'] = data['penampilan'];
    
    // Section 6: Fungsi Psikologis
    if (data['mood'] != null) result['mood'] = data['mood'];
    if (data['afect'] != null) result['afect'] = data['afect'];
    if (data['alam_pikiran'] != null) result['alam_pikiran'] = data['alam_pikiran'];
    
    // Section 7: Fungsi Sosial
    if (data['fungsi_sosial'] != null) result['fungsi_sosial'] = data['fungsi_sosial'];
    
    // Section 8: Fungsi Spiritual
    if (data['kepercayaan'] != null) result['kepercayaan'] = data['kepercayaan'];
    if (data['praktik_ibadah'] != null) result['praktik_ibadah'] = data['praktik_ibadah'];
    
    // Section 9: Genogram
    if (data['genogram_structure'] != null) result['genogram_structure'] = data['genogram_structure'];
    if (data['genogram_notes'] != null) result['genogram_notes'] = data['genogram_notes'];
    
    // Section 10: Rencana Perawatan (Renpra)
    if (data['diagnosis'] != null) result['diagnosis'] = data['diagnosis'];
    if (data['intervensi'] != null) result['intervensi'] = data['intervensi'];
    if (data['tujuan'] != null) result['tujuan'] = data['tujuan'];
    if (data['kriteria'] != null) result['kriteria'] = data['kriteria'];
    if (data['rasional'] != null) result['rasional'] = data['rasional'];
    
    // Section 11: Penutup
    if (data['catatan_tambahan'] != null) result['catatan_tambahan'] = data['catatan_tambahan'];
    if (data['tanggal_pengisian'] != null) result['tanggal_pengisian'] = data['tanggal_pengisian'];
    
    return result;
  }
}
