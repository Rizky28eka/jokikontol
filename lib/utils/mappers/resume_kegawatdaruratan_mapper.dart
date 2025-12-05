class ResumeKegawatdaruratanMapper {
  static Map<String, dynamic> map(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    
    final identitas = data['identitas'] ?? {};
    final riwayatKeluhan = data['riwayat_keluhan'] ?? {};
    final pemeriksaanFisik = data['pemeriksaan_fisik'] ?? {};
    final statusMental = data['status_mental'] ?? {};
    final diagnosis = data['diagnosis'] ?? {};
    final tindakan = data['tindakan'] ?? {};
    final renpra = data['renpra'] ?? {};

    // Identitas
    if (identitas['nama_lengkap'] != null) result['nama_lengkap'] = identitas['nama_lengkap'];
    else if (data['nama_lengkap'] != null) result['nama_lengkap'] = data['nama_lengkap'];
    
    if (identitas['umur'] != null) result['umur'] = identitas['umur'];
    else if (data['umur'] != null) result['umur'] = data['umur'];
    
    if (identitas['jenis_kelamin'] != null) result['jenis_kelamin'] = identitas['jenis_kelamin'];
    else if (data['jenis_kelamin'] != null) result['jenis_kelamin'] = data['jenis_kelamin'];
    
    if (identitas['alamat'] != null) result['alamat'] = identitas['alamat'];
    else if (data['alamat'] != null) result['alamat'] = data['alamat'];
    
    if (identitas['tanggal_masuk'] != null) result['tanggal_masuk'] = identitas['tanggal_masuk'];
    else if (data['tanggal_masuk'] != null) result['tanggal_masuk'] = data['tanggal_masuk'];
    
    // Riwayat Keluhan
    if (riwayatKeluhan['keluhan_utama'] != null) result['keluhan_utama'] = riwayatKeluhan['keluhan_utama'];
    else if (data['keluhan_utama'] != null) result['keluhan_utama'] = data['keluhan_utama'];
    
    if (riwayatKeluhan['riwayat_penyakit_sekarang'] != null) result['riwayat_penyakit_sekarang'] = riwayatKeluhan['riwayat_penyakit_sekarang'];
    else if (data['riwayat_penyakit_sekarang'] != null) result['riwayat_penyakit_sekarang'] = data['riwayat_penyakit_sekarang'];
    
    if (riwayatKeluhan['faktor_pencetus'] != null) result['faktor_pencetus'] = riwayatKeluhan['faktor_pencetus'];
    else if (data['faktor_pencetus'] != null) result['faktor_pencetus'] = data['faktor_pencetus'];
    
    // Pemeriksaan Fisik
    if (pemeriksaanFisik['keadaan_umum'] != null) result['keadaan_umum'] = pemeriksaanFisik['keadaan_umum'];
    else if (data['keadaan_umum'] != null) result['keadaan_umum'] = data['keadaan_umum'];
    
    if (pemeriksaanFisik['tanda_vital'] != null) result['tanda_vital'] = pemeriksaanFisik['tanda_vital'];
    else if (data['tanda_vital'] != null) result['tanda_vital'] = data['tanda_vital'];
    
    if (pemeriksaanFisik['pemeriksaan_lain'] != null) result['pemeriksaan_lain'] = pemeriksaanFisik['pemeriksaan_lain'];
    else if (data['pemeriksaan_lain'] != null) result['pemeriksaan_lain'] = data['pemeriksaan_lain'];
    
    // Status Mental
    if (statusMental['kesadaran'] != null) result['kesadaran'] = statusMental['kesadaran'];
    else if (data['kesadaran'] != null) result['kesadaran'] = data['kesadaran'];
    
    if (statusMental['orientasi'] != null) result['orientasi'] = statusMental['orientasi'];
    else if (data['orientasi'] != null) result['orientasi'] = data['orientasi'];
    
    if (statusMental['bentuk_pemikiran'] != null) result['bentuk_pemikiran'] = statusMental['bentuk_pemikiran'];
    else if (data['bentuk_pemikiran'] != null) result['bentuk_pemikiran'] = data['bentuk_pemikiran'];
    
    if (statusMental['isi_pemikiran'] != null) result['isi_pemikiran'] = statusMental['isi_pemikiran'];
    else if (data['isi_pemikiran'] != null) result['isi_pemikiran'] = data['isi_pemikiran'];
    
    if (statusMental['persepsi'] != null) result['persepsi'] = statusMental['persepsi'];
    else if (data['persepsi'] != null) result['persepsi'] = data['persepsi'];
    
    // Diagnosis
    if (diagnosis['diagnosis_utama'] != null) result['diagnosis_utama'] = diagnosis['diagnosis_utama'];
    else if (data['diagnosis_utama'] != null) result['diagnosis_utama'] = data['diagnosis_utama'];
    
    if (diagnosis['diagnosis_banding'] != null) result['diagnosis_banding'] = diagnosis['diagnosis_banding'];
    else if (data['diagnosis_banding'] != null) result['diagnosis_banding'] = data['diagnosis_banding'];
    
    if (diagnosis['diagnosis_tambahan'] != null) result['diagnosis_tambahan'] = diagnosis['diagnosis_tambahan'];
    else if (data['diagnosis_tambahan'] != null) result['diagnosis_tambahan'] = data['diagnosis_tambahan'];
    
    // Tindakan
    if (tindakan['tindakan_medis'] != null) result['tindakan_medis'] = tindakan['tindakan_medis'];
    else if (data['tindakan_medis'] != null) result['tindakan_medis'] = data['tindakan_medis'];
    
    if (tindakan['tindakan_keperawatan'] != null) result['tindakan_keperawatan'] = tindakan['tindakan_keperawatan'];
    else if (data['tindakan_keperawatan'] != null) result['tindakan_keperawatan'] = data['tindakan_keperawatan'];
    
    if (tindakan['terapi_psikososial'] != null) result['terapi_psikososial'] = tindakan['terapi_psikososial'];
    else if (data['terapi_psikososial'] != null) result['terapi_psikososial'] = data['terapi_psikososial'];
    
    // Renpra
    if (renpra['diagnosis'] != null) result['renpra_diagnosis'] = renpra['diagnosis'];
    if (renpra['intervensi'] != null) result['renpra_intervensi'] = renpra['intervensi'];
    if (renpra['tujuan'] != null) result['renpra_tujuan'] = renpra['tujuan'];
    if (renpra['kriteria'] != null) result['renpra_kriteria'] = renpra['kriteria'];
    if (renpra['rasional'] != null) result['renpra_rasional'] = renpra['rasional'];
    
    return result;
  }
}
