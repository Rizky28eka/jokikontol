class ResumeKegawatdaruratanMapper {
  static Map<String, dynamic> map(Map<String, dynamic> formData) {
    final result = <String, dynamic>{};

    // Basic form information
    if (formData['patient_id'] != null) result['patient_id'] = formData['patient_id'];
    if (formData['status'] != null) result['status'] = formData['status'];

    // Identitas section
    if (formData['nama_lengkap'] != null) result['nama_pasien'] = formData['nama_lengkap']; // name mapping
    if (formData['no_rm'] != null) result['no_rm'] = formData['no_rm']; // new field
    if (formData['tanggal_masuk'] != null) result['tanggal_masuk'] = formData['tanggal_masuk'];
    if (formData['jam_masuk'] != null) result['jam_masuk'] = formData['jam_masuk']; // new field
    if (formData['tanggal_keluar'] != null) result['tanggal_keluar'] = formData['tanggal_keluar']; // new field
    if (formData['jam_keluar'] != null) result['jam_keluar'] = formData['jam_keluar']; // new field

    // Anamnesis section
    if (formData['keluhan_utama'] != null) result['keluhan_utama'] = formData['keluhan_utama'];
    if (formData['riwayat_penyakit_sekarang'] != null) result['riwayat_penyakit_sekarang'] = formData['riwayat_penyakit_sekarang'];
    if (formData['riwayat_penyakit_dahulu'] != null) result['riwayat_penyakit_dahulu'] = formData['riwayat_penyakit_dahulu']; // new field
    if (formData['riwayat_pengobatan'] != null) result['riwayat_pengobatan'] = formData['riwayat_pengobatan']; // new field
    if (formData['faktor_pencetus'] != null) result['faktor_pencetus'] = formData['faktor_pencetus']; // new field

    // Pemeriksaan Fisik section
    if (formData['keadaan_umum'] != null) result['keadaan_umum'] = formData['keadaan_umum']; // new field
    if (formData['tanda_vital'] != null) result['tanda_vital'] = formData['tanda_vital']; // new field
    if (formData['pemeriksaan_lain'] != null) result['pemeriksaan_lain'] = formData['pemeriksaan_lain']; // new field
    if (formData['kesadaran'] != null) result['kesadaran'] = formData['kesadaran'];
    if (formData['gcs'] != null) result['gcs'] = formData['gcs']; // new field
    if (formData['tekanan_darah'] != null) result['tekanan_darah'] = formData['tekanan_darah']; // new field
    if (formData['nadi'] != null) result['nadi'] = formData['nadi']; // new field
    if (formData['suhu'] != null) result['suhu'] = formData['suhu']; // new field
    if (formData['pernapasan'] != null) result['pernapasan'] = formData['pernapasan']; // new field
    if (formData['spo2'] != null) result['spo2'] = formData['spo2']; // new field

    // Status Mental section
    if (formData['penampilan'] != null) result['penampilan'] = formData['penampilan']; // new field
    if (formData['perilaku'] != null) result['perilaku'] = formData['perilaku']; // new field
    if (formData['pembicaraan'] != null) result['pembicaraan'] = formData['pembicaraan']; // new field
    if (formData['mood_afek'] != null) result['mood_afek'] = formData['mood_afek']; // new field
    if (formData['pikiran'] != null) result['pikiran'] = formData['pikiran']; // new field
    if (formData['persepsi'] != null) result['persepsi'] = formData['persepsi'];
    if (formData['kognitif'] != null) result['kognitif'] = formData['kognitif']; // new field
    if (formData['orientasi'] != null) result['orientasi'] = formData['orientasi']; // new field
    if (formData['bentuk_pemikiran'] != null) result['bentuk_pemikiran'] = formData['bentuk_pemikiran']; // new field
    if (formData['isi_pemikiran'] != null) result['isi_pemikiran'] = formData['isi_pemikiran']; // new field

    // Diagnosis & Tindakan section
    if (formData['diagnosis_utama'] != null) result['diagnosis_kerja'] = formData['diagnosis_utama']; // name mapping
    if (formData['diagnosis_banding'] != null) result['diagnosis_banding'] = formData['diagnosis_banding']; // new field
    if (formData['diagnosis_tambahan'] != null) result['diagnosis_tambahan'] = formData['diagnosis_tambahan']; // new field
    if (formData['tindakan_medis'] != null) result['tindakan_yang_dilakukan'] = formData['tindakan_medis']; // name mapping
    if (formData['tindakan_keperawatan'] != null) result['tindakan_keperawatan'] = formData['tindakan_keperawatan']; // new field
    if (formData['terapi_psikososial'] != null) result['terapi_psikososial'] = formData['terapi_psikososial']; // new field
    if (formData['terapi_obat'] != null) result['terapi_obat'] = formData['terapi_obat']; // new field

    // Section 7: Implementasi (new fields)
    if (formData['pelaksanaan_intervensi'] != null) result['pelaksanaan_intervensi'] = formData['pelaksanaan_intervensi']; // new field
    if (formData['kolaborasi_tim'] != null) result['kolaborasi_tim'] = formData['kolaborasi_tim']; // new field
    if (formData['edukasi'] != null) result['edukasi'] = formData['edukasi']; // new field

    // Section 8: Evaluasi (new fields)
    if (formData['respon_intervensi'] != null) result['respon_intervensi'] = formData['respon_intervensi']; // new field
    if (formData['perubahan_klinis'] != null) result['perubahan_klinis'] = formData['perubahan_klinis']; // new field
    if (formData['tujuan_tercapai'] != null) result['tujuan_tercapai'] = formData['tujuan_tercapai']; // new field
    if (formData['hambatan_perawatan'] != null) result['hambatan_perawatan'] = formData['hambatan_perawatan']; // new field

    // Section 9: Rencana Lanjut (new fields)
    if (formData['rencana_medis'] != null) result['anjuran'] = formData['rencana_medis']; // name mapping
    if (formData['rencana_keperawatan'] != null) result['rencana_keperawatan'] = formData['rencana_keperawatan']; // new field
    if (formData['rencana_pemantauan'] != null) result['rencana_pemantauan'] = formData['rencana_pemantauan']; // new field

    // Section 10: Rencana dengan Keluarga (new fields)
    if (formData['keterlibatan_keluarga'] != null) result['keterlibatan_keluarga'] = formData['keterlibatan_keluarga']; // new field
    if (formData['edukasi_keluarga'] != null) result['edukasi_keluarga'] = formData['edukasi_keluarga']; // new field
    if (formData['dukungan_keluarga'] != null) result['dukungan_keluarga'] = formData['dukungan_keluarga']; // new field

    // Section 11: Renpra (nursing care plan)
    if (formData['diagnosis'] != null) result['diagnosis'] = formData['diagnosis']; // new field
    if (formData['intervensi'] != null) result['intervensi'] = formData['intervensi']; // new field
    if (formData['tujuan'] != null) result['tujuan'] = formData['tujuan']; // new field
    if (formData['kriteria'] != null) result['kriteria'] = formData['kriteria']; // new field
    if (formData['rasional'] != null) result['rasional'] = formData['rasional']; // new field
    if (formData['evaluasi_renpra'] != null) result['evaluasi_renpra'] = formData['evaluasi_renpra']; // new field

    return result;
  }
}