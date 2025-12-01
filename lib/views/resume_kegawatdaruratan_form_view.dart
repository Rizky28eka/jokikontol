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

  @override
  Map<String, dynamic> transformInitialData(Map<String, dynamic> data) {
    return {
      // Section 1: Identitas
      'nama_lengkap': data['identitas']?['nama_lengkap'],
      'umur': data['identitas']?['umur'],
      'jenis_kelamin': data['identitas']?['jenis_kelamin'],
      'alamat': data['identitas']?['alamat'],
      'tanggal_masuk': data['identitas']?['tanggal_masuk'],
      // Section 2: Riwayat Keluhan
      'keluhan_utama': data['riwayat_keluhan']?['keluhan_utama'],
      'riwayat_penyakit_sekarang':
          data['riwayat_keluhan']?['riwayat_penyakit_sekarang'],
      'faktor_pencetus': data['riwayat_keluhan']?['faktor_pencetus'],
      // Section 3: Pemeriksaan Fisik
      'keadaan_umum': data['pemeriksaan_fisik']?['keadaan_umum'],
      'tanda_vital': data['pemeriksaan_fisik']?['tanda_vital'],
      'pemeriksaan_lain': data['pemeriksaan_fisik']?['pemeriksaan_lain'],
      // Section 4: Status Mental
      'kesadaran': data['status_mental']?['kesadaran'],
      'orientasi': data['status_mental']?['orientasi'],
      'bentuk_pemikiran': data['status_mental']?['bentuk_pemikiran'],
      'isi_pemikiran': data['status_mental']?['isi_pemikiran'],
      'persepsi': data['status_mental']?['persepsi'],
      // Section 5: Diagnosis
      'diagnosis_utama': data['diagnosis']?['diagnosis_utama'],
      'diagnosis_banding': data['diagnosis']?['diagnosis_banding'],
      'diagnosis_tambahan': data['diagnosis']?['diagnosis_tambahan'],
      // Section 6: Tindakan
      'tindakan_medis': data['tindakan']?['tindakan_medis'],
      'tindakan_keperawatan': data['tindakan']?['tindakan_keperawatan'],
      'terapi_psikososial': data['tindakan']?['terapi_psikososial'],
      // Section 7: Implementasi
      'pelaksanaan_intervensi': data['implementasi']?['pelaksanaan_intervensi'],
      'kolaborasi_tim': data['implementasi']?['kolaborasi_tim'],
      'edukasi': data['implementasi']?['edukasi'],
      // Section 8: Evaluasi
      'respon_intervensi': data['evaluasi']?['respon_intervensi'],
      'perubahan_klinis': data['evaluasi']?['perubahan_klinis'],
      'tujuan_tercapai': data['evaluasi']?['tujuan_tercapai'],
      'hambatan_perawatan': data['evaluasi']?['hambatan_perawatan'],
      // Section 9: Rencana Lanjut
      'rencana_medis': data['rencana_lanjut']?['rencana_medis'],
      'rencana_keperawatan': data['rencana_lanjut']?['rencana_keperawatan'],
      'rencana_pemantauan': data['rencana_lanjut']?['rencana_pemantauan'],
      // Section 10: Rencana Keluarga
      'keterlibatan_keluarga':
          data['rencana_keluarga']?['keterlibatan_keluarga'],
      'edukasi_keluarga': data['rencana_keluarga']?['edukasi_keluarga'],
      'dukungan_keluarga': data['rencana_keluarga']?['dukungan_keluarga'],
      // Section 11: Renpra
      'diagnosis': data['renpra']?['diagnosis'],
      'intervensi': data['renpra']?['intervensi'] ?? [],
      'tujuan': data['renpra']?['tujuan'],
      'kriteria': data['renpra']?['kriteria'],
      'rasional': data['renpra']?['rasional'],
      'evaluasi_renpra': data['renpra']?['evaluasi'],
    };
  }

  @override
  Map<String, dynamic> transformFormData(Map<String, dynamic> formData) {
    return {
      'identitas': {
        'nama_lengkap': formData['nama_lengkap'],
        'umur': formData['umur'],
        'jenis_kelamin': formData['jenis_kelamin'],
        'alamat': formData['alamat'],
        'tanggal_masuk': formData['tanggal_masuk'],
      },
      'riwayat_keluhan': {
        'keluhan_utama': formData['keluhan_utama'],
        'riwayat_penyakit_sekarang': formData['riwayat_penyakit_sekarang'],
        'faktor_pencetus': formData['faktor_pencetus'],
      },
      'pemeriksaan_fisik': {
        'keadaan_umum': formData['keadaan_umum'],
        'tanda_vital': formData['tanda_vital'],
        'pemeriksaan_lain': formData['pemeriksaan_lain'],
      },
      'status_mental': {
        'kesadaran': formData['kesadaran'],
        'orientasi': formData['orientasi'],
        'bentuk_pemikiran': formData['bentuk_pemikiran'],
        'isi_pemikiran': formData['isi_pemikiran'],
        'persepsi': formData['persepsi'],
      },
      'diagnosis': {
        'diagnosis_utama': formData['diagnosis_utama'],
        'diagnosis_banding': formData['diagnosis_banding'],
        'diagnosis_tambahan': formData['diagnosis_tambahan'],
      },
      'tindakan': {
        'tindakan_medis': formData['tindakan_medis'],
        'tindakan_keperawatan': formData['tindakan_keperawatan'],
        'terapi_psikososial': formData['terapi_psikososial'],
      },
      'implementasi': {
        'pelaksanaan_intervensi': formData['pelaksanaan_intervensi'],
        'kolaborasi_tim': formData['kolaborasi_tim'],
        'edukasi': formData['edukasi'],
      },
      'evaluasi': {
        'respon_intervensi': formData['respon_intervensi'],
        'perubahan_klinis': formData['perubahan_klinis'],
        'tujuan_tercapai': formData['tujuan_tercapai'],
        'hambatan_perawatan': formData['hambatan_perawatan'],
      },
      'rencana_lanjut': {
        'rencana_medis': formData['rencana_medis'],
        'rencana_keperawatan': formData['rencana_keperawatan'],
        'rencana_pemantauan': formData['rencana_pemantauan'],
      },
      'rencana_keluarga': {
        'keterlibatan_keluarga': formData['keterlibatan_keluarga'],
        'edukasi_keluarga': formData['edukasi_keluarga'],
        'dukungan_keluarga': formData['dukungan_keluarga'],
      },
      'renpra': formData['diagnosis'] != null
          ? {
              'diagnosis': formData['diagnosis'],
              'intervensi': formData['intervensi'],
              'tujuan': formData['tujuan'],
              'kriteria': formData['kriteria'],
              'rasional': formData['rasional'],
              'evaluasi': formData['evaluasi_renpra'],
            }
          : null,
    };
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
        const CustomTextField(name: 'nama_lengkap', label: 'Nama Lengkap'),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'umur',
          label: 'Umur',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          name: 'jenis_kelamin',
          label: 'Jenis Kelamin',
          items: const [
            DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
            DropdownMenuItem(value: 'P', child: Text('Perempuan')),
            DropdownMenuItem(value: 'O', child: Text('Lainnya')),
          ],
          hint: 'Pilih Jenis Kelamin',
        ),
        const SizedBox(height: 16),
        const CustomTextField(name: 'alamat', label: 'Alamat', maxLines: 2),
        const SizedBox(height: 16),
        CustomDateTimePicker(
          name: 'tanggal_masuk',
          label: 'Tanggal Masuk',
          inputType: InputType.date,
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
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'riwayat_penyakit_sekarang',
          label: 'Riwayat Penyakit Sekarang',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'faktor_pencetus',
          label: 'Faktor Pencetus',
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
        const CustomTextField(name: 'keadaan_umum', label: 'Keadaan Umum'),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'tanda_vital',
          label: 'Tanda-tanda Vital',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'pemeriksaan_lain',
          label: 'Pemeriksaan Fisik Lain',
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
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'isi_pemikiran',
          label: 'Isi Pemikiran',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(name: 'persepsi', label: 'Persepsi', maxLines: 3),
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
          name: 'diagnosis_utama',
          label: 'Diagnosis Utama',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'diagnosis_banding',
          label: 'Diagnosis Banding',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'diagnosis_tambahan',
          label: 'Diagnosis Tambahan',
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
          name: 'tindakan_medis',
          label: 'Tindakan Medis',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'tindakan_keperawatan',
          label: 'Tindakan Keperawatan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'terapi_psikososial',
          label: 'Terapi Psikososial',
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
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'kolaborasi_tim',
          label: 'Kolaborasi dengan Tim Lain',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'edukasi',
          label: 'Edukasi yang Diberikan',
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
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'perubahan_klinis',
          label: 'Perubahan Klinis',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'tujuan_tercapai',
          label: 'Tujuan yang Telah Tercapai',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'hambatan_perawatan',
          label: 'Hambatan dalam Perawatan',
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
        const CustomTextField(
          name: 'rencana_medis',
          label: 'Rencana Medis Lanjutan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'rencana_keperawatan',
          label: 'Rencana Keperawatan Lanjutan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'rencana_pemantauan',
          label: 'Rencana Pemantauan',
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
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'edukasi_keluarga',
          label: 'Edukasi untuk Keluarga',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'dukungan_keluarga',
          label: 'Dukungan dari Keluarga',
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
        const CustomTextField(name: 'tujuan', label: 'Tujuan', maxLines: 3),
        const SizedBox(height: 16),
        const CustomTextField(name: 'kriteria', label: 'Kriteria', maxLines: 3),
        const SizedBox(height: 16),
        const CustomTextField(name: 'rasional', label: 'Rasional', maxLines: 3),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'evaluasi_renpra',
          label: 'Evaluasi',
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
