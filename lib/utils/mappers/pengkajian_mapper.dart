class PengkajianMapper {
  static Map<String, dynamic> map(Map<String, dynamic> data) {
    final result = <String, dynamic>{};

    // Basic form information
    if (data['patient_id'] != null) result['patient_id'] = data['patient_id'];
    if (data['status'] != null) result['status'] = data['status'];

    // Section 1: Identitas Pasien (Patient Identity)
    if (data['nama_lengkap'] != null) result['nama_lengkap'] = data['nama_lengkap'];
    if (data['umur'] != null) result['usia'] = data['umur']; // umur -> usia mapping
    if (data['jenis_kelamin'] != null) result['jenis_kelamin'] = data['jenis_kelamin'];
    if (data['tempat_lahir'] != null) result['tempat_lahir'] = data['tempat_lahir'];
    if (data['tanggal_lahir'] != null) result['tanggal_lahir'] = data['tanggal_lahir'];
    if (data['agama'] != null) result['agama'] = data['agama'];
    if (data['suku'] != null) result['suku'] = data['suku'];
    if (data['pendidikan'] != null) result['pendidikan'] = data['pendidikan']; // From user interface
    if (data['pekerjaan'] != null) result['pekerjaan'] = data['pekerjaan'];
    if (data['alamat'] != null) result['alamat'] = data['alamat'];
    if (data['no_rm'] != null) result['no_rm'] = data['no_rm'];
    if (data['tanggal_masuk'] != null) result['tanggal_masuk'] = data['tanggal_masuk'];
    if (data['diagnosa_medis'] != null) result['diagnosa_medis'] = data['diagnosa_medis'];
    if (data['status_perkawinan'] != null) result['status_perkawinan'] = data['status_perkawinan']; // Additional field

    // Section 2: Riwayat Kesehatan (Health History)
    if (data['keluhan_utama'] != null) result['keluhan_utama'] = data['keluhan_utama'];
    if (data['riwayat_penyakit_sekarang'] != null) result['riwayat_penyakit_sekarang'] = data['riwayat_penyakit_sekarang'];
    if (data['riwayat_penyakit_dahulu'] != null) result['riwayat_penyakit_dahulu'] = data['riwayat_penyakit_dahulu'];
    if (data['riwayat_penyakit_keluarga'] != null) result['riwayat_penyakit_keluarga'] = data['riwayat_penyakit_keluarga'];
    if (data['riwayat_pengobatan'] != null) result['riwayat_pengobatan'] = data['riwayat_pengobatan'];
    if (data['riwayat_pendidikan'] != null) result['riwayat_pendidikan'] = data['riwayat_pendidikan']; // Additional field
    if (data['riwayat_keluarga'] != null) result['riwayat_keluarga'] = data['riwayat_keluarga']; // Additional field

    // Section 3: Pemeriksaan Fisik (Physical Examination)
    if (data['tekanan_darah'] != null) result['tekanan_darah'] = data['tekanan_darah'];
    if (data['nadi'] != null) result['nadi'] = data['nadi'];
    if (data['suhu'] != null) result['suhu'] = data['suhu'];
    if (data['pernapasan'] != null) result['pernapasan'] = data['pernapasan'];
    if (data['tinggi_badan'] != null) result['tinggi_badan'] = data['tinggi_badan'];
    if (data['berat_badan'] != null) result['berat_badan'] = data['berat_badan'];

    // Section 4: Psikososial (Psychosocial)
    if (data['konsep_diri'] != null) result['konsep_diri'] = data['konsep_diri'];
    if (data['hubungan_sosial'] != null) result['hubungan_sosial'] = data['hubungan_sosial'];
    if (data['spiritual'] != null) result['spiritual'] = data['spiritual'];
    if (data['dukungan_sosial'] != null) result['dukungan_sosial'] = data['dukungan_sosial']; // Additional field
    if (data['stresor_psikososial'] != null) result['stresor_psikososial'] = data['stresor_psikososial']; // Additional field
    if (data['fungsi_sosial'] != null) result['fungsi_sosial'] = data['fungsi_sosial']; // Additional field
    if (data['kepercayaan'] != null) result['kepercayaan'] = data['kepercayaan']; // Additional field
    if (data['praktik_ibadah'] != null) result['praktik_ibadah'] = data['praktik_ibadah']; // Additional field

    // Section 5: Genogram
    if (data['genogram_structure'] != null) result['genogram_structure'] = data['genogram_structure'];
    if (data['genogram_notes'] != null) result['genogram_notes'] = data['genogram_notes'];

    // Section 6: Status Mental (Mental Status)
    if (data['penampilan'] != null) result['penampilan'] = data['penampilan'];
    if (data['pembicaraan'] != null) result['pembicaraan'] = data['pembicaraan'];
    if (data['aktivitas_motorik'] != null) result['aktivitas_motorik'] = data['aktivitas_motorik'];
    if (data['alam_perasaan'] != null) result['alam_perasaan'] = data['alam_perasaan'];
    if (data['afek'] != null) result['afek'] = data['afek']; // afect -> afek mapping
    if (data['interaksi'] != null) result['interaksi'] = data['interaksi'];
    if (data['persepsi'] != null) result['persepsi'] = data['persepsi'];
    if (data['proses_pikir'] != null) result['proses_pikir'] = data['proses_pikir'];
    if (data['isi_pikir'] != null) result['isi_pikir'] = data['isi_pikir'];
    if (data['tingkat_kesadaran'] != null) result['tingkat_kesadaran'] = data['tingkat_kesadaran'];
    if (data['memori'] != null) result['memori'] = data['memori'];
    if (data['tingkat_konsentrasi'] != null) result['tingkat_konsentrasi'] = data['tingkat_konsentrasi'];
    if (data['orientasi'] != null) result['orientasi'] = data['orientasi'];
    if (data['daya_tilik_diri'] != null) result['daya_tilik_diri'] = data['daya_tilik_diri'];
    
    // Additional mental health fields from frontend
    if (data['kesadaran'] != null) result['tingkat_kesadaran'] = data['kesadaran']; // kesadaran -> tingkat_kesadaran mapping
    if (data['mood'] != null) result['alam_perasaan'] = data['mood']; // mood -> alam_perasaan mapping
    if (data['afect'] != null) result['afek'] = data['afect']; // afect -> afek mapping
    if (data['alam_pikiran'] != null) result['alam_pikiran'] = data['alam_pikiran']; // Additional field

    // Section 7: Kebutuhan Persiapan Pulang (Discharge Planning Needs)
    if (data['makan_mandiri'] != null) result['makan_mandiri'] = data['makan_mandiri'];
    if (data['bab_bak_mandiri'] != null) result['bab_bak_mandiri'] = data['bab_bak_mandiri'];
    if (data['mandi_mandiri'] != null) result['mandi_mandiri'] = data['mandi_mandiri'];
    if (data['berpakaian_mandiri'] != null) result['berpakaian_mandiri'] = data['berpakaian_mandiri'];
    if (data['istirahat_tidur_cukup'] != null) result['istirahat_tidur_cukup'] = data['istirahat_tidur_cukup'];
    if (data['kebutuhan_persiapan_pulang_lainnya'] != null) result['kebutuhan_persiapan_pulang_lainnya'] = data['kebutuhan_persiapan_pulang_lainnya'];

    // Section 8: Mekanisme Koping dan Masalah Psikososial
    if (data['mekanisme_koping'] != null) result['mekanisme_koping'] = data['mekanisme_koping'];
    if (data['masalah_psikososial'] != null) result['masalah_psikososial'] = data['masalah_psikososial'];

    // Section 9: Aspek Medik
    if (data['diagnosa_medis_lengkap'] != null) result['diagnosa_medis_lengkap'] = data['diagnosa_medis_lengkap'];
    if (data['terapi_medis'] != null) result['terapi_medis'] = data['terapi_medis'];

    // Section 10: Rencana Perawatan (Nursing Care Plan)
    if (data['riwayat_gangguan_psikiatri'] != null) result['riwayat_gangguan_psikiatri'] = data['riwayat_gangguan_psikiatri']; // Additional field
    if (data['diagnosis'] != null) result['diagnosis'] = data['diagnosis']; // Additional field
    if (data['intervensi'] != null) result['intervensi'] = data['intervensi']; // Additional field
    if (data['tujuan'] != null) result['tujuan'] = data['tujuan']; // Additional field
    if (data['kriteria'] != null) result['kriteria'] = data['kriteria']; // Additional field
    if (data['rasional'] != null) result['rasional'] = data['rasional']; // Additional field

    // Section 11: Penutup (Closing)
    if (data['catatan_tambahan'] != null) result['catatan_tambahan'] = data['catatan_tambahan']; // Additional field
    if (data['tanggal_pengisian'] != null) result['tanggal_pengisian'] = data['tanggal_pengisian']; // Additional field

    return result;
  }
}