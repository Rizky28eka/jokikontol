import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../models/patient_model.dart';
import '../services/nursing_data_global_service.dart';
import '../utils/form_builder_mixin.dart';
import '../widgets/form_components/custom_text_field.dart';
import '../widgets/form_components/custom_dropdown.dart';
import '../widgets/form_components/custom_checkbox_group.dart';
import '../widgets/form_components/custom_date_time_picker.dart';

class ResumeKegawatdaruratanFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const ResumeKegawatdaruratanFormView({super.key, this.patient, this.formId});

  @override
  State<ResumeKegawatdaruratanFormView> createState() =>
      _ResumeKegawatdaruratanFormViewState();
}

class _ResumeKegawatdaruratanFormViewState
    extends State<ResumeKegawatdaruratanFormView>
    with FormBuilderMixin {
  @override
  final FormController formController = Get.put(FormController());
  @override
  final PatientController patientController = Get.find();
  final NursingInterventionController _interventionController = Get.put(
    NursingInterventionController(),
  );

  int _currentSection = 0;

  @override
  String get formType => 'resume_kegawatdaruratan';

  @override
  int? get formId => widget.formId ?? Get.arguments?['formId'] as int?;

  Patient? _currentPatient;
  int? _currentPatientId;

  @override
  Patient? get currentPatient => _currentPatient;

  @override
  int? get currentPatientId => _currentPatientId;

  @override
  void initState() {
    super.initState();
    _currentPatient = widget.patient ?? Get.arguments?['patient'] as Patient?;
    _currentPatientId =
        _currentPatient?.id ?? Get.arguments?['patientId'] as int?;
    initializeForm(
      patient: _currentPatient,
      patientId: _currentPatientId,
      formId: formId,
    );
  }

  void _nextSection() {
    updateFormData();
    if (_currentSection < 10) setState(() => _currentSection++);
  }

  void _previousSection() {
    updateFormData();
    if (_currentSection > 0) setState(() => _currentSection--);
  }

  Widget _buildSection(int sectionNumber) {
    Widget sectionContent;
    switch (sectionNumber) {
      case 0:
        sectionContent = _buildIdentitasSection();
        break;
      case 1:
        sectionContent = _buildRiwayatKeluhanSection();
        break;
      case 2:
        sectionContent = _buildPemeriksaanFisikSection();
        break;
      case 3:
        sectionContent = _buildStatusMentalSection();
        break;
      case 4:
        sectionContent = _buildDiagnosisSection();
        break;
      case 5:
        sectionContent = _buildTindakanSection();
        break;
      case 6:
        sectionContent = _buildImplementasiSection();
        break;
      case 7:
        sectionContent = _buildEvaluasiSection();
        break;
      case 8:
        sectionContent = _buildRencanaLanjutSection();
        break;
      case 9:
        sectionContent = _buildRencanaKeluargaSection();
        break;
      case 10:
        sectionContent = _buildRenpraSection();
        break;
      default:
        sectionContent = const SizedBox();
    }

    return KeyedSubtree(
      key: ValueKey('section_$sectionNumber'),
      child: sectionContent,
    );
  }

  Widget _buildIdentitasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 1: Identitas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const CustomTextField(name: 'nama_lengkap', label: 'Nama Pasien', tooltip: 'Nama lengkap pasien'),
        const SizedBox(height: 16),
        const CustomTextField(name: 'no_rm', label: 'Nomor Rekam Medis', tooltip: 'Nomor rekam medis pasien'),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'umur',
          label: 'Umur',
          tooltip: 'Usia pasien dalam tahun',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          name: 'jenis_kelamin',
          label: 'Jenis Kelamin',
          tooltip: 'Jenis kelamin pasien',
          items: const [
            DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
            DropdownMenuItem(value: 'P', child: Text('Perempuan')),
            DropdownMenuItem(value: 'O', child: Text('Lainnya')),
          ],
          hint: 'Pilih Jenis Kelamin',
        ),
        const SizedBox(height: 16),
        const CustomTextField(name: 'alamat', label: 'Alamat', tooltip: 'Alamat tempat tinggal pasien', maxLines: 2),
        const SizedBox(height: 16),
        const CustomDateTimePicker(
          name: 'tanggal_masuk',
          label: 'Tanggal Masuk',
          tooltip: 'Tanggal pasien masuk ke fasilitas kesehatan',
          inputType: InputType.date,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'jam_masuk',
          label: 'Jam Masuk',
          tooltip: 'Jam pasien masuk ke fasilitas kesehatan',
        ),
        const SizedBox(height: 16),
        const CustomDateTimePicker(
          name: 'tanggal_keluar',
          label: 'Tanggal Keluar',
          tooltip: 'Tanggal pasien keluar dari fasilitas kesehatan',
          inputType: InputType.date,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'jam_keluar',
          label: 'Jam Keluar',
          tooltip: 'Jam pasien keluar dari fasilitas kesehatan',
        ),
      ],
    );
  }

  Widget _buildRiwayatKeluhanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 2: Riwayat Keluhan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'keluhan_utama',
          label: 'Keluhan Utama',
          tooltip: 'Keluhan utama yang dirasakan pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'riwayat_penyakit_sekarang',
          label: 'Riwayat Penyakit Sekarang',
          tooltip: 'Riwayat penyakit yang sedang dialami pasien',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'riwayat_penyakit_dahulu',
          label: 'Riwayat Penyakit Dahulu',
          tooltip: 'Riwayat penyakit yang pernah dialami pasien sebelumnya',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'riwayat_pengobatan',
          label: 'Riwayat Pengobatan',
          tooltip: 'Riwayat pengobatan yang pernah diterima pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'faktor_pencetus',
          label: 'Faktor Pencetus',
          tooltip: 'Faktor-faktor yang mungkin memicu gangguan kesehatan pasien',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPemeriksaanFisikSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 3: Pemeriksaan Fisik',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const CustomTextField(name: 'keadaan_umum', label: 'Keadaan Umum', tooltip: 'Kondisi umum pasien saat pemeriksaan'),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'tanda_vital',
          label: 'Tanda-tanda Vital',
          tooltip: 'Pemeriksaan tanda-tanda vital pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'tekanan_darah',
          label: 'Tekanan Darah',
          tooltip: 'Tekanan darah pasien (sistolik/diastolik)',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'nadi',
          label: 'Nadi',
          tooltip: 'Frekuensi denyut nadi pasien',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'suhu',
          label: 'Suhu',
          tooltip: 'Suhu tubuh pasien',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'pernapasan',
          label: 'Pernapasan',
          tooltip: 'Frekuensi pernapasan pasien',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'gcs',
          label: 'GCS (Glasgow Coma Scale)',
          tooltip: 'Skala kesadaran pasien menurut Glasgow Coma Scale',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'spo2',
          label: 'SpO2',
          tooltip: 'Saturasi oksigen dalam darah',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'pemeriksaan_lain',
          label: 'Pemeriksaan Fisik Lain',
          tooltip: 'Pemeriksaan fisik tambahan yang dilakukan',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildStatusMentalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 4: Status Mental',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          name: 'kesadaran',
          label: 'Kesadaran',
          tooltip: 'Tingkat kesadaran pasien saat pemeriksaan',
          items: const [
            DropdownMenuItem(value: 'sadar_penuh', child: Text('Sadar Penuh')),
            DropdownMenuItem(value: 'somnolent', child: Text('Somnolent')),
            DropdownMenuItem(value: 'stupor', child: Text('Stupor')),
            DropdownMenuItem(value: 'coma', child: Text('Coma')),
          ],
          hint: 'Pilih Kesadaran',
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          name: 'orientasi',
          label: 'Orientasi',
          tooltip: 'Kemampuan pasien mengenal diri dan lingkungan',
          items: const [
            DropdownMenuItem(value: 'utuh', child: Text('Utuh')),
            DropdownMenuItem(value: 'gangguan', child: Text('Gangguan')),
          ],
          hint: 'Pilih Orientasi',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'bentuk_pemikiran',
          label: 'Bentuk Pemikiran',
          tooltip: 'Struktur dan proses pemikiran pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'isi_pemikiran',
          label: 'Isi Pemikiran',
          tooltip: 'Isi pikiran yang dikembangkan pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(name: 'persepsi', label: 'Persepsi', tooltip: 'Kemampuan pasien dalam menangkap dan memahami informasi', maxLines: 3),
        const SizedBox(height: 16),
        const CustomTextField(name: 'penampilan', label: 'Penampilan', tooltip: 'Deskripsi penampilan fisik pasien', maxLines: 3),
        const SizedBox(height: 16),
        const CustomTextField(name: 'perilaku', label: 'Perilaku', tooltip: 'Deskripsi perilaku pasien saat pemeriksaan', maxLines: 3),
        const SizedBox(height: 16),
        const CustomTextField(name: 'pembicaraan', label: 'Pembicaraan', tooltip: 'Gaya dan kecepatan berbicara pasien', maxLines: 3),
        const SizedBox(height: 16),
        const CustomTextField(name: 'mood_afek', label: 'Mood/Afek', tooltip: 'Perasaan umum dan ekspresi emosional pasien', maxLines: 3),
        const SizedBox(height: 16),
        const CustomTextField(name: 'pikiran', label: 'Pikiran', tooltip: 'Isi dan proses berpikir pasien', maxLines: 3),
        const SizedBox(height: 16),
        const CustomTextField(name: 'kognitif', label: 'Kognitif', tooltip: 'Fungsi kognitif pasien', maxLines: 3),
      ],
    );
  }

  Widget _buildDiagnosisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 5: Diagnosis Kerja',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'diagnosis_kerja',
          label: 'Diagnosis Kerja',
          tooltip: 'Diagnosis kerja yang disusun oleh tenaga kesehatan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'diagnosis_utama',
          label: 'Diagnosis Utama',
          tooltip: 'Diagnosis utama yang menjadi fokus perawatan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'diagnosis_banding',
          label: 'Diagnosis Banding',
          tooltip: 'Diagnosis banding yang perlu dipertimbangkan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'diagnosis_tambahan',
          label: 'Diagnosis Tambahan',
          tooltip: 'Diagnosis tambahan yang ditemukan',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTindakanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 6: Tindakan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'tindakan_yang_dilakukan',
          label: 'Tindakan Yang Dilakukan',
          tooltip: 'Tindakan medis yang telah dilakukan terhadap pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'tindakan_medis',
          label: 'Tindakan Medis',
          tooltip: 'Tindakan medis spesifik yang dilakukan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'tindakan_keperawatan',
          label: 'Tindakan Keperawatan',
          tooltip: 'Tindakan keperawatan yang dilakukan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'terapi_psikososial',
          label: 'Terapi Psikososial',
          tooltip: 'Terapi psikososial yang diberikan kepada pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'terapi_obat',
          label: 'Terapi Obat',
          tooltip: 'Obat-obatan yang diberikan kepada pasien',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildImplementasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 7: Implementasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'pelaksanaan_intervensi',
          label: 'Pelaksanaan Intervensi',
          tooltip: 'Deskripsi pelaksanaan intervensi terhadap pasien',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'kolaborasi_tim',
          label: 'Kolaborasi dengan Tim Lain',
          tooltip: 'Deskripsi kolaborasi dengan tenaga kesehatan lainnya',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'edukasi',
          label: 'Edukasi yang Diberikan',
          tooltip: 'Edukasi yang telah diberikan kepada pasien',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildEvaluasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 8: Evaluasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'respon_intervensi',
          label: 'Respon Terhadap Intervensi',
          tooltip: 'Respon pasien terhadap intervensi yang diberikan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'perubahan_klinis',
          label: 'Perubahan Klinis',
          tooltip: 'Perubahan klinis yang terjadi pada pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'tujuan_tercapai',
          label: 'Tujuan yang Telah Tercapai',
          tooltip: 'Tujuan perawatan yang telah berhasil dicapai',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'hambatan_perawatan',
          label: 'Hambatan dalam Perawatan',
          tooltip: 'Hambatan-hambatan yang ditemui dalam proses perawatan',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRencanaLanjutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 9: Rencana Tindak Lanjut',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          name: 'kondisi_keluar',
          label: 'Kondisi Keluar',
          tooltip: 'Kondisi pasien saat pulang dari fasilitas kesehatan',
          items: const [
            DropdownMenuItem(value: 'Membaik', child: Text('Membaik')),
            DropdownMenuItem(value: 'Belum Membaik', child: Text('Belum Membaik')),
            DropdownMenuItem(value: 'Meninggal', child: Text('Meninggal')),
            DropdownMenuItem(value: 'Pulang Paksa', child: Text('Pulang Paksa')),
          ],
          hint: 'Pilih Kondisi Keluar',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'anjuran',
          label: 'Anjuran',
          tooltip: 'Anjuran atau nasihat yang diberikan saat pasien pulang',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'rencana_medis',
          label: 'Rencana Medis Lanjutan',
          tooltip: 'Rencana medis yang akan dilakukan setelah pasien pulang',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'rencana_keperawatan',
          label: 'Rencana Keperawatan Lanjutan',
          tooltip: 'Rencana keperawatan yang akan dilakukan setelah pasien pulang',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'rencana_pemantauan',
          label: 'Rencana Pemantauan',
          tooltip: 'Rencana pemantauan kondisi pasien setelah pulang',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRencanaKeluargaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 10: Rencana dengan Keluarga',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'keterlibatan_keluarga',
          label: 'Keterlibatan Keluarga',
          tooltip: 'Deskripsi keterlibatan keluarga dalam perawatan pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'edukasi_keluarga',
          label: 'Edukasi untuk Keluarga',
          tooltip: 'Edukasi yang diberikan kepada keluarga pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'dukungan_keluarga',
          label: 'Dukungan dari Keluarga',
          tooltip: 'Deskripsi dukungan yang diberikan oleh keluarga kepada pasien',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRenpraSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 11: Rencana Perawatan (Renpra)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final nursingService = Get.find<NursingDataGlobalService>();
          final diagnoses = nursingService.diagnoses;
          if (diagnoses.isEmpty) {
            return const Text('Tidak ada diagnosis tersedia');
          }

          return CustomDropdown<int>(
            name: 'diagnosis',
            label: 'Diagnosis Keperawatan',
            tooltip: 'Pilih diagnosis keperawatan yang sesuai',
            items: diagnoses
                .map(
                  (diag) =>
                      DropdownMenuItem(value: diag.id, child: Text(diag.name)),
                )
                .toList(),
            hint: 'Pilih Diagnosis',
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          final interventions = _interventionController.interventions;
          if (interventions.isEmpty) {
            return const Text('Tidak ada intervensi tersedia');
          }

          return CustomCheckboxGroup<int>(
            name: 'intervensi',
            label: 'Intervensi',
            tooltip: 'Pilih intervensi yang akan dilakukan',
            options: interventions
                .map(
                  (iv) => FormBuilderFieldOption(
                    value: iv.id,
                    child: Text(iv.name),
                  ),
                )
                .toList(),
          );
        }),
        const SizedBox(height: 16),
        const CustomTextField(name: 'tujuan', label: 'Tujuan', tooltip: 'Tujuan perawatan yang ingin dicapai', maxLines: 3),
        const SizedBox(height: 16),
        const CustomTextField(name: 'kriteria', label: 'Kriteria', tooltip: 'Kriteria untuk mengevaluasi pencapaian tujuan', maxLines: 3),
        const SizedBox(height: 16),
        const CustomTextField(name: 'rasional', label: 'Rasional', tooltip: 'Alasan atau landasan mengapa intervensi dipilih', maxLines: 3),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'evaluasi_renpra',
          label: 'Evaluasi',
          tooltip: 'Evaluasi terhadap pencapaian tujuan perawatan',
          maxLines: 3,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.formId == null
              ? 'Resume Kegawatdaruratan Psikiatri'
              : 'Edit Resume',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_currentSection + 1) / 11),
            const SizedBox(height: 16),
            Text('Section ${_currentSection + 1} dari 11'),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: formKey,
                  initialValue: initialValues,
                  child: _buildSection(_currentSection),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentSection > 0)
                  ElevatedButton(
                    onPressed: _previousSection,
                    child: const Text('Sebelumnya'),
                  )
                else
                  const SizedBox.shrink(),
                if (_currentSection == 10)
                  Expanded(child: buildActionButtons())
                else
                  ElevatedButton(
                    onPressed: _nextSection,
                    child: const Text('Selanjutnya'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}