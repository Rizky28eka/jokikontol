class ResumePoliklinikMapper {
  static Map<String, dynamic> map(Map<String, dynamic> formData) {
    final result = <String, dynamic>{};

    // Basic form information
    if (formData['patient_id'] != null) result['patient_id'] = formData['patient_id'];
    if (formData['status'] != null) result['status'] = formData['status'];

    // Identitas section
    if (formData['nama_lengkap'] != null) result['nama_pasien'] = formData['nama_lengkap']; // name mapping
    if (formData['no_rm'] != null) result['no_rm'] = formData['no_rm'];
    if (formData['tanggal_kunjungan'] != null) result['tanggal_kunjungan'] = formData['tanggal_kunjungan'];
    if (formData['poliklinik'] != null) result['poliklinik'] = formData['poliklinik'];
    if (formData['umur'] != null) result['umur'] = formData['umur']; // might not be in backend, but kept for compatibility
    if (formData['jenis_kelamin'] != null) result['jenis_kelamin'] = formData['jenis_kelamin']; // might not be in backend, but kept for compatibility
    if (formData['status_perkawinan'] != null) result['status_perkawinan'] = formData['status_perkawinan']; // might not be in backend, but kept for compatibility

    // Anamnesis section
    if (formData['keluhan_utama'] != null) result['keluhan_utama'] = formData['keluhan_utama'];
    if (formData['riwayat_penyakit_sekarang'] != null) result['riwayat_penyakit_sekarang'] = formData['riwayat_penyakit_sekarang'];
    if (formData['riwayat_penyakit_dahulu'] != null) result['riwayat_penyakit_dahulu'] = formData['riwayat_penyakit_dahulu'];
    if (formData['riwayat_pengobatan'] != null) result['riwayat_pengobatan'] = formData['riwayat_pengobatan'];
    if (formData['riwayat_alergi'] != null) result['riwayat_alergi'] = formData['riwayat_alergi'];
    if (formData['riwayat_pendidikan'] != null) result['riwayat_pendidikan'] = formData['riwayat_pendidikan'];
    if (formData['pekerjaan'] != null) result['pekerjaan'] = formData['pekerjaan'];
    if (formData['riwayat_keluarga'] != null) result['riwayat_keluarga'] = formData['riwayat_keluarga'];
    if (formData['hubungan_sosial'] != null) result['hubungan_sosial'] = formData['hubungan_sosial'];
    if (formData['dukungan_sosial'] != null) result['dukungan_sosial'] = formData['dukungan_sosial'];
    if (formData['stresor_psikososial'] != null) result['stresor_psikososial'] = formData['stresor_psikososial'];

    // Pemeriksaan Fisik section
    if (formData['kesadaran'] != null) result['kesadaran'] = formData['kesadaran'];
    if (formData['tekanan_darah'] != null) result['tekanan_darah'] = formData['tekanan_darah'];
    if (formData['nadi'] != null) result['nadi'] = formData['nadi'];
    if (formData['suhu'] != null) result['suhu'] = formData['suhu'];
    if (formData['pernapasan'] != null) result['pernapasan'] = formData['pernapasan'];
    if (formData['berat_badan'] != null) result['berat_badan'] = formData['berat_badan'];
    if (formData['tinggi_badan'] != null) result['tinggi_badan'] = formData['tinggi_badan'];
    if (formData['orientasi'] != null) result['orientasi'] = formData['orientasi'];

    // Status Mental section
    if (formData['penampilan'] != null) result['penampilan'] = formData['penampilan'];
    if (formData['perilaku'] != null) result['perilaku'] = formData['perilaku'];
    if (formData['mood'] != null || formData['afect'] != null) {
      final mood = formData['mood']?.toString() ?? '';
      final afect = formData['afect']?.toString() ?? '';
      result['mood_afek'] = '$mood $afect'.trim();
    }
    if (formData['alam_pikiran'] != null) {
      result['pikiran'] = formData['alam_pikiran']; // mapping to backend field
    }

    // Diagnosis & Terapi section
    if (formData['diagnosis'] != null) result['diagnosis'] = formData['diagnosis'];
    if (formData['terapi_farmakologi'] != null) result['terapi_farmakologi'] = formData['terapi_farmakologi'];
    if (formData['terapi_non_farmakologi'] != null) result['terapi_non_farmakologi'] = formData['terapi_non_farmakologi'];
    if (formData['edukasi'] != null) result['edukasi'] = formData['edukasi'];

    // Fungsi Sosial section
    if (formData['fungsi_sosial'] != null) result['fungsi_sosial'] = formData['fungsi_sosial'];
    if (formData['interaksi_sosial'] != null) result['interaksi_sosial'] = formData['interaksi_sosial'];

    // Fungsi Spiritual section
    if (formData['kepercayaan'] != null) result['kepercayaan'] = formData['kepercayaan'];
    if (formData['praktik_ibadah'] != null) result['praktik_ibadah'] = formData['praktik_ibadah'];

    // Tindak Lanjut section
    if (formData['tanggal_kontrol_berikutnya'] != null) result['tanggal_kontrol_berikutnya'] = formData['tanggal_kontrol_berikutnya'];
    if (formData['rencana_tindak_lanjut'] != null) result['rencana_tindak_lanjut'] = formData['rencana_tindak_lanjut'];

    // Rencana Perawatan (Nursing Care Plan)
    if (formData['renpra_diagnosis'] != null) {
      result['renpra'] = {
        'diagnosis': formData['renpra_diagnosis'],
        'intervensi': formData['renpra_intervensi'],
        'tujuan': formData['renpra_tujuan'],
        'kriteria': formData['renpra_kriteria'],
        'rasional': formData['renpra_rasional'],
      };
    }

    // Penutup section
    if (formData['catatan_tambahan'] != null) result['catatan_tambahan'] = formData['catatan_tambahan'];
    if (formData['tanggal_pengisian'] != null) result['tanggal_pengisian'] = formData['tanggal_pengisian'];

    return result;
  }
}