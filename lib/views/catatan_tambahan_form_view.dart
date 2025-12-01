import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../models/patient_model.dart';
import '../services/nursing_data_global_service.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../utils/form_base_mixin.dart';

class CatatanTambahanFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const CatatanTambahanFormView({super.key, this.patient, this.formId});

  @override
  State<CatatanTambahanFormView> createState() =>
      _CatatanTambahanFormViewState();
}

class _CatatanTambahanFormViewState extends State<CatatanTambahanFormView>
    with FormBaseMixin {
  @override
  final FormController formController = Get.put(FormController());
  @override
  final PatientController patientController = Get.find();
  final NursingInterventionController _interventionController = Get.put(NursingInterventionController());

  // Data structure for the catatan tambahan form
  @override
  final Map<String, dynamic> formData = {
    'catatan': {}, // Contains the free text area content and optional renpra
  };
  
  @override
  String get formType => 'catatan_tambahan';
  
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
    
    initializeForm(
      patient: _currentPatient,
      patientId: _currentPatientId,
      formId: formId,
    );
  }

  @override
  void dispose() {
    super.dispose();
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
                      initialValue: formData['catatan']['isi_catatan'],
                      decoration: const InputDecoration(
                        labelText: 'Isi Catatan',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: null, // Makes it expandable
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) {
                        formData['catatan']['isi_catatan'] = value;
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
                            (diag) => DropdownMenuItem<int?>(
                              value: diag.id,
                              child: Text(diag.name),
                            ),
                          )
                          .toList();

                      // Provide a default 'Tidak Ada' option (null value)
                      items.insert(0, DropdownMenuItem<int?>(value: null, child: const Text('Tidak Ada')));

                      if (items.isEmpty) {
                        return const Text('Tidak ada diagnosis tersedia');
                      }

                      return DropdownButtonFormField<int?>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: items.cast<DropdownMenuItem<int?>>(),
                        value: formData['catatan']['renpra']?['diagnosis'] as int?,
                        onChanged: (value) {
                          if (value == null) {
                            formData['catatan']['renpra'] = null;
                          } else {
                            formData['catatan']['renpra'] =
                                formData['catatan']['renpra'] ?? {};
                            formData['catatan']['renpra']['diagnosis'] = value;
                          }
                        },
                        hint: const Text('Pilih Diagnosis atau Tidak Ada'),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Intervensi checkboxes (only if renpra is selected)
                    if (formData['catatan']['renpra']?['diagnosis'] != null &&
                        formData['catatan']['renpra']?['diagnosis'] !=
                            'Tidak Ada') ...[
                      const Text('Intervensi'),
                      const SizedBox(height: 8),
                      Obx(() {
                        final interventions = _interventionController.interventions;
                        if (interventions.isEmpty) return const Text('Tidak ada intervensi tersedia');
                        return Column(
                          children: interventions.map((iv) {
                            formData['catatan']['renpra'] = formData['catatan']['renpra'] ?? {};
                            final currentInterventions =
                                (formData['catatan']['renpra']?['intervensi'] as List?) ?? <int>[];
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
                                formData['catatan']['renpra']?['intervensi'] = intervensi;
                                setState(() {});
                              },
                            );
                          }).toList(),
                        );
                      }),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: formData['catatan']['renpra']?['tujuan'],
                        decoration: const InputDecoration(
                          labelText: 'Tujuan',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          formData['catatan']['renpra'] =
                              formData['catatan']['renpra'] ?? {};
                          formData['catatan']['renpra']['tujuan'] = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue:
                            formData['catatan']['renpra']?['kriteria'],
                        decoration: const InputDecoration(
                          labelText: 'Kriteria',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          formData['catatan']['renpra'] =
                              formData['catatan']['renpra'] ?? {};
                          formData['catatan']['renpra']['kriteria'] = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue:
                            formData['catatan']['renpra']?['rasional'],
                        decoration: const InputDecoration(
                          labelText: 'Rasional',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          formData['catatan']['renpra'] =
                              formData['catatan']['renpra'] ?? {};
                          formData['catatan']['renpra']['rasional'] = value;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Action buttons from mixin
            buildActionButtons(),
          ],
        ),
      ),
    );
  }
}
