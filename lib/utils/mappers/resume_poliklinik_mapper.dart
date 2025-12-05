class ResumePoliklinikMapper {
  static Map<String, dynamic> map(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    
    final section1 = data['section_1'] ?? {};
    final section2 = data['section_2'] ?? {};
    final section3 = data['section_3'] ?? {};
    final section4 = data['section_4'] ?? {};
    final section5 = data['section_5'] ?? {};
    final section6 = data['section_6'] ?? {};
    final section7 = data['section_7'] ?? {};
    final section8 = data['section_8'] ?? {};
    final section9 = data['section_9'] ?? {};
    final section10 = data['section_10'] ?? {};

    // Section 1: Identitas Klien
    if (section1['nama_lengkap'] != null) result['nama_lengkap'] = section1['nama_lengkap'];
    else if (data['nama_lengkap'] != null) result['nama_lengkap'] = data['nama_lengkap'];
    
    if (section1['umur'] != null) result['umur'] = section1['umur'];
    else if (data['umur'] != null) result['umur'] = data['umur'];
    
    if (section1['jenis_kelamin'] != null) result['jenis_kelamin'] = section1['jenis_kelamin'];
    else if (data['jenis_kelamin'] != null) result['jenis_kelamin'] = data['jenis_kelamin'];
    
    if (section1['status_perkawinan'] != null) result['status_perkawinan'] = section1['status_perkawinan'];
    else if (data['status_perkawinan'] != null) result['status_perkawinan'] = data['status_perkawinan'];

    // Section 2: Riwayat Kehidupan
    if (section2['riwayat_pendidikan'] != null) result['riwayat_pendidikan'] = section2['riwayat_pendidikan'];
    else if (data['riwayat_pendidikan'] != null) result['riwayat_pendidikan'] = data['riwayat_pendidikan'];
    
    if (section2['pekerjaan'] != null) result['pekerjaan'] = section2['pekerjaan'];
    else if (data['pekerjaan'] != null) result['pekerjaan'] = data['pekerjaan'];
    
    if (section2['riwayat_keluarga'] != null) result['riwayat_keluarga'] = section2['riwayat_keluarga'];
    else if (data['riwayat_keluarga'] != null) result['riwayat_keluarga'] = data['riwayat_keluarga'];

    // Section 3: Riwayat Psikososial
    if (section3['hubungan_sosial'] != null) result['hubungan_sosial'] = section3['hubungan_sosial'];
    else if (data['hubungan_sosial'] != null) result['hubungan_sosial'] = data['hubungan_sosial'];
    
    if (section3['dukungan_sosial'] != null) result['dukungan_sosial'] = section3['dukungan_sosial'];
    else if (data['dukungan_sosial'] != null) result['dukungan_sosial'] = data['dukungan_sosial'];
    
    if (section3['stresor_psikososial'] != null) result['stresor_psikososial'] = section3['stresor_psikososial'];
    else if (data['stresor_psikososial'] != null) result['stresor_psikososial'] = data['stresor_psikososial'];

    // Section 4: Riwayat Psikiatri
    if (section4['riwayat_gangguan_psikiatri'] != null) result['riwayat_gangguan_psikiatri'] = section4['riwayat_gangguan_psikiatri'];
    else if (data['riwayat_gangguan_psikiatri'] != null) result['riwayat_gangguan_psikiatri'] = data['riwayat_gangguan_psikiatri'];
    
    if (section4['riwayat_pengobatan'] != null) result['riwayat_pengobatan'] = section4['riwayat_pengobatan'];
    else if (data['riwayat_pengobatan'] != null) result['riwayat_pengobatan'] = data['riwayat_pengobatan'];

    // Section 5: Pemeriksaan Psikologis
    if (section5['kesadaran'] != null) result['kesadaran'] = section5['kesadaran'];
    else if (data['kesadaran'] != null) result['kesadaran'] = data['kesadaran'];
    
    if (section5['orientasi'] != null) result['orientasi'] = section5['orientasi'];
    else if (data['orientasi'] != null) result['orientasi'] = data['orientasi'];
    
    if (section5['penampilan'] != null) result['penampilan'] = section5['penampilan'];
    else if (data['penampilan'] != null) result['penampilan'] = data['penampilan'];

    // Section 6: Fungsi Psikologis
    if (section6['mood'] != null) result['mood'] = section6['mood'];
    else if (data['mood'] != null) result['mood'] = data['mood'];
    
    if (section6['afect'] != null) result['afect'] = section6['afect'];
    else if (data['afect'] != null) result['afect'] = data['afect'];
    
    if (section6['alam_pikiran'] != null) result['alam_pikiran'] = section6['alam_pikiran'];
    else if (data['alam_pikiran'] != null) result['alam_pikiran'] = data['alam_pikiran'];

    // Section 7: Fungsi Sosial
    if (section7['fungsi_sosial'] != null) result['fungsi_sosial'] = section7['fungsi_sosial'];
    else if (data['fungsi_sosial'] != null) result['fungsi_sosial'] = data['fungsi_sosial'];
    
    if (section7['interaksi_sosial'] != null) result['interaksi_sosial'] = section7['interaksi_sosial'];
    else if (data['interaksi_sosial'] != null) result['interaksi_sosial'] = data['interaksi_sosial'];

    // Section 8: Fungsi Spiritual
    if (section8['kepercayaan'] != null) result['kepercayaan'] = section8['kepercayaan'];
    else if (data['kepercayaan'] != null) result['kepercayaan'] = data['kepercayaan'];
    
    if (section8['praktik_ibadah'] != null) result['praktik_ibadah'] = section8['praktik_ibadah'];
    else if (data['praktik_ibadah'] != null) result['praktik_ibadah'] = data['praktik_ibadah'];

    // Section 9: Renpra
    if (section9['diagnosis'] != null) result['diagnosis'] = section9['diagnosis'];
    else if (data['diagnosis'] != null) result['diagnosis'] = data['diagnosis'];
    
    if (section9['intervensi'] != null) result['intervensi'] = section9['intervensi'];
    else if (data['intervensi'] != null) result['intervensi'] = data['intervensi'];
    
    if (section9['tujuan'] != null) result['tujuan'] = section9['tujuan'];
    else if (data['tujuan'] != null) result['tujuan'] = data['tujuan'];
    
    if (section9['kriteria'] != null) result['kriteria'] = section9['kriteria'];
    else if (data['kriteria'] != null) result['kriteria'] = data['kriteria'];
    
    if (section9['rasional'] != null) result['rasional'] = section9['rasional'];
    else if (data['rasional'] != null) result['rasional'] = data['rasional'];

    // Section 10: Penutup
    if (section10['catatan_tambahan'] != null) result['catatan_tambahan'] = section10['catatan_tambahan'];
    else if (data['catatan_tambahan'] != null) result['catatan_tambahan'] = data['catatan_tambahan'];
    
    if (section10['tanggal_pengisian'] != null) result['tanggal_pengisian'] = section10['tanggal_pengisian'];
    else if (data['tanggal_pengisian'] != null) result['tanggal_pengisian'] = data['tanggal_pengisian'];
    
    return result;
  }
}
