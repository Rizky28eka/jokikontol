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

class ResumePoliklinikFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const ResumePoliklinikFormView({super.key, this.patient, this.formId});

  @override
  State<ResumePoliklinikFormView> createState() => _ResumePoliklinikFormViewState();
}

class _ResumePoliklinikFormViewState extends State<ResumePoliklinikFormView> with FormBuilderMixin {
  @override
  final FormController formController = Get.put(FormController());
  @override
  final PatientController patientController = Get.find();
  final NursingInterventionController _interventionController = Get.put(NursingInterventionController());

  int _currentSection = 0;
  final int _totalSections = 10;

  @override
  String get formType => 'resume_poliklinik';

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
    _currentPatientId = _currentPatient?.id ?? Get.arguments?['patientId'] as int?;

    final formDataArg = Get.arguments?['formData'] as Map<String, dynamic>?;
    if (formDataArg != null) {
      initialValues = transformInitialData(formDataArg);
    }

    initializeForm(
      patient: _currentPatient,
      patientId: _currentPatientId,
      formId: formId,
    );
  }

  @override
  Map<String, dynamic> transformInitialData(Map<String, dynamic> data) {
    // The reverse mapper has already flattened the data.
    return data;
  }

  @override
  Map<String, dynamic> transformFormData(Map<String, dynamic> formData) {
    // The forward mapper will handle the complex transformation.
    // The mixin's transform handles generic conversions like DateTime.
    return super.transformFormData(formData);
  }
  void _nextSection() {
    updateFormData();
    if (_currentSection < _totalSections - 1) {
      setState(() => _currentSection++);
    }
  }

  void _previousSection() {
    updateFormData();
    if (_currentSection > 0) {
      setState(() => _currentSection--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Resume Poliklinik'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentSection + 1) / _totalSections,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          ),
        ),
      ),
      body: FormBuilder(
        key: formKey,
        initialValue: initialValues,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey('section_$_currentSection'),
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
                child: _buildSection(context, _currentSection),
              ),
            ),
            _buildBottomActionBar(colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, int sectionNumber) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String title;
    Widget content;

    switch (sectionNumber) {
      case 0:
        title = 'Identitas Klien';
        content = _buildIdentitasSection(colorScheme);
        break;
      case 1:
        title = 'Riwayat Kehidupan';
        content = _buildRiwayatKehidupanSection(colorScheme);
        break;
      case 2:
        title = 'Riwayat Psikososial';
        content = _buildRiwayatPsikososialSection(colorScheme);
        break;
      case 3:
        title = 'Riwayat Psikiatri';
        content = _buildRiwayatPsikiatriSection(colorScheme);
        break;
      case 4:
        title = 'Pemeriksaan Psikologis';
        content = _buildPemeriksaanPsikologisSection(colorScheme);
        break;
      case 5:
        title = 'Fungsi Psikologis';
        content = _buildFungsiPsikologisSection(colorScheme);
        break;
      case 6:
        title = 'Fungsi Sosial';
        content = _buildFungsiSosialSection(colorScheme);
        break;
      case 7:
        title = 'Fungsi Spiritual';
        content = _buildFungsiSpiritualSection(colorScheme);
        break;
      case 8:
        title = 'Rencana Perawatan';
        content = _buildRenpraSection(colorScheme);
        break;
      case 9:
        title = 'Penutup';
        content = _buildPenutupSection(colorScheme);
        break;
      default:
        return const SizedBox.shrink();
    }

    return _buildInfoCard(
      colorScheme: colorScheme,
      textTheme: textTheme,
      title: 'Bagian ${sectionNumber + 1}: $title',
      child: content,
    );
  }

  Widget _buildIdentitasSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(name: 'nama_lengkap', label: 'Nama Lengkap', tooltip: 'Nama lengkap pasien'),
        const SizedBox(height: 20),
        CustomTextField(name: 'umur', label: 'Umur', tooltip: 'Usia pasien dalam tahun', keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        CustomDropdown<String>(
          name: 'jenis_kelamin',
          label: 'Jenis Kelamin',
          tooltip: 'Jenis kelamin pasien',
          items: const [
            DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
            DropdownMenuItem(value: 'P', child: Text('Perempuan')),
          ],
        ),
        const SizedBox(height: 20),
        CustomDropdown<String>(
          name: 'status_perkawinan',
          label: 'Status Perkawinan',
          tooltip: 'Status perkawinan pasien saat ini',
          items: const [
            DropdownMenuItem(value: 'belum_kawin', child: Text('Belum Kawin')),
            DropdownMenuItem(value: 'menikah', child: Text('Menikah')),
            DropdownMenuItem(value: 'cerai', child: Text('Cerai')),
            DropdownMenuItem(value: 'duda', child: Text('Duda')),
            DropdownMenuItem(value: 'janda', child: Text('Janda')),
          ],
        ),
      ],
    );
  }

  Widget _buildRiwayatKehidupanSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(name: 'riwayat_pendidikan', label: 'Riwayat Pendidikan', tooltip: 'Riwayat pendidikan yang pernah ditempuh pasien', maxLines: 3),
        const SizedBox(height: 20),
        CustomTextField(name: 'pekerjaan', label: 'Pekerjaan', tooltip: 'Pekerjaan pasien saat ini'),
        const SizedBox(height: 20),
        CustomTextField(name: 'riwayat_keluarga', label: 'Riwayat Keluarga', tooltip: 'Kondisi dan hubungan dalam keluarga pasien', maxLines: 3),
      ],
    );
  }

  Widget _buildRiwayatPsikososialSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(name: 'hubungan_sosial', label: 'Hubungan Sosial', tooltip: 'Hubungan pasien dengan lingkungan sosialnya', maxLines: 3),
        const SizedBox(height: 20),
        CustomTextField(name: 'dukungan_sosial', label: 'Dukungan Sosial', tooltip: 'Jenis dukungan yang diterima pasien dari lingkungan', maxLines: 3),
        const SizedBox(height: 20),
        CustomTextField(name: 'stresor_psikososial', label: 'Stresor Psikososial', tooltip: 'Faktor-faktor yang menyebabkan stres pada pasien', maxLines: 3),
      ],
    );
  }

  Widget _buildRiwayatPsikiatriSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(name: 'riwayat_gangguan_psikiatri', label: 'Riwayat Gangguan Psikiatri', tooltip: 'Riwayat gangguan psikiatri sebelumnya pada pasien', maxLines: 3),
        const SizedBox(height: 20),
        CustomTextField(name: 'riwayat_pengobatan', label: 'Riwayat Pengobatan', tooltip: 'Riwayat pengobatan psikiatri yang pernah diterima pasien', maxLines: 3),
      ],
    );
  }

  Widget _buildPemeriksaanPsikologisSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(name: 'kesadaran', label: 'Kesadaran', tooltip: 'Tingkat kesadaran pasien saat pemeriksaan'),
        const SizedBox(height: 20),
        CustomTextField(name: 'orientasi', label: 'Orientasi', tooltip: 'Kemampuan pasien mengenal diri dan lingkungan'),
        const SizedBox(height: 20),
        CustomTextField(name: 'penampilan', label: 'Penampilan', tooltip: 'Deskripsi penampilan fisik pasien'),
      ],
    );
  }

  Widget _buildFungsiPsikologisSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(name: 'mood', label: 'Mood', tooltip: 'Perasaan umum pasien dalam periode waktu tertentu'),
        const SizedBox(height: 20),
        CustomTextField(name: 'afect', label: 'Afect', tooltip: 'Ekspresi emosional yang dapat diamati pada pasien'),
        const SizedBox(height: 20),
        CustomTextField(name: 'alam_pikiran', label: 'Alam Pikiran', tooltip: 'Isi pikiran yang dipercakapkan pasien'),
      ],
    );
  }

  Widget _buildFungsiSosialSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(name: 'fungsi_sosial', label: 'Fungsi Sosial', tooltip: 'Kemampuan pasien dalam berinteraksi sosial', maxLines: 3),
        const SizedBox(height: 20),
        CustomTextField(name: 'interaksi_sosial', label: 'Interaksi Sosial', tooltip: 'Cara pasien berinteraksi dengan orang lain', maxLines: 3),
      ],
    );
  }

  Widget _buildFungsiSpiritualSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(name: 'kepercayaan', label: 'Kepercayaan', tooltip: 'Keyakinan atau kepercayaan yang dianut pasien'),
        const SizedBox(height: 20),
        CustomTextField(name: 'praktik_ibadah', label: 'Praktik Ibadah', tooltip: 'Aktivitas keagamaan atau spiritual yang dilakukan pasien'),
      ],
    );
  }

  Widget _buildRenpraSection(ColorScheme colorScheme) {
    final nursingService = Get.find<NursingDataGlobalService>();
    return Column(
      children: [
        Obx(() {
          final diagnoses = nursingService.diagnoses;
          if (diagnoses.isEmpty) return const Center(child: Text('Data diagnosis tidak tersedia.'));
          return CustomDropdown<int>(
            name: 'diagnosis',
            label: 'Diagnosis',
            tooltip: 'Pilih diagnosis keperawatan yang sesuai',
            items: diagnoses.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
          );
        }),
        const SizedBox(height: 20),
        Obx(() {
          final interventions = _interventionController.interventions;
          if (interventions.isEmpty) return const Center(child: Text('Tidak ada intervensi tersedia.'));
          final options = interventions.map((iv) => FormBuilderFieldOption(value: iv.id, child: Text(iv.name))).toList();
          return CustomCheckboxGroup<int>(name: 'intervensi', label: 'Intervensi', tooltip: 'Pilih intervensi yang akan dilakukan', options: options);
        }),
        const SizedBox(height: 20),
        CustomTextField(name: 'tujuan', label: 'Tujuan', tooltip: 'Tujuan perawatan yang ingin dicapai', maxLines: 3),
        const SizedBox(height: 20),
        CustomTextField(name: 'kriteria', label: 'Kriteria Evaluasi', tooltip: 'Kriteria untuk mengevaluasi pencapaian tujuan', maxLines: 3),
        const SizedBox(height: 20),
        CustomTextField(name: 'rasional', label: 'Rasional', tooltip: 'Alasan atau landasan mengapa intervensi dipilih', maxLines: 3),
      ],
    );
  }

  Widget _buildPenutupSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(name: 'catatan_tambahan', label: 'Catatan Tambahan', tooltip: 'Catatan tambahan atau informasi penting lainnya', maxLines: 5),
        const SizedBox(height: 20),
        CustomDateTimePicker(
          name: 'tanggal_pengisian',
          label: 'Tanggal Pengisian',
          tooltip: 'Tanggal formulir ini diisi',
          inputType: InputType.date,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required ColorScheme colorScheme, required TextTheme textTheme, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentSection > 0)
            TextButton.icon(
              onPressed: _previousSection,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              label: const Text('Sebelumnya'),
              style: TextButton.styleFrom(foregroundColor: colorScheme.onSurface),
            ),
          const Spacer(),
          SizedBox(
            height: 52,
            child: Obx(
              () => FilledButton.icon(
                onPressed: formController.isLoading ? null : (_currentSection == _totalSections - 1 ? submitForm : _nextSection),
                icon: formController.isLoading ? const SizedBox.shrink() : Icon(_currentSection == _totalSections - 1 ? Icons.save_alt_rounded : Icons.arrow_forward_ios_rounded),
                label: formController.isLoading
                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: colorScheme.onPrimary))
                    : Text(_currentSection == _totalSections - 1 ? 'Simpan' : 'Selanjutnya'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}