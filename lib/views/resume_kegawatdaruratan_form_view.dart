import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../models/patient_model.dart';
import '../models/form_model.dart';
import '../services/hive_service.dart';
import '../services/nursing_data_global_service.dart';
import '../controllers/nursing_intervention_controller.dart';

class ResumeKegawatdaruratanFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const ResumeKegawatdaruratanFormView({super.key, this.patient, this.formId});

  @override
  State<ResumeKegawatdaruratanFormView> createState() =>
      _ResumeKegawatdaruratanFormViewState();
}

class _ResumeKegawatdaruratanFormViewState
    extends State<ResumeKegawatdaruratanFormView> {
  final FormController formController = Get.put(FormController());
  final PatientController patientController = Get.find();
  final NursingInterventionController _interventionController = Get.put(NursingInterventionController());

  int _currentSection = 0;

  // Data structure for the resume kegawatdaruratan form with 11 sections
  final Map<String, dynamic> _formData = {
    'identitas': {}, // Section 1: Identitas
    'riwayat_keluhan':
        {}, // Section 2: Riwayat Keluhan Utama dan Riwayat Penyakit Sekarang
    'pemeriksaan_fisik': {}, // Section 3: Pemeriksaan Fisik
    'status_mental': {}, // Section 4: Pemeriksaan Status Mental
    'diagnosis': {}, // Section 5: Diagnosis Kerja
    'tindakan': {}, // Section 6: Tindakan yang Telah Dilakukan
    'implementasi': {}, // Section 7: Implementasi
    'evaluasi': {}, // Section 8: Evaluasi
    'rencana_lanjut': {}, // Section 9: Rencana Tindak Lanjut
    'rencana_keluarga': {}, // Section 10: Rencana dengan Keluarga
    'renpra': {}, // Section 11: Renpra (Rencana Perawatan)
  };
  Patient? _currentPatient;
  int? _currentPatientId;

  @override
  void initState() {
    super.initState();

    // Initialize Hive
    HiveService.init();

    // If editing existing form, load the data
    final effectiveFormId = widget.formId ?? Get.arguments?['formId'] as int?;
    if (effectiveFormId != null) {
      _loadFormData(effectiveFormId);
    } else {
      // set current patient for fallback
      _currentPatient = widget.patient ?? Get.arguments?['patient'] as Patient?;
      _currentPatientId = _currentPatient?.id ?? Get.arguments?['patientId'] as int?;
      // Check for any existing draft forms to continue
      _checkForDrafts();
      _currentPatient = widget.patient ?? Get.arguments?['patient'] as Patient?;
      _currentPatientId = _currentPatient?.id ?? Get.arguments?['patientId'] as int?;
    }
  }

  Future<void> _checkForDrafts() async {
    final patient = _currentPatient ?? widget.patient ?? Get.arguments?['patient'] as Patient?;
    final patientId = _currentPatientId ?? patient?.id ?? Get.arguments?['patientId'] as int?;
    if (patientId == null) return;

    final draft = await HiveService.getDraftForm(
      'resume_kegawatdaruratan',
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
          });
        },
        onCancel: () {
          // Optional: Delete draft if user chooses not to restore
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
      });
    }
  }

  @override
  void dispose() {
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
      final form = FormModel(
        id: widget.formId ?? DateTime.now().millisecondsSinceEpoch,
        type: 'resume_kegawatdaruratan',
        userId: 0,
        patientId: patientId,
        status: 'draft',
        data: _formData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        genogram: null,
      );

      await HiveService.saveDraftForm(form);
      Get.snackbar('Success', 'Draft saved locally');
      // Return to previous route and provide the saved draft as result
      Get.back(result: form);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save draft: $e');
    }
  }

  Future<void> _submitForm() async {
    final patient = _currentPatient ?? widget.patient ?? Get.arguments?['patient'] as Patient?;
    final patientId = _currentPatientId ?? patient?.id ?? Get.arguments?['patientId'] as int?;

    // Check if patient is available
    if (patient == null || patientId == null) {
      Get.snackbar('Error', 'Patient information is required to submit form');
      return;
    }

    try {
      // Try to submit to server
      final resultForm = widget.formId != null
          ? await formController.updateForm(
              id: widget.formId!,
              type: 'resume_kegawatdaruratan',
              patientId: patientId,
              data: _formData,
              status: 'submitted',
            )
          : await formController.createForm(
              type: 'resume_kegawatdaruratan',
              patientId: patientId,
              data: _formData,
              status: 'submitted',
            );

      // If submission successful, remove any local draft
      await HiveService.deleteDraftForm(
        'resume_kegawatdaruratan',
        widget.patient!.id,
      );

      Get.snackbar('Success', 'Form submitted successfully');
      Get.back(result: resultForm);
    } catch (e) {
      // If submission fails, save as draft locally and notify user
      Get.snackbar('Error', 'Submission failed. Form saved as draft locally.');

      // Save to local storage as draft
      final form = FormModel(
        id: DateTime.now().millisecondsSinceEpoch,
        type: 'resume_kegawatdaruratan',
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
        return _buildSection1Identitas();
      case 1:
        return _buildSection2RiwayatKeluhan();
      case 2:
        return _buildSection3PemeriksaanFisik();
      case 3:
        return _buildSection4StatusMental();
      case 4:
        return _buildSection5Diagnosis();
      case 5:
        return _buildSection6Tindakan();
      case 6:
        return _buildSection7Implementasi();
      case 7:
        return _buildSection8Evaluasi();
      case 8:
        return _buildSection9RencanaLanjut();
      case 9:
        return _buildSection10RencanaKeluarga();
      case 10:
        return _buildSection11Renpra();
      default:
        return const SizedBox();
    }
  }

  Widget _buildSection1Identitas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 1: Identitas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['identitas']['nama_lengkap'],
          decoration: const InputDecoration(
            labelText: 'Nama Lengkap',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['identitas']['nama_lengkap'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['identitas']['umur']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Umur',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _formData['identitas']['umur'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['identitas']['jenis_kelamin'],
          decoration: const InputDecoration(
            labelText: 'Jenis Kelamin',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['identitas']['jenis_kelamin'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['identitas']['alamat'],
          decoration: const InputDecoration(
            labelText: 'Alamat',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          onChanged: (value) {
            _formData['identitas']['alamat'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['identitas']['tanggal_masuk'],
          decoration: const InputDecoration(
            labelText: 'Tanggal Masuk',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.datetime,
          onChanged: (value) {
            _formData['identitas']['tanggal_masuk'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection2RiwayatKeluhan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 2: Riwayat Keluhan Utama dan Riwayat Penyakit Sekarang',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['riwayat_keluhan']['keluhan_utama'],
          decoration: const InputDecoration(
            labelText: 'Keluhan Utama',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['riwayat_keluhan']['keluhan_utama'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue:
              _formData['riwayat_keluhan']['riwayat_penyakit_sekarang'],
          decoration: const InputDecoration(
            labelText: 'Riwayat Penyakit Sekarang',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          onChanged: (value) {
            _formData['riwayat_keluhan']['riwayat_penyakit_sekarang'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['riwayat_keluhan']['faktor_pencetus'],
          decoration: const InputDecoration(
            labelText: 'Faktor Pencetus',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['riwayat_keluhan']['faktor_pencetus'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection3PemeriksaanFisik() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 3: Pemeriksaan Fisik',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['pemeriksaan_fisik']['keadaan_umum'],
          decoration: const InputDecoration(
            labelText: 'Keadaan Umum',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['pemeriksaan_fisik']['keadaan_umum'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['pemeriksaan_fisik']['tanda_vital'],
          decoration: const InputDecoration(
            labelText: 'Tanda-tanda Vital',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['pemeriksaan_fisik']['tanda_vital'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['pemeriksaan_fisik']['pemeriksaan_lain'],
          decoration: const InputDecoration(
            labelText: 'Pemeriksaan Fisik Lain',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['pemeriksaan_fisik']['pemeriksaan_lain'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection4StatusMental() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 4: Pemeriksaan Status Mental',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['status_mental']['kesadaran'],
          decoration: const InputDecoration(
            labelText: 'Kesadaran',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['status_mental']['kesadaran'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['status_mental']['orientasi'],
          decoration: const InputDecoration(
            labelText: 'Orientasi',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['status_mental']['orientasi'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['status_mental']['bentuk_pemikiran'],
          decoration: const InputDecoration(
            labelText: 'Bentuk Pemikiran',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['status_mental']['bentuk_pemikiran'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['status_mental']['isi_pemikiran'],
          decoration: const InputDecoration(
            labelText: 'Isi Pemikiran',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['status_mental']['isi_pemikiran'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['status_mental']['persepsi'],
          decoration: const InputDecoration(
            labelText: 'Persepsi',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['status_mental']['persepsi'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection5Diagnosis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 5: Diagnosis Kerja',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['diagnosis']['diagnosis_utama'],
          decoration: const InputDecoration(
            labelText: 'Diagnosis Utama',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['diagnosis']['diagnosis_utama'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['diagnosis']['diagnosis_banding'],
          decoration: const InputDecoration(
            labelText: 'Diagnosis Banding',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['diagnosis']['diagnosis_banding'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['diagnosis']['diagnosis_tambahan'],
          decoration: const InputDecoration(
            labelText: 'Diagnosis Tambahan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['diagnosis']['diagnosis_tambahan'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection6Tindakan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 6: Tindakan yang Telah Dilakukan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['tindakan']['tindakan_medis'],
          decoration: const InputDecoration(
            labelText: 'Tindakan Medis',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['tindakan']['tindakan_medis'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['tindakan']['tindakan_keperawatan'],
          decoration: const InputDecoration(
            labelText: 'Tindakan Keperawatan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['tindakan']['tindakan_keperawatan'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['tindakan']['terapi_psikososial'],
          decoration: const InputDecoration(
            labelText: 'Terapi Psikososial',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['tindakan']['terapi_psikososial'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection7Implementasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 7: Implementasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['implementasi']['pelaksanaan_intervensi'],
          decoration: const InputDecoration(
            labelText: 'Pelaksanaan Intervensi',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          onChanged: (value) {
            _formData['implementasi']['pelaksanaan_intervensi'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['implementasi']['kolaborasi_tim'],
          decoration: const InputDecoration(
            labelText: 'Kolaborasi dengan Tim Lain',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['implementasi']['kolaborasi_tim'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['implementasi']['edukasi'],
          decoration: const InputDecoration(
            labelText: 'Edukasi yang Diberikan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['implementasi']['edukasi'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection8Evaluasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 8: Evaluasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['evaluasi']['respon_intervensi'],
          decoration: const InputDecoration(
            labelText: 'Respon Terhadap Intervensi',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['evaluasi']['respon_intervensi'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['evaluasi']['perubahan_klinis'],
          decoration: const InputDecoration(
            labelText: 'Perubahan Klinis',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['evaluasi']['perubahan_klinis'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['evaluasi']['tujuan_tercapai'],
          decoration: const InputDecoration(
            labelText: 'Tujuan yang Telah Tercapai',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['evaluasi']['tujuan_tercapai'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['evaluasi']['hambatan_perawatan'],
          decoration: const InputDecoration(
            labelText: 'Hambatan dalam Perawatan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['evaluasi']['hambatan_perawatan'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection9RencanaLanjut() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 9: Rencana Tindak Lanjut',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['rencana_lanjut']['rencana_medis'],
          decoration: const InputDecoration(
            labelText: 'Rencana Medis Lanjutan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['rencana_lanjut']['rencana_medis'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['rencana_lanjut']['rencana_keperawatan'],
          decoration: const InputDecoration(
            labelText: 'Rencana Keperawatan Lanjutan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['rencana_lanjut']['rencana_keperawatan'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['rencana_lanjut']['rencana_pemantauan'],
          decoration: const InputDecoration(
            labelText: 'Rencana Pemantauan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['rencana_lanjut']['rencana_pemantauan'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection10RencanaKeluarga() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 10: Rencana dengan Keluarga',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['rencana_keluarga']['keterlibatan_keluarga'],
          decoration: const InputDecoration(
            labelText: 'Keterlibatan Keluarga',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['rencana_keluarga']['keterlibatan_keluarga'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['rencana_keluarga']['edukasi_keluarga'],
          decoration: const InputDecoration(
            labelText: 'Edukasi untuk Keluarga',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['rencana_keluarga']['edukasi_keluarga'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['rencana_keluarga']['dukungan_keluarga'],
          decoration: const InputDecoration(
            labelText: 'Dukungan dari Keluarga',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['rencana_keluarga']['dukungan_keluarga'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection11Renpra() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 11: Rencana Perawatan (Renpra)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Diagnosis dropdown
        const Text('Diagnosis Keperawatan'),
        const SizedBox(height: 8),
        Obx(() {
          final nursingService = Get.find<NursingDataGlobalService>();
          final diagnoses = nursingService.diagnoses;

          // Create dropdown items from dynamic diagnoses
          final items = diagnoses
                  .map((diag) => DropdownMenuItem(value: diag.id, child: Text(diag.name)),)
              .toList();

          // Add a default option if no diagnoses available
          if (items.isEmpty) {
            items.add(
              DropdownMenuItem<int>(
                value: null,
                child: const Text('Tidak ada diagnosis tersedia'),
              ),
            );
          }

          return DropdownButtonFormField<int?>(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: items.cast<DropdownMenuItem<int?>>(),
            value: _formData['renpra']['diagnosis'] as int?,
            onChanged: (value) {
              _formData['renpra']['diagnosis'] = value;
            },
            hint: const Text('Pilih Diagnosis Keperawatan'),
          );
        }),
        const SizedBox(height: 16),
        const Text('Intervensi'),
        const SizedBox(height: 8),
        Obx(() {
          final interventions = _interventionController.interventions;
          if (interventions.isEmpty) return const Text('Tidak ada intervensi tersedia');
          return Column(
            children: interventions.map((iv) {
              final currentInterventions =
                  (_formData['renpra']['intervensi'] as List?) ?? <int>[];
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
                  _formData['renpra']['intervensi'] = intervensi;
                  setState(() {});
                },
              );
            }).toList(),
          );
        }),
        CheckboxListTile(
          title: const Text('Peningkatan Aktivitas'),
          value:
              (_formData['renpra']['intervensi'] as List?)?.contains(
                'Peningkatan Aktivitas',
              ) ??
              false,
          onChanged: (bool? value) {
            final intervensi =
                _formData['renpra']['intervensi'] as List? ?? <String>[];
            if (value == true) {
              intervensi.add('Peningkatan Aktivitas');
            } else {
              intervensi.remove('Peningkatan Aktivitas');
            }
            _formData['renpra']['intervensi'] = intervensi;
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
            _formData['renpra']['tujuan'] = value;
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
            _formData['renpra']['kriteria'] = value;
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
            _formData['renpra']['rasional'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Evaluasi',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['renpra']['evaluasi'] = value;
          },
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
        actions: [
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
