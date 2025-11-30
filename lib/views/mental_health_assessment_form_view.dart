import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/form_selection_controller.dart';
import '../controllers/patient_controller.dart';
import '../controllers/pdf_controller.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../models/patient_model.dart';
import '../models/form_model.dart';
import '../services/hive_service.dart';
import '../services/nursing_data_global_service.dart';
import '../widgets/form_text_field.dart';
import '../widgets/form_section_header.dart';

class MentalHealthAssessmentFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const MentalHealthAssessmentFormView({super.key, this.patient, this.formId});

  @override
  State<MentalHealthAssessmentFormView> createState() =>
      _MentalHealthAssessmentFormViewState();
}

class _MentalHealthAssessmentFormViewState
    extends State<MentalHealthAssessmentFormView> {
  final FormController formController = Get.put(FormController());
  final PatientController patientController = Get.find();
  final NursingInterventionController _interventionController = Get.put(
    NursingInterventionController(),
  );

  int _currentSection = 0;

  // Controllers for the form fields - one for each field
  final List<TextEditingController> _controllers = List.generate(
    30,
    (index) => TextEditingController(),
  );

  // Data structure for the form
  final Map<String, dynamic> _formData = {
    'section_1': {}, // Identitas Klien
    'section_2': {}, // Riwayat Kehidupan
    'section_3': {}, // Riwayat Psikososial
    'section_4': {}, // Riwayat Psikiatri
    'section_5': {}, // Pemeriksaan Psikologis
    'section_6': {}, // Fungsi Psikologis
    'section_7': {}, // Fungsi Sosial
    'section_8': {}, // Fungsi Spiritual
    'section_9': {}, // Genogram
    'section_10': {}, // Renpra (Rencana Perawatan)
    'section_11': {}, // Penutup
  };
  Patient? _currentPatient;
  int? _currentPatientId;

  @override
  void initState() {
    super.initState();

    HiveService.init();

    _currentPatient = widget.patient ?? Get.arguments?['patient'] as Patient?;
    _currentPatientId = _currentPatient?.id ?? Get.arguments?['patientId'] as int?;

    final effectiveFormId = widget.formId ?? Get.arguments?['formId'] as int?;
    final formData = Get.arguments?['formData'] as Map<String, dynamic>?;
    
    if (effectiveFormId != null) {
      if (formData != null) {
        setState(() {
          _formData.addAll(formData);
          _populateControllers();
        });
      } else {
        _loadFormData(effectiveFormId);
      }
    } else {
      _checkForDrafts();
      Future.microtask(() async {
        if (_currentPatientId != null) {
          await _prefillGenogramFromPatient(_currentPatientId!);
        }
      });
    }
  }

  Future<void> _prefillGenogramFromPatient(int patientId) async {
    try {
      await formController.fetchForms(patientId: patientId);
      final formsWithGenogram = formController.forms.where((f) => f.patientId == patientId && f.genogram != null).toList();
      if (formsWithGenogram.isNotEmpty) {
        // Find the latest (forms are sorted by created_at desc)
        final latest = formsWithGenogram.first;
        if (latest.genogram?.structure != null) {
          setState(() {
            _formData['section_9'] = {'structure': latest.genogram!.structure, 'notes': latest.genogram!.notes};
            _formData['genogram'] = {'structure': latest.genogram!.structure, 'notes': latest.genogram!.notes};
          });
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _checkForDrafts() async {
    final patient = _currentPatient ?? widget.patient ?? Get.arguments?['patient'] as Patient?;
    final patientId = _currentPatientId ?? patient?.id ?? Get.arguments?['patientId'] as int?;
    
    if (patientId == null) return;

    final draft = await HiveService.getDraftForm(
      'pengkajian',
      patientId,
    );
    if (draft != null) {
      Get.defaultDialog(
        title: 'Draft Ditemukan',
        middleText:
            'Apakah Anda ingin melanjutkan pengisian form dari draft yang tersimpan?',
        textConfirm: 'Ya',
        textCancel: 'Tidak',
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
          setState(() {
            _formData.addAll(draft.data ?? {});
            _populateControllers();
          });
        },
        onCancel: () {
          // Optional: Delete draft if user chooses not to restore
          // HiveService.deleteDraftForm('pengkajian', widget.patient!.id);
        },
      );
    }
  }

  Future<void> _loadFormData([int? id]) async {
    final formIdToLoad = id ?? widget.formId ?? Get.arguments?['formId'] as int?;
    if (formIdToLoad == null) return;

    final form = await formController.getFormById(formIdToLoad);
    if (form != null && form.data != null) {
      setState(() {
        if (form.patient != null) {
          _currentPatient = form.patient as Patient;
          _currentPatientId = form.patient!.id;
        }
        _formData.addAll(form.data!);
        // If genogram exists as a related resource, add it under section_9
        if (form.genogram != null) {
          _formData['section_9'] = _formData['section_9'] ?? {};
          _formData['section_9']['structure'] = form.genogram!.structure;
          _formData['section_9']['notes'] = form.genogram!.notes;
          // ensure we also set a top-level genogram payload expected by backend
          _formData['genogram'] = {
            'structure': form.genogram!.structure,
            'notes': form.genogram!.notes,
          };
        }
        _populateControllers();
      });
    }
  }

  void _populateControllers() {
    // Section 1: Identitas Klien (0-3)
    if (_formData['section_1'] != null) {
      _controllers[0].text = _formData['section_1']['nama_lengkap'] ?? '';
      _controllers[1].text = _formData['section_1']['umur']?.toString() ?? '';
      // populate text controllers if legacy data present
      _controllers[2].text = _formData['section_1']['jenis_kelamin'] ?? '';
      _controllers[3].text = _formData['section_1']['status_perkawinan'] ?? '';
      // ensure _formData has dropdown values set if loaded from controllers
      if ((_formData['section_1']['jenis_kelamin'] ?? '').isEmpty &&
          _controllers[2].text.isNotEmpty) {
        _formData['section_1']['jenis_kelamin'] = _controllers[2].text;
      }
      if ((_formData['section_1']['status_perkawinan'] ?? '').isEmpty &&
          _controllers[3].text.isNotEmpty) {
        _formData['section_1']['status_perkawinan'] = _controllers[3].text;
      }
    }

    // Section 2: Riwayat Kehidupan (4-6)
    if (_formData['section_2'] != null) {
      _controllers[4].text = _formData['section_2']['riwayat_pendidikan'] ?? '';
      _controllers[5].text = _formData['section_2']['pekerjaan'] ?? '';
      _controllers[6].text = _formData['section_2']['riwayat_keluarga'] ?? '';
    }

    // Section 3: Riwayat Psikososial (7-9)
    if (_formData['section_3'] != null) {
      _controllers[7].text = _formData['section_3']['hubungan_sosial'] ?? '';
      _controllers[8].text = _formData['section_3']['dukungan_sosial'] ?? '';
      _controllers[9].text =
          _formData['section_3']['stresor_psikososial'] ?? '';
    }

    // Section 4: Riwayat Psikiatri (10)
    if (_formData['section_4'] != null) {
      _controllers[10].text =
          _formData['section_4']['riwayat_gangguan_psikiatri'] ?? '';
    }

    // Section 5: Pemeriksaan Psikologis (11-13)
    if (_formData['section_5'] != null) {
      _controllers[11].text = _formData['section_5']['kesadaran'] ?? '';
      _controllers[12].text = _formData['section_5']['orientasi'] ?? '';
      _controllers[13].text = _formData['section_5']['penampilan'] ?? '';
      if ((_formData['section_5']['kesadaran'] ?? '').isEmpty &&
          _controllers[11].text.isNotEmpty) {
        _formData['section_5']['kesadaran'] = _controllers[11].text;
      }
      if ((_formData['section_5']['orientasi'] ?? '').isEmpty &&
          _controllers[12].text.isNotEmpty) {
        _formData['section_5']['orientasi'] = _controllers[12].text;
      }
    }

    // Section 6: Fungsi Psikologis (14-16)
    if (_formData['section_6'] != null) {
      _controllers[14].text = _formData['section_6']['mood'] ?? '';
      _controllers[15].text = _formData['section_6']['afect'] ?? '';
      _controllers[16].text = _formData['section_6']['alam_pikiran'] ?? '';
      if ((_formData['section_6']['mood'] ?? '').isEmpty &&
          _controllers[14].text.isNotEmpty) {
        _formData['section_6']['mood'] = _controllers[14].text;
      }
      if ((_formData['section_6']['afect'] ?? '').isEmpty &&
          _controllers[15].text.isNotEmpty) {
        _formData['section_6']['afect'] = _controllers[15].text;
      }
    }

    // Section 7: Fungsi Sosial (17)
    if (_formData['section_7'] != null) {
      _controllers[17].text = _formData['section_7']['fungsi_sosial'] ?? '';
    }

    // Section 8: Fungsi Spiritual (18-19)
    if (_formData['section_8'] != null) {
      _controllers[18].text = _formData['section_8']['kepercayaan'] ?? '';
      _controllers[19].text = _formData['section_8']['praktik_ibadah'] ?? '';
    }

    // Section 11: Penutup (20)
    if (_formData['section_11'] != null) {
      _controllers[20].text = _formData['section_11']['catatan_tambahan'] ?? '';
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextSection() {
    if (_currentSection < 10) {
      setState(() {
        _currentSection++;
      });
    } else {
      _submitForm();
    }
  }

  void _previousSection() {
    if (_currentSection > 0) {
      setState(() {
        _currentSection--;
      });
    }
  }

  Future<void> _saveDraft() async {
    final patient = _currentPatient ?? widget.patient ?? Get.arguments?['patient'] as Patient?;
    final patientId = _currentPatientId ?? patient?.id ?? Get.arguments?['patientId'] as int?;
    
    if (patient == null || patientId == null) {
      Get.snackbar('Error', 'Patient information is required to save draft');
      return;
    }

    try {
      if (widget.formId != null) {
        await formController.updateForm(
          id: widget.formId!,
          data: _formData,
          status: 'draft',
        );
      } else {
        await formController.createForm(
          type: 'pengkajian',
          patientId: patientId,
          data: _formData,
          status: 'draft',
        );
      }
      Get.snackbar(
        'Success',
        'Draft saved successfully',
        snackPosition: SnackPosition.TOP,
      );
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save draft: $e');
    }
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
      // Open the PDF in a new window or download it
      Get.snackbar('Success', 'PDF generated successfully. URL: $pdfUrl');
      // In a real implementation, you might open the PDF viewer here
    }
  }

  Future<void> _submitForm() async {
    // Get patient from widget/args/current patient
    final patient = _currentPatient ?? widget.patient ?? Get.arguments?['patient'] as Patient?;
    final patientId = _currentPatientId ?? patient?.id ?? Get.arguments?['patientId'] as int?;

    if (patient == null || patientId == null) {
      Get.snackbar('Error', 'Patient information is required to submit form');
      return;
    }

    // Basic validation: ensure required fields exist
    if ((_formData['section_1']['jenis_kelamin'] ?? '').toString().isEmpty) {
      Get.snackbar('Validation', 'Jenis Kelamin harus dipilih');
      return;
    }
    if ((_formData['section_1']['status_perkawinan'] ?? '').toString().isEmpty) {
      Get.snackbar('Validation', 'Status Perkawinan harus dipilih');
      return;
    }

    try {
      // ensure genogram payload is present for backend if we have a section_9 structure
      if ((_formData['section_9'] ?? {})['structure'] != null) {
        _formData['genogram'] = {
          'structure': _formData['section_9']['structure'],
          'notes': _formData['section_9']['notes'] ?? '',
        };
      }
      // Try to submit to server
      final resultForm = widget.formId != null
          ? await formController.updateForm(
              id: widget.formId!,
              type: 'pengkajian',
              patientId: patientId,
              data: _formData,
              status: 'submitted',
            )
          : await formController.createForm(
              type: 'pengkajian',
              patientId: patientId,
              data: _formData,
              status: 'submitted',
            );

      // If submission successful, remove any local draft
      await HiveService.deleteDraftForm('pengkajian', patientId);

      Get.snackbar('Success', 'Form submitted successfully');

      // Refresh form list before going back (FormController already fetches)
      try {
        final formSelectionController = Get.find<FormSelectionController>();
        await formSelectionController.fetchForms();
      } catch (e) {
        // Controller might not exist, ignore
      }
      Get.back(result: resultForm);
    } catch (e) {
      // If submission fails, save as draft locally and notify user
      Get.snackbar('Error', 'Submission failed. Form saved as draft locally.');

      // Save to local storage as draft
      final form = FormModel(
        id: DateTime.now().millisecondsSinceEpoch,
        type: 'pengkajian',
        userId: 0,
        patientId: patientId,
        status: 'draft',
        data: _formData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        genogram: null,
      );

      await HiveService.saveDraftForm(form);
    }
  }

  Widget _buildSection(int sectionNumber) {
    switch (sectionNumber) {
      case 0:
        return _buildSection1IdentitasKlien();
      case 1:
        return _buildSection2RiwayatKehidupan();
      case 2:
        return _buildSection3RiwayatPsikososial();
      case 3:
        return _buildSection4RiwayatPsikiatri();
      case 4:
        return _buildSection5PemeriksaanPsikologis();
      case 5:
        return _buildSection6FungsiPsikologis();
      case 6:
        return _buildSection7FungsiSosial();
      case 7:
        return _buildSection8FungsiSpiritual();
      case 8:
        return _buildSection9Genogram();
      case 9:
        return _buildSection10Renpra();
      case 10:
        return _buildSection11Penutup();
      default:
        return const SizedBox();
    }
  }

  Widget _buildSection1IdentitasKlien() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'Section 1: Identitas Klien'),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[0],
          labelText: 'Nama Lengkap',
          onChanged: (value) => _formData['section_1']['nama_lengkap'] = value,
        ),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[1],
          labelText: 'Umur',
          keyboardType: TextInputType.number,
          onChanged: (value) => _formData['section_1']['umur'] = value,
        ),
        const SizedBox(height: 16),
        // Jenis Kelamin (Dropdown)
        DropdownButtonFormField<String>(
          value: _formData['section_1']['jenis_kelamin'] as String?,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
            DropdownMenuItem(value: 'P', child: Text('Perempuan')),
            DropdownMenuItem(value: 'O', child: Text('Lainnya')),
          ],
          onChanged: (value) => setState(() {
            _formData['section_1']['jenis_kelamin'] = value;
          }),
          hint: const Text('Pilih Jenis Kelamin'),
        ),
        const SizedBox(height: 16),
        // Status Perkawinan (Dropdown)
        DropdownButtonFormField<String>(
          value: _formData['section_1']['status_perkawinan'] as String?,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'belum_kawin', child: Text('Belum Kawin')),
            DropdownMenuItem(value: 'menikah', child: Text('Menikah')),
            DropdownMenuItem(value: 'cerai_hidup', child: Text('Cerai Hidup')),
            DropdownMenuItem(value: 'cerai_mati', child: Text('Cerai Mati')),
            DropdownMenuItem(value: 'duda', child: Text('Duda')),
            DropdownMenuItem(value: 'janda', child: Text('Janda')),
          ],
          onChanged: (value) => setState(() {
            _formData['section_1']['status_perkawinan'] = value;
          }),
          hint: const Text('Pilih Status Perkawinan'),
        ),
      ],
    );
  }

  Widget _buildSection2RiwayatKehidupan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'Section 2: Riwayat Kehidupan'),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[4],
          labelText: 'Riwayat Pendidikan',
          maxLines: 3,
          onChanged: (value) =>
              _formData['section_2']['riwayat_pendidikan'] = value,
        ),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[5],
          labelText: 'Pekerjaan',
          onChanged: (value) => _formData['section_2']['pekerjaan'] = value,
        ),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[6],
          labelText: 'Riwayat Keluarga',
          maxLines: 3,
          onChanged: (value) =>
              _formData['section_2']['riwayat_keluarga'] = value,
        ),
      ],
    );
  }

  Widget _buildSection3RiwayatPsikososial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'Section 3: Riwayat Psikososial'),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[7],
          labelText: 'Hubungan Sosial',
          maxLines: 3,
          onChanged: (value) =>
              _formData['section_3']['hubungan_sosial'] = value,
        ),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[8],
          labelText: 'Dukungan Sosial',
          maxLines: 3,
          onChanged: (value) =>
              _formData['section_3']['dukungan_sosial'] = value,
        ),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[9],
          labelText: 'Stresor Psikososial',
          maxLines: 3,
          onChanged: (value) =>
              _formData['section_3']['stresor_psikososial'] = value,
        ),
      ],
    );
  }

  Widget _buildSection4RiwayatPsikiatri() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'Section 4: Riwayat Psikiatri'),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[10],
          labelText: 'Riwayat Gangguan Psikiatri',
          maxLines: 3,
          onChanged: (value) =>
              _formData['section_4']['riwayat_gangguan_psikiatri'] = value,
        ),
      ],
    );
  }

  Widget _buildSection5PemeriksaanPsikologis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'Section 5: Pemeriksaan Psikologis'),
        const SizedBox(height: 16),
        // Kesadaran (Dropdown)
        DropdownButtonFormField<String>(
          value: _formData['section_5']['kesadaran'] as String?,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'sadar_penuh', child: Text('Sadar Penuh')),
            DropdownMenuItem(value: 'somnolent', child: Text('Somnolent')),
            DropdownMenuItem(value: 'stupor', child: Text('Stupor')),
            DropdownMenuItem(value: 'coma', child: Text('Coma')),
          ],
          onChanged: (value) => setState(() {
            _formData['section_5']['kesadaran'] = value;
          }),
          hint: const Text('Pilih Kesadaran'),
        ),
        const SizedBox(height: 16),
        // Orientasi (Dropdown)
        DropdownButtonFormField<String>(
          value: _formData['section_5']['orientasi'] as String?,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'utuh', child: Text('Utuh')),
            DropdownMenuItem(value: 'gangguan', child: Text('Gangguan')),
          ],
          onChanged: (value) => setState(() {
            _formData['section_5']['orientasi'] = value;
          }),
          hint: const Text('Pilih Orientasi'),
        ),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[13],
          labelText: 'Penampilan',
          onChanged: (value) => _formData['section_5']['penampilan'] = value,
        ),
      ],
    );
  }

  Widget _buildSection6FungsiPsikologis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'Section 6: Fungsi Psikologis'),
        const SizedBox(height: 16),
        // Mood (Dropdown)
        DropdownButtonFormField<String>(
          value: _formData['section_6']['mood'] as String?,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'normal', child: Text('Normal')),
            DropdownMenuItem(value: 'depresi', child: Text('Depresi')),
            DropdownMenuItem(value: 'ansietas', child: Text('Ansietas')),
            DropdownMenuItem(value: 'iritabel', child: Text('Iritabel')),
            DropdownMenuItem(value: 'labil', child: Text('Labil')),
          ],
          onChanged: (value) => setState(() {
            _formData['section_6']['mood'] = value;
          }),
          hint: const Text('Pilih Mood'),
        ),
        const SizedBox(height: 16),
        // Afect (Dropdown)
        DropdownButtonFormField<String>(
          value: _formData['section_6']['afect'] as String?,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'normal', child: Text('Normal')),
            DropdownMenuItem(value: 'flat', child: Text('Flat')),
            DropdownMenuItem(value: 'terhambat', child: Text('Terhambat')),
            DropdownMenuItem(value: 'labil', child: Text('Labil')),
            DropdownMenuItem(value: 'iritabel', child: Text('Iritabel')),
          ],
          onChanged: (value) => setState(() {
            _formData['section_6']['afect'] = value;
          }),
          hint: const Text('Pilih Afect'),
        ),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[16],
          labelText: 'Alam pikiran',
          onChanged: (value) => _formData['section_6']['alam_pikiran'] = value,
        ),
      ],
    );
  }

  Widget _buildSection7FungsiSosial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'Section 7: Fungsi Sosial'),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[17],
          labelText: 'Fungsi Sosial',
          maxLines: 3,
          onChanged: (value) => _formData['section_7']['fungsi_sosial'] = value,
        ),
      ],
    );
  }

  Widget _buildSection8FungsiSpiritual() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'Section 8: Fungsi Spiritual'),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[18],
          labelText: 'Kepercayaan',
          onChanged: (value) => _formData['section_8']['kepercayaan'] = value,
        ),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[19],
          labelText: 'Praktik Ibadah',
          onChanged: (value) =>
              _formData['section_8']['praktik_ibadah'] = value,
        ),
      ],
    );
  }

  Widget _buildSection9Genogram() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'Section 9: Genogram'),
        const SizedBox(height: 16),
        const Text('Genogram Builder will be implemented here'),
        const SizedBox(height: 12),
        // Inline preview of current genogram members (if any)
        Builder(builder: (context) {
          final structure = (_formData['section_9'] ?? {})['structure'] ?? (_formData['genogram'] ?? {})['structure'];
          final List members = structure != null && structure is Map ? (structure['members'] ?? []) as List : <dynamic>[];
          final List connections = structure != null && structure is Map ? (structure['connections'] ?? []) as List : <dynamic>[];
          if (members.isEmpty) {
            return const Text('Belum ada anggota genogram.');
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Anggota Genogram (${members.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                itemBuilder: (context, idx) {
                  final member = members[idx] as Map<String, dynamic>;
                  return ListTile(
                    title: Text(member['name'] ?? 'Unknown'),
                    subtitle: Text('${member['relationship'] ?? ''} • ${member['age'] ?? ''}'),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text('Hubungan: ${connections.length}'),
            ],
          );
        }),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final genogramStructure = (_formData['section_9'] ?? {})['structure'] ?? {'members': [], 'connections': []};
            final genogramNotes = (_formData['section_9'] ?? {})['notes'] ?? '';
            final result = await Get.toNamed('/genogram-builder', arguments: {
              'structure': genogramStructure,
              'notes': genogramNotes,
            });
            if (result != null && result is Map<String, dynamic>) {
              setState(() {
                _formData['section_9'] = {};
                _formData['section_9']['structure'] = result['structure'] ?? result;
                _formData['section_9']['notes'] = result['notes'] ?? result['structure']?['notes'] ?? '';
                // Mirror to top-level genogram key so backend can persist it
                _formData['genogram'] = {
                  'structure': _formData['section_9']['structure'],
                  'notes': _formData['section_9']['notes'],
                };
              });
            }
          },
            child: const Text('Open Genogram Builder'),
        ),
      ],
    );
  }

  Widget _buildSection10Renpra() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(
          title: 'Section 10: Rencana Perawatan (Renpra)',
        ),
        const SizedBox(height: 16),
        const Text('Diagnosis'),
        const SizedBox(height: 8),
        Obx(() {
          final nursingService = Get.find<NursingDataGlobalService>();
          final diagnoses = nursingService.diagnoses;
          final items = diagnoses
              .map(
                (diag) =>
                    DropdownMenuItem(value: diag.id, child: Text(diag.name)),
              )
              .toList();
          if (items.isEmpty) {
            items.add(
              DropdownMenuItem<int>(
                value: null,
                child: const Text('Tidak ada diagnosis tersedia'),
              ),
            );
          }
          return DropdownButtonFormField<int>(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: items,
            value: _formData['section_10']['diagnosis'] as int?,
            onChanged: (value) => _formData['section_10']['diagnosis'] = value,
            hint: const Text('Pilih Diagnosis'),
          );
        }),
        const SizedBox(height: 16),
        const Text('Intervensi'),
        Obx(() {
          final interventions = _interventionController.interventions;
          if (interventions.isEmpty)
            return const Text('Tidak ada intervensi tersedia');
          return Column(
            children: interventions.map((iv) {
              final currentInterventions =
                  (_formData['section_10']['intervensi'] as List?) ?? <int>[];
              final isChecked = currentInterventions.contains(iv.id);
              return CheckboxListTile(
                title: Text(iv.name),
                value: isChecked,
                onChanged: (bool? value) {
                  final intervensi = List<int>.from(currentInterventions);
                  if (value == true) {
                    if (!intervensi.contains(iv.id)) intervensi.add(iv.id);
                  } else {
                    intervensi.remove(iv.id);
                  }
                  _formData['section_10']['intervensi'] = intervensi;
                  setState(() {});
                },
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 16),
        FormTextField(
          labelText: 'Tujuan',
          maxLines: 3,
          onChanged: (value) => _formData['section_10']['tujuan'] = value,
        ),
        const SizedBox(height: 16),
        FormTextField(
          labelText: 'Kriteria',
          maxLines: 3,
          onChanged: (value) => _formData['section_10']['kriteria'] = value,
        ),
        const SizedBox(height: 16),
        FormTextField(
          labelText: 'Rasional',
          maxLines: 3,
          onChanged: (value) => _formData['section_10']['rasional'] = value,
        ),
      ],
    );
  }

  Widget _buildSection11Penutup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'Section 11: Penutup'),
        const SizedBox(height: 16),
        FormTextField(
          controller: _controllers[20],
          labelText: 'Catatan Tambahan',
          maxLines: 5,
          onChanged: (value) =>
              _formData['section_11']['catatan_tambahan'] = value,
        ),
        const SizedBox(height: 16),
        const Text('Tanggal Pengisian:'),
        TextButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                _formData['section_11']['tanggal_pengisian'] = pickedDate
                    .toIso8601String();
              });
            }
          },
          child: Text(
            _formData['section_11']['tanggal_pengisian'] != null
                ? _formData['section_11']['tanggal_pengisian']
                      .toString()
                      .substring(0, 10)
                : 'Pilih Tanggal',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          final formSelectionController = Get.find<FormSelectionController>();
          await formSelectionController.fetchForms();
        } catch (e) {
          // Controller not found, ignore
        }
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
            TextButton(
              onPressed: _saveDraft,
              child: const Text(
                'Simpan Draft',
                style: TextStyle(color: Colors.white),
              ),
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
                  child: _buildSection(_currentSection),
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
                  ElevatedButton(
                    onPressed: _nextSection,
                    child: Text(
                      _currentSection == 10 ? 'Simpan' : 'Selanjutnya',
                    ),
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
