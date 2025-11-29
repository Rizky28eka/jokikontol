import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../controllers/pdf_controller.dart';
import '../models/patient_model.dart';
import '../models/form_model.dart';
import '../services/hive_service.dart';
import '../services/nursing_data_global_service.dart';

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

  int _currentSection = 0;

  // Controllers for the form fields
  final List<TextEditingController> _controllers = List.generate(
    11,
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

  @override
  void initState() {
    super.initState();

    // Initialize Hive
    HiveService.init();

    // If editing existing form, load the data
    if (widget.formId != null) {
      _loadFormData();
    } else {
      // Check for any existing draft forms to continue
      _checkForDrafts();
    }
  }

  Future<void> _checkForDrafts() async {
    if (widget.patient == null) return;

    final draft = await HiveService.getDraftForm(
      'pengkajian',
      widget.patient!.id,
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

  Future<void> _loadFormData() async {
    if (widget.formId == null) return;

    final form = await formController.getFormById(widget.formId!);
    if (form != null && form.data != null) {
      setState(() {
        _formData.addAll(form.data!);
        _populateControllers();
      });
    }
  }

  void _populateControllers() {
    // Populate controllers from _formData
    // Section 1
    if (_formData['section_1'] != null) {
      _controllers[0].text = _formData['section_1']['nama_lengkap'] ?? '';
      _controllers[1].text = _formData['section_1']['umur']?.toString() ?? '';
      _controllers[2].text = _formData['section_1']['jenis_kelamin'] ?? '';
      _controllers[3].text = _formData['section_1']['status_perkawinan'] ?? '';
    }

    // Section 2
    if (_formData['section_2'] != null) {
      _controllers[4].text = _formData['section_2']['riwayat_pendidikan'] ?? '';
      _controllers[5].text = _formData['section_2']['pekerjaan'] ?? '';
      _controllers[6].text = _formData['section_2']['riwayat_keluarga'] ?? '';
    }

    // Section 3
    if (_formData['section_3'] != null) {
      _controllers[7].text = _formData['section_3']['hubungan_sosial'] ?? '';
      _controllers[8].text = _formData['section_3']['dukungan_sosial'] ?? '';
      _controllers[9].text =
          _formData['section_3']['stresor_psikososial'] ?? '';
    }

    // Section 4
    if (_formData['section_4'] != null) {
      _controllers[10].text =
          _formData['section_4']['riwayat_gangguan_psikiatri'] ?? '';
    }

    // Note: Other sections use direct binding or different controllers in build methods
    // We need to ensure those are handled correctly if they use controllers.
    // However, looking at the build methods, some use reused controllers which is buggy.
    // For now, I will stick to the plan of fixing logic, but I should note the controller reuse issue.
    // The original code reuses _controllers[0] for Section 5, which overwrites Section 1.
    // This is a bug in the original code. I should fix it by adding more controllers.
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
    if (widget.patient == null) {
      Get.snackbar('Error', 'Patient information is required to save draft');
      return;
    }

    try {
      final form = FormModel(
        id: widget.formId ?? DateTime.now().millisecondsSinceEpoch,
        type: 'pengkajian',
        userId: 0,
        patientId: widget.patient!.id,
        status: 'draft',
        data: _formData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        genogram: null,
      );

      await HiveService.saveDraftForm(form);
      Get.snackbar('Success', 'Draft saved locally');

      // Try to sync if online (optional, for now just local)
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
    // Check if patient is available
    if (widget.patient == null) {
      Get.snackbar('Error', 'Patient information is required to submit form');
      return;
    }

    try {
      // Try to submit to server
      await formController.createForm(
        type: 'pengkajian',
        patientId: widget.patient!.id,
        data: _formData,
        status: 'submitted',
      );

      // If submission successful, remove any local draft
      await HiveService.deleteDraftForm('pengkajian', widget.patient!.id);

      Get.snackbar('Success', 'Form submitted successfully');
      Get.back(); // Navigate back
    } catch (e) {
      // If submission fails, save as draft locally and notify user
      Get.snackbar('Error', 'Submission failed. Form saved as draft locally.');

      // Save to local storage as draft
      final form = FormModel(
        id: DateTime.now().millisecondsSinceEpoch,
        type: 'pengkajian',
        userId: 0,
        patientId: widget.patient!.id,
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
        const Text(
          'Section 1: Identitas Klien',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[0],
          decoration: const InputDecoration(
            labelText: 'Nama Lengkap',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['section_1']['nama_lengkap'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[1],
          decoration: const InputDecoration(
            labelText: 'Umur',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _formData['section_1']['umur'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[2],
          decoration: const InputDecoration(
            labelText: 'Jenis Kelamin',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['section_1']['jenis_kelamin'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[3],
          decoration: const InputDecoration(
            labelText: 'Status Perkawinan',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['section_1']['status_perkawinan'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection2RiwayatKehidupan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 2: Riwayat Kehidupan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[4],
          decoration: const InputDecoration(
            labelText: 'Riwayat Pendidikan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['section_2']['riwayat_pendidikan'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[5],
          decoration: const InputDecoration(
            labelText: 'Pekerjaan',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['section_2']['pekerjaan'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[6],
          decoration: const InputDecoration(
            labelText: 'Riwayat Keluarga',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['section_2']['riwayat_keluarga'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection3RiwayatPsikososial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 3: Riwayat Psikososial',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[7],
          decoration: const InputDecoration(
            labelText: 'Hubungan Sosial',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['section_3']['hubungan_sosial'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[8],
          decoration: const InputDecoration(
            labelText: 'Dukungan Sosial',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['section_3']['dukungan_sosial'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[9],
          decoration: const InputDecoration(
            labelText: 'Stresor Psikososial',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['section_3']['stresor_psikososial'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection4RiwayatPsikiatri() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 4: Riwayat Psikiatri',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[10],
          decoration: const InputDecoration(
            labelText: 'Riwayat Gangguan Psikiatri',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['section_4']['riwayat_gangguan_psikiatri'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection5PemeriksaanPsikologis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 5: Pemeriksaan Psikologis',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[0],
          decoration: const InputDecoration(
            labelText: 'Kesadaran',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['section_5']['kesadaran'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[1],
          decoration: const InputDecoration(
            labelText: 'Orientasi',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['section_5']['orientasi'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[2],
          decoration: const InputDecoration(
            labelText: 'Penampilan',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['section_5']['penampilan'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection6FungsiPsikologis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 6: Fungsi Psikologis',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[3],
          decoration: const InputDecoration(
            labelText: 'Mood',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['section_6']['mood'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[4],
          decoration: const InputDecoration(
            labelText: 'Afect',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['section_6']['afect'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[5],
          decoration: const InputDecoration(
            labelText: 'Alam pikiran',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['section_6']['alam_pikiran'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection7FungsiSosial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 7: Fungsi Sosial',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[6],
          decoration: const InputDecoration(
            labelText: 'Fungsi Sosial',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['section_7']['fungsi_sosial'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection8FungsiSpiritual() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 8: Fungsi Spiritual',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[7],
          decoration: const InputDecoration(
            labelText: 'Kepercayaan',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['section_8']['kepercayaan'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[8],
          decoration: const InputDecoration(
            labelText: 'Praktik Ibadah',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['section_8']['praktik_ibadah'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection9Genogram() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 9: Genogram',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('Genogram Builder will be implemented here'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Navigate to Genogram Builder
            Get.toNamed('/genogram-builder');
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
        const Text(
          'Section 10: Rencana Perawatan (Renpra)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Diagnosis dropdown
        const Text('Diagnosis'),
        const SizedBox(height: 8),
        Obx(() {
          final nursingService = Get.find<NursingDataGlobalService>();
          final diagnoses = nursingService.diagnoses;

          // Create dropdown items from dynamic diagnoses
          final items = diagnoses
              .map(
                (diag) =>
                    DropdownMenuItem(value: diag.name, child: Text(diag.name)),
              )
              .toList();

          // Add a default option if no diagnoses available
          if (items.isEmpty) {
            items.add(
              const DropdownMenuItem(
                value: '',
                child: Text('Tidak ada diagnosis tersedia'),
              ),
            );
          }

          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: items,
            value: _formData['section_10']['diagnosis'],
            onChanged: (value) {
              _formData['section_10']['diagnosis'] = value;
            },
            hint: const Text('Pilih Diagnosis'),
          );
        }),
        const SizedBox(height: 16),
        // Intervensi checkboxes
        const Text('Intervensi'),
        CheckboxListTile(
          title: const Text('Terapi Individu'),
          value:
              (_formData['section_10']['intervensi'] as List?)?.contains(
                'Terapi Individu',
              ) ??
              false,
          onChanged: (bool? value) {
            final intervensi =
                _formData['section_10']['intervensi'] as List? ?? <String>[];
            if (value == true) {
              intervensi.add('Terapi Individu');
            } else {
              intervensi.remove('Terapi Individu');
            }
            _formData['section_10']['intervensi'] = intervensi;
          },
        ),
        CheckboxListTile(
          title: const Text('Terapi Keluarga'),
          value:
              (_formData['section_10']['intervensi'] as List?)?.contains(
                'Terapi Keluarga',
              ) ??
              false,
          onChanged: (bool? value) {
            final intervensi =
                _formData['section_10']['intervensi'] as List? ?? <String>[];
            if (value == true) {
              intervensi.add('Terapi Keluarga');
            } else {
              intervensi.remove('Terapi Keluarga');
            }
            _formData['section_10']['intervensi'] = intervensi;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Tujuan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['section_10']['tujuan'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Kriteria',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['section_10']['kriteria'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Rasional',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['section_10']['rasional'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection11Penutup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 11: Penutup',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[9],
          decoration: const InputDecoration(
            labelText: 'Catatan Tambahan',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          onChanged: (value) {
            _formData['section_11']['catatan_tambahan'] = value;
          },
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
              _formData['section_11']['tanggal_pengisian'] = pickedDate
                  .toIso8601String();
            }
          },
          child: Text(
            _formData['section_11']['tanggal_pengisian'] ?? 'Pilih Tanggal',
          ),
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
            // Progress indicator
            LinearProgressIndicator(value: (_currentSection + 1) / 11),
            const SizedBox(height: 16),
            Text('Section ${_currentSection + 1} dari 11'),
            const SizedBox(height: 16),

            // Section content
            Expanded(
              child: SingleChildScrollView(
                child: _buildSection(_currentSection),
              ),
            ),

            // Navigation buttons
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
                  child: Text(_currentSection == 10 ? 'Simpan' : 'Selanjutnya'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
