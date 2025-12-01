import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/form_selection_controller.dart';
import '../controllers/patient_controller.dart';
import '../controllers/pdf_controller.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../models/patient_model.dart';
import '../services/nursing_data_global_service.dart';
import '../utils/form_builder_mixin.dart';
import '../widgets/form_components/custom_text_field.dart';
import '../widgets/form_components/custom_dropdown.dart';
import '../widgets/form_components/custom_checkbox_group.dart';

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

    final formDataArg = Get.arguments?['formData'] as Map<String, dynamic>?;
    if (formDataArg != null) {
      initialValues = transformInitialData(formDataArg);
    }

    initializeForm(
      patient: _currentPatient,
      patientId: _currentPatientId,
      formId: formId,
    );

    Future.microtask(() async {
      if (_currentPatientId != null)
        await _prefillGenogramFromPatient(_currentPatientId!);
    });
  }

  Future<void> _prefillGenogramFromPatient(int patientId) async {
    try {
      await formController.fetchForms(patientId: patientId);
      final formsWithGenogram = formController.forms
          .where((f) => f.patientId == patientId && f.genogram != null)
          .toList();
      if (formsWithGenogram.isNotEmpty) {
        final latest = formsWithGenogram.first;
        if (latest.genogram?.structure != null) {
          setState(() {
            formKey.currentState?.fields['genogram_structure']?.didChange(
              latest.genogram!.structure,
            );
            formKey.currentState?.fields['genogram_notes']?.didChange(
              latest.genogram!.notes,
            );
          });
        }
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Map<String, dynamic> transformInitialData(Map<String, dynamic> data) {
    return {
      'nama_lengkap': data['section_1']?['nama_lengkap'],
      'umur': data['section_1']?['umur'],
      'jenis_kelamin': data['section_1']?['jenis_kelamin'],
      'status_perkawinan': data['section_1']?['status_perkawinan'],
      'riwayat_pendidikan': data['section_2']?['riwayat_pendidikan'],
      'pekerjaan': data['section_2']?['pekerjaan'],
      'riwayat_keluarga': data['section_2']?['riwayat_keluarga'],
      'hubungan_sosial': data['section_3']?['hubungan_sosial'],
      'dukungan_sosial': data['section_3']?['dukungan_sosial'],
      'stresor_psikososial': data['section_3']?['stresor_psikososial'],
      'riwayat_gangguan_psikiatri':
          data['section_4']?['riwayat_gangguan_psikiatri'],
      'kesadaran': data['section_5']?['kesadaran'],
      'orientasi': data['section_5']?['orientasi'],
      'penampilan': data['section_5']?['penampilan'],
      'mood': data['section_6']?['mood'],
      'afect': data['section_6']?['afect'],
      'alam_pikiran': data['section_6']?['alam_pikiran'],
      'fungsi_sosial': data['section_7']?['fungsi_sosial'],
      'kepercayaan': data['section_8']?['kepercayaan'],
      'praktik_ibadah': data['section_8']?['praktik_ibadah'],
      'genogram_structure':
          data['section_9']?['structure'] ?? data['genogram']?['structure'],
      'genogram_notes':
          data['section_9']?['notes'] ?? data['genogram']?['notes'],
      'diagnosis': data['section_10']?['diagnosis'],
      'intervensi': data['section_10']?['intervensi'] ?? [],
      'tujuan': data['section_10']?['tujuan'],
      'kriteria': data['section_10']?['kriteria'],
      'rasional': data['section_10']?['rasional'],
      'catatan_tambahan': data['section_11']?['catatan_tambahan'],
      'tanggal_pengisian': data['section_11']?['tanggal_pengisian'],
    };
  }

  @override
  Map<String, dynamic> transformFormData(Map<String, dynamic> formData) {
    final result = {
      'section_1': {
        'nama_lengkap': formData['nama_lengkap'],
        'umur': formData['umur'],
        'jenis_kelamin': formData['jenis_kelamin'],
        'status_perkawinan': formData['status_perkawinan'],
      },
      'section_2': {
        'riwayat_pendidikan': formData['riwayat_pendidikan'],
        'pekerjaan': formData['pekerjaan'],
        'riwayat_keluarga': formData['riwayat_keluarga'],
      },
      'section_3': {
        'hubungan_sosial': formData['hubungan_sosial'],
        'dukungan_sosial': formData['dukungan_sosial'],
        'stresor_psikososial': formData['stresor_psikososial'],
      },
      'section_4': {
        'riwayat_gangguan_psikiatri': formData['riwayat_gangguan_psikiatri'],
      },
      'section_5': {
        'kesadaran': formData['kesadaran'],
        'orientasi': formData['orientasi'],
        'penampilan': formData['penampilan'],
      },
      'section_6': {
        'mood': formData['mood'],
        'afect': formData['afect'],
        'alam_pikiran': formData['alam_pikiran'],
      },
      'section_7': {'fungsi_sosial': formData['fungsi_sosial']},
      'section_8': {
        'kepercayaan': formData['kepercayaan'],
        'praktik_ibadah': formData['praktik_ibadah'],
      },
      'section_9': formData['genogram_structure'] != null
          ? {
              'structure': formData['genogram_structure'],
              'notes': formData['genogram_notes'],
            }
          : null,
      'section_10': formData['diagnosis'] != null
          ? {
              'diagnosis': formData['diagnosis'],
              'intervensi': formData['intervensi'],
              'tujuan': formData['tujuan'],
              'kriteria': formData['kriteria'],
              'rasional': formData['rasional'],
            }
          : null,
      'section_11': {
        'catatan_tambahan': formData['catatan_tambahan'],
        'tanggal_pengisian': formData['tanggal_pengisian'],
      },
    };

    // Add genogram at top level for backend
    if (formData['genogram_structure'] != null) {
      result['genogram'] = {
        'structure': formData['genogram_structure'],
        'notes': formData['genogram_notes'],
      };
    }

    return result;
  }

  void _nextSection() {
    if (_currentSection < 10) setState(() => _currentSection++);
  }

  void _previousSection() {
    if (_currentSection > 0) setState(() => _currentSection--);
  }

  Future<void> _exportToPdf() async {
    if (widget.formId == null) {
      Get.snackbar(
        'Cannot Export',
        'Please save the form first before exporting to PDF',
      );
      return;
    }
    final pdfController = Get.put(PdfController());
    final pdfUrl = await pdfController.generatePdfForForm(widget.formId!);
    if (pdfUrl != null) {
      Get.snackbar('Success', 'PDF generated successfully. URL: $pdfUrl');
    }
  }

  Widget _buildSection(int sectionNumber) {
    switch (sectionNumber) {
      case 0:
        return _buildIdentitasKlienSection();
      case 1:
        return _buildRiwayatKehidupanSection();
      case 2:
        return _buildRiwayatPsikososialSection();
      case 3:
        return _buildRiwayatPsikiatriSection();
      case 4:
        return _buildPemeriksaanPsikologisSection();
      case 5:
        return _buildFungsiPsikologisSection();
      case 6:
        return _buildFungsiSosialSection();
      case 7:
        return _buildFungsiSpiritualSection();
      case 8:
        return _buildGenogramSection();
      case 9:
        return _buildRenpraSection();
      case 10:
        return _buildPenutupSection();
      default:
        return const SizedBox();
    }
  }

  Widget _buildIdentitasKlienSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 1: Identitas Klien',
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
        CustomDropdown<String>(
          name: 'status_perkawinan',
          label: 'Status Perkawinan',
          items: const [
            DropdownMenuItem(value: 'belum_kawin', child: Text('Belum Kawin')),
            DropdownMenuItem(value: 'menikah', child: Text('Menikah')),
            DropdownMenuItem(value: 'cerai_hidup', child: Text('Cerai Hidup')),
            DropdownMenuItem(value: 'cerai_mati', child: Text('Cerai Mati')),
            DropdownMenuItem(value: 'duda', child: Text('Duda')),
            DropdownMenuItem(value: 'janda', child: Text('Janda')),
          ],
          hint: 'Pilih Status Perkawinan',
        ),
      ],
    );
  }

  Widget _buildRiwayatKehidupanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 2: Riwayat Kehidupan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'riwayat_pendidikan',
          label: 'Riwayat Pendidikan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(name: 'pekerjaan', label: 'Pekerjaan'),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'riwayat_keluarga',
          label: 'Riwayat Keluarga',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRiwayatPsikososialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 3: Riwayat Psikososial',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'hubungan_sosial',
          label: 'Hubungan Sosial',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'dukungan_sosial',
          label: 'Dukungan Sosial',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'stresor_psikososial',
          label: 'Stresor Psikososial',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRiwayatPsikiatriSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 4: Riwayat Psikiatri',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'riwayat_gangguan_psikiatri',
          label: 'Riwayat Gangguan Psikiatri',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPemeriksaanPsikologisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 5: Pemeriksaan Psikologis',
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
        const CustomTextField(name: 'penampilan', label: 'Penampilan'),
      ],
    );
  }

  Widget _buildFungsiPsikologisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 6: Fungsi Psikologis',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          name: 'mood',
          label: 'Mood',
          items: const [
            DropdownMenuItem(value: 'normal', child: Text('Normal')),
            DropdownMenuItem(value: 'depresi', child: Text('Depresi')),
            DropdownMenuItem(value: 'ansietas', child: Text('Ansietas')),
            DropdownMenuItem(value: 'iritabel', child: Text('Iritabel')),
            DropdownMenuItem(value: 'labil', child: Text('Labil')),
          ],
          hint: 'Pilih Mood',
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          name: 'afect',
          label: 'Afect',
          items: const [
            DropdownMenuItem(value: 'normal', child: Text('Normal')),
            DropdownMenuItem(value: 'flat', child: Text('Flat')),
            DropdownMenuItem(value: 'terhambat', child: Text('Terhambat')),
            DropdownMenuItem(value: 'labil', child: Text('Labil')),
            DropdownMenuItem(value: 'iritabel', child: Text('Iritabel')),
          ],
          hint: 'Pilih Afect',
        ),
        const SizedBox(height: 16),
        const CustomTextField(name: 'alam_pikiran', label: 'Alam Pikiran'),
      ],
    );
  }

  Widget _buildFungsiSosialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 7: Fungsi Sosial',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'fungsi_sosial',
          label: 'Fungsi Sosial',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildFungsiSpiritualSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 8: Fungsi Spiritual',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const CustomTextField(name: 'kepercayaan', label: 'Kepercayaan'),
        const SizedBox(height: 16),
        const CustomTextField(name: 'praktik_ibadah', label: 'Praktik Ibadah'),
      ],
    );
  }

  Widget _buildGenogramSection() {
    final structure = formKey.currentState?.fields['genogram_structure']?.value;
    final List members = structure != null && structure is Map
        ? (structure['members'] ?? []) as List
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 9: Genogram',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (members.isEmpty)
          const Text('Belum ada anggota genogram.')
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anggota Genogram (${members.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                itemBuilder: (context, idx) {
                  final member = members[idx] as Map<String, dynamic>;
                  return ListTile(
                    title: Text(member['name'] ?? 'Unknown'),
                    subtitle: Text(
                      '${member['relationship'] ?? ''} • ${member['age'] ?? ''}',
                    ),
                  );
                },
              ),
            ],
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final result = await Get.toNamed(
              '/genogram-builder',
              arguments: {
                'structure': structure ?? {'members': [], 'connections': []},
                'notes':
                    formKey.currentState?.fields['genogram_notes']?.value ?? '',
              },
            );
            if (result != null && result is Map<String, dynamic>) {
              formKey.currentState?.fields['genogram_structure']?.didChange(
                result['structure'] ?? result,
              );
              formKey.currentState?.fields['genogram_notes']?.didChange(
                result['notes'] ?? '',
              );
              setState(() {});
            }
          },
          child: const Text('Open Genogram Builder'),
        ),
      ],
    );
  }

  Widget _buildRenpraSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 10: Rencana Perawatan (Renpra)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final nursingService = Get.find<NursingDataGlobalService>();
          final diagnoses = nursingService.diagnoses;
          if (diagnoses.isEmpty)
            return const Text('Tidak ada diagnosis tersedia');

          return CustomDropdown<int>(
            name: 'diagnosis',
            label: 'Diagnosis',
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
          if (interventions.isEmpty)
            return const Text('Tidak ada intervensi tersedia');

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
      ],
    );
  }

  Widget _buildPenutupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 11: Penutup',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'catatan_tambahan',
          label: 'Catatan Tambahan',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        FormBuilderDateTimePicker(
          name: 'tanggal_pengisian',
          inputType: InputType.date,
          decoration: const InputDecoration(
            labelText: 'Tanggal Pengisian',
            border: OutlineInputBorder(),
          ),
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (formId == null) await saveDraft();
        try {
          final formSelectionController = Get.find<FormSelectionController>();
          await formSelectionController.fetchForms();
        } catch (e) {}
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.formId == null
                ? 'Form Pengkajian Kesehatan Jiwa'
                : 'Edit Form',
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            TextButton(
              onPressed: _exportToPdf,
              child: const Text('PDF', style: TextStyle(color: Colors.white)),
            ),
          ],
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
      ),
    );
  }
}
