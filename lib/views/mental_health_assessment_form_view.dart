import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../models/patient_model.dart';
import '../services/nursing_data_global_service.dart';
import '../utils/form_builder_mixin.dart';
import '../widgets/form_components/custom_checkbox_group.dart';
import '../widgets/form_components/custom_date_time_picker.dart';

class MentalHealthAssessmentFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const MentalHealthAssessmentFormView({super.key, this.patient, this.formId});

  @override
  State<MentalHealthAssessmentFormView> createState() =>
      _MentalHealthAssessmentFormViewState();
}

class _MentalHealthAssessmentFormViewState
    extends State<MentalHealthAssessmentFormView>
    with FormBuilderMixin {
  @override
  final FormController formController = Get.put(FormController());
  @override
  final PatientController patientController = Get.find();
  final NursingInterventionController _interventionController = Get.put(
    NursingInterventionController(),
  );

  int _currentSection = 0;
  final int _totalSections = 11;

  @override
  String get formType => 'pengkajian';

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
        title: const Text('Pengkajian Kesehatan Jiwa'),
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
        content = _buildIdentitasKlienSection(colorScheme);
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
        title = 'Genogram';
        content = _buildGenogramSection(colorScheme);
        break;
      case 9:
        title = 'Rencana Perawatan (Renpra)';
        content = _buildRenpraSection(colorScheme);
        break;
      case 10:
        title = 'Penutup';
        content = _buildPenutupSection(colorScheme);
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return Container(
      key: ValueKey('section_content_$sectionNumber'),
      child: _buildInfoCard(
        colorScheme: colorScheme,
        textTheme: textTheme,
        title: 'Bagian ${sectionNumber + 1}: $title',
        child: content,
      ),
    );
  }

  Widget _buildIdentitasKlienSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildTextField(name: 'nama_lengkap', label: 'Nama Lengkap', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextField(name: 'umur', label: 'Umur', keyboardType: TextInputType.number, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildDropdown<String>(name: 'jenis_kelamin', label: 'Jenis Kelamin', items: const [
          DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
          DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
        ], colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildDropdown<String>(name: 'status_perkawinan', label: 'Status Perkawinan', items: const [
          DropdownMenuItem(value: 'belum_kawin', child: Text('Belum Kawin')),
          DropdownMenuItem(value: 'menikah', child: Text('Menikah')),
          DropdownMenuItem(value: 'cerai_hidup', child: Text('Cerai Hidup')),
          DropdownMenuItem(value: 'cerai_mati', child: Text('Cerai Mati')),
          DropdownMenuItem(value: 'duda', child: Text('Duda')),
          DropdownMenuItem(value: 'janda', child: Text('Janda')),
        ], colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildRiwayatKehidupanSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildTextField(name: 'riwayat_pendidikan', label: 'Riwayat Pendidikan', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextField(name: 'pekerjaan', label: 'Pekerjaan', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextField(name: 'riwayat_keluarga', label: 'Riwayat Keluarga', maxLines: 3, colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildRiwayatPsikososialSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildTextField(name: 'hubungan_sosial', label: 'Hubungan Sosial', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextField(name: 'dukungan_sosial', label: 'Dukungan Sosial', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextField(name: 'stresor_psikososial', label: 'Stresor Psikososial', maxLines: 3, colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildRiwayatPsikiatriSection(ColorScheme colorScheme) {
    return _buildTextField(name: 'riwayat_gangguan_psikiatri', label: 'Riwayat Gangguan Psikiatri', maxLines: 3, colorScheme: colorScheme);
  }

  Widget _buildPemeriksaanPsikologisSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildDropdown<String>(name: 'kesadaran', label: 'Kesadaran', items: const [
          DropdownMenuItem(value: 'sadar_penuh', child: Text('Sadar Penuh')),
          DropdownMenuItem(value: 'somnolent', child: Text('Somnolent')),
          DropdownMenuItem(value: 'stupor', child: Text('Stupor')),
          DropdownMenuItem(value: 'coma', child: Text('Coma')),
        ], colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildDropdown<String>(name: 'orientasi', label: 'Orientasi', items: const [
          DropdownMenuItem(value: 'utuh', child: Text('Utuh')),
          DropdownMenuItem(value: 'gangguan', child: Text('Gangguan')),
        ], colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextField(name: 'penampilan', label: 'Penampilan', colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildFungsiPsikologisSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildDropdown<String>(name: 'mood', label: 'Mood', items: const [
          DropdownMenuItem(value: 'normal', child: Text('Normal')),
          DropdownMenuItem(value: 'depresi', child: Text('Depresi')),
          DropdownMenuItem(value: 'ansietas', child: Text('Ansietas')),
          DropdownMenuItem(value: 'iritabel', child: Text('Iritabel')),
          DropdownMenuItem(value: 'labil', child: Text('Labil')),
        ], colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildDropdown<String>(name: 'afect', label: 'Afect', items: const [
          DropdownMenuItem(value: 'normal', child: Text('Normal')),
          DropdownMenuItem(value: 'flat', child: Text('Flat')),
          DropdownMenuItem(value: 'terhambat', child: Text('Terhambat')),
          DropdownMenuItem(value: 'labil', child: Text('Labil')),
          DropdownMenuItem(value: 'iritabel', child: Text('Iritabel')),
        ], colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextField(name: 'alam_pikiran', label: 'Alam Pikiran', colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildFungsiSosialSection(ColorScheme colorScheme) {
    return _buildTextField(name: 'fungsi_sosial', label: 'Fungsi Sosial', maxLines: 3, colorScheme: colorScheme);
  }

  Widget _buildFungsiSpiritualSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildTextField(name: 'kepercayaan', label: 'Kepercayaan', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextField(name: 'praktik_ibadah', label: 'Praktik Ibadah', colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildGenogramSection(ColorScheme colorScheme) {
    final structure = formKey.currentState?.fields['genogram_structure']?.value;
    final notes = formKey.currentState?.fields['genogram_notes']?.value ?? '';
    final List members = structure != null && structure is Map ? (structure['members'] ?? []) as List : [];
    
    return Column(
      children: [
        FormBuilderField<Map<String, dynamic>>(name: 'genogram_structure', builder: (field) => const SizedBox.shrink()),
        _buildTextField(name: 'genogram_notes', label: 'Catatan Genogram', maxLines: 4, colorScheme: colorScheme),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () async {
              final result = await Get.toNamed('/genogram-builder', arguments: {'structure': structure ?? {'members': [], 'connections': []}, 'notes': notes});
              if (result != null && result is Map<String, dynamic>) {
                formKey.currentState?.fields['genogram_structure']?.didChange(result['structure'] ?? result);
                formKey.currentState?.fields['genogram_notes']?.didChange(result['notes'] ?? '');
                setState(() {});
              }
            },
            icon: const Icon(Icons.family_restroom_rounded),
            label: Text(members.isEmpty ? 'Buka Genogram Builder' : 'Edit Genogram (${members.length} Anggota)'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
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
          return _buildDropdown<int>(name: 'diagnosis', label: 'Diagnosis', items: diagnoses.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(), colorScheme: colorScheme);
        }),
        const SizedBox(height: 20),
        _buildInterventionSection(colorScheme),
        const SizedBox(height: 20),
        _buildTextField(name: 'tujuan', label: 'Tujuan', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextField(name: 'kriteria', label: 'Kriteria Evaluasi', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextField(name: 'rasional', label: 'Rasional', maxLines: 3, colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildInterventionSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Intervensi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest.withOpacity(0.3), borderRadius: BorderRadius.circular(12), border: Border.all(color: colorScheme.outline.withOpacity(0.2), width: 1)),
          child: Obx(() {
            final interventions = _interventionController.interventions;
            if (interventions.isEmpty) return const Center(child: Text('Tidak ada intervensi tersedia.'));
            final options = interventions.map((iv) => FormBuilderFieldOption(value: iv.id, child: Text(iv.name))).toList();
            return CustomCheckboxGroup<int>(name: 'intervensi', label: '', options: options);
          }),
        ),
      ],
    );
  }

  Widget _buildPenutupSection(ColorScheme colorScheme) {
    final rawDate = initialValues['tanggal_pengisian'];
    DateTime? initialDate;
    if (rawDate is DateTime) {
      initialDate = rawDate;
    } else if (rawDate is String) {
      initialDate = DateTime.tryParse(rawDate);
    }

    return Column(
      children: [
        _buildTextField(name: 'catatan_tambahan', label: 'Catatan Tambahan', maxLines: 5, colorScheme: colorScheme),
        const SizedBox(height: 20),
        CustomDateTimePicker(
          name: 'tanggal_pengisian',
          label: 'Tanggal Pengisian',
          inputType: InputType.date,
          initialDate: initialDate ?? DateTime.now(),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        const SizedBox(height: 24),
        child,
      ]),
    );
  }

  Widget _buildTextField({required String name, required String label, required ColorScheme colorScheme, TextInputType? keyboardType, int? maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        const SizedBox(height: 8),
        FormBuilderTextField(
          name: name,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({required String name, required String label, required List<DropdownMenuItem<T>> items, required ColorScheme colorScheme, ValueChanged<T?>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        const SizedBox(height: 8),
        FormBuilderDropdown<T>(
          name: name,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
          ),
          dropdownColor: colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: colorScheme.surface, border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3), width: 1))),
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