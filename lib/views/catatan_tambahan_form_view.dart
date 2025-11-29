import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../models/patient_model.dart';
import '../models/form_model.dart';
import '../services/hive_service.dart';
import '../services/nursing_data_global_service.dart';

class CatatanTambahanFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const CatatanTambahanFormView({super.key, this.patient, this.formId});

  @override
  State<CatatanTambahanFormView> createState() =>
      _CatatanTambahanFormViewState();
}

class _CatatanTambahanFormViewState extends State<CatatanTambahanFormView> {
  final FormController formController = Get.put(FormController());
  final PatientController patientController = Get.find();

  // Data structure for the catatan tambahan form
  final Map<String, dynamic> _formData = {
    'catatan': {}, // Contains the free text area content and optional renpra
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
      'catatan_tambahan',
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

  Future<void> _loadFormData() async {
    if (widget.formId == null) return;

    final form = await formController.getFormById(widget.formId!);
    if (form != null && form.data != null) {
      setState(() {
        _formData.addAll(form.data!);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveDraft() async {
    if (widget.patient == null) {
      Get.snackbar('Error', 'Patient information is required to save draft');
      return;
    }

    try {
      final form = FormModel(
        id: widget.formId ?? DateTime.now().millisecondsSinceEpoch,
        type: 'catatan_tambahan',
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
    } catch (e) {
      Get.snackbar('Error', 'Failed to save draft: $e');
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
        type: 'catatan_tambahan',
        patientId: widget.patient!.id,
        data: _formData,
        status: 'submitted',
      );

      // If submission successful, remove any local draft
      await HiveService.deleteDraftForm('catatan_tambahan', widget.patient!.id);

      Get.snackbar('Success', 'Form submitted successfully');
      Get.back(); // Navigate back
    } catch (e) {
      // If submission fails, save as draft locally and notify user
      Get.snackbar('Error', 'Submission failed. Form saved as draft locally.');

      // Save to local storage as draft
      final form = FormModel(
        id: DateTime.now().millisecondsSinceEpoch,
        type: 'catatan_tambahan',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.formId == null
              ? 'Form Catatan Tambahan'
              : 'Edit Catatan Tambahan',
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
            // Main content area with text area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catatan Tambahan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _formData['catatan']['isi_catatan'],
                      decoration: const InputDecoration(
                        labelText: 'Isi Catatan',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: null, // Makes it expandable
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) {
                        _formData['catatan']['isi_catatan'] = value;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Optional Renpra section
                    const Text(
                      'Rencana Perawatan (Renpra) - Opsional',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Diagnosis dropdown
                    const Text('Diagnosis'),
                    const SizedBox(height: 8),
                    Obx(() {
                      final nursingService =
                          Get.find<NursingDataGlobalService>();
                      final diagnoses = nursingService.diagnoses;

                      // Create dropdown items from dynamic diagnoses
                      final items = diagnoses
                          .map(
                            (diag) => DropdownMenuItem(
                              value: diag.name,
                              child: Text(diag.name),
                            ),
                          )
                          .toList();

                      // Add 'Tidak Ada' option at the beginning
                      items.insert(
                        0,
                        const DropdownMenuItem(
                          value: 'Tidak Ada',
                          child: Text('Tidak Ada'),
                        ),
                      );

                      // Add a default option if no diagnoses available
                      if (items.length == 1) {
                        items.add(
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Tidak ada diagnosis tersedia'),
                          ),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: items,
                        value:
                            _formData['catatan']['renpra']?['diagnosis'] ??
                            'Tidak Ada',
                        onChanged: (value) {
                          if (value == 'Tidak Ada') {
                            _formData['catatan']['renpra'] = null;
                          } else {
                            _formData['catatan']['renpra'] =
                                _formData['catatan']['renpra'] ?? {};
                            _formData['catatan']['renpra']['diagnosis'] = value;
                          }
                        },
                        hint: const Text('Pilih Diagnosis atau Tidak Ada'),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Intervensi checkboxes (only if renpra is selected)
                    if (_formData['catatan']['renpra']?['diagnosis'] != null &&
                        _formData['catatan']['renpra']?['diagnosis'] !=
                            'Tidak Ada') ...[
                      const Text('Intervensi'),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text('Terapi Individu'),
                        value:
                            (_formData['catatan']['renpra']?['intervensi']
                                    as List?)
                                ?.contains('Terapi Individu') ??
                            false,
                        onChanged: (bool? value) {
                          _formData['catatan']['renpra'] =
                              _formData['catatan']['renpra'] ?? {};
                          final intervensi =
                              _formData['catatan']['renpra']['intervensi']
                                  as List? ??
                              <String>[];
                          if (value == true) {
                            intervensi.add('Terapi Individu');
                          } else {
                            intervensi.remove('Terapi Individu');
                          }
                          _formData['catatan']['renpra']['intervensi'] =
                              intervensi;
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Terapi Keluarga'),
                        value:
                            (_formData['catatan']['renpra']?['intervensi']
                                    as List?)
                                ?.contains('Terapi Keluarga') ??
                            false,
                        onChanged: (bool? value) {
                          _formData['catatan']['renpra'] =
                              _formData['catatan']['renpra'] ?? {};
                          final intervensi =
                              _formData['catatan']['renpra']['intervensi']
                                  as List? ??
                              <String>[];
                          if (value == true) {
                            intervensi.add('Terapi Keluarga');
                          } else {
                            intervensi.remove('Terapi Keluarga');
                          }
                          _formData['catatan']['renpra']['intervensi'] =
                              intervensi;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _formData['catatan']['renpra']?['tujuan'],
                        decoration: const InputDecoration(
                          labelText: 'Tujuan',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          _formData['catatan']['renpra'] =
                              _formData['catatan']['renpra'] ?? {};
                          _formData['catatan']['renpra']['tujuan'] = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue:
                            _formData['catatan']['renpra']?['kriteria'],
                        decoration: const InputDecoration(
                          labelText: 'Kriteria',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          _formData['catatan']['renpra'] =
                              _formData['catatan']['renpra'] ?? {};
                          _formData['catatan']['renpra']['kriteria'] = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue:
                            _formData['catatan']['renpra']?['rasional'],
                        decoration: const InputDecoration(
                          labelText: 'Rasional',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          _formData['catatan']['renpra'] =
                              _formData['catatan']['renpra'] ?? {};
                          _formData['catatan']['renpra']['rasional'] = value;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Submit button
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
