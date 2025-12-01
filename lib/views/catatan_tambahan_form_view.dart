import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../models/patient_model.dart';
import '../services/nursing_data_global_service.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../utils/form_builder_mixin.dart';
import '../widgets/form_components/custom_text_field.dart';
import '../widgets/form_components/custom_dropdown.dart';
import '../widgets/form_components/custom_checkbox_group.dart';

class CatatanTambahanFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const CatatanTambahanFormView({super.key, this.patient, this.formId});

  @override
  State<CatatanTambahanFormView> createState() =>
      _CatatanTambahanFormViewState();
}

class _CatatanTambahanFormViewState extends State<CatatanTambahanFormView>
    with FormBuilderMixin {
  @override
  final FormController formController = Get.put(FormController());
  @override
  final PatientController patientController = Get.find();
  final NursingInterventionController _interventionController = Get.put(
    NursingInterventionController(),
  );

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

  // State to track selected diagnosis for visibility logic
  int? _selectedDiagnosis;

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
    final catatan = data['catatan'] ?? {};
    final renpra = catatan['renpra'] ?? {};

    // Set initial selected diagnosis for UI state
    if (renpra['diagnosis'] != null) {
      _selectedDiagnosis = renpra['diagnosis'];
    }

    return {
      'isi_catatan': catatan['isi_catatan'],
      'diagnosis': renpra['diagnosis'],
      'intervensi': renpra['intervensi'] != null
          ? List<int>.from(renpra['intervensi'])
          : [],
      'tujuan': renpra['tujuan'],
      'kriteria': renpra['kriteria'],
      'rasional': renpra['rasional'],
    };
  }

  @override
  Map<String, dynamic> transformFormData(Map<String, dynamic> formData) {
    return {
      'catatan': {
        'isi_catatan': formData['isi_catatan'],
        'renpra': formData['diagnosis'] != null
            ? {
                'diagnosis': formData['diagnosis'],
                'intervensi': formData['intervensi'],
                'tujuan': formData['tujuan'],
                'kriteria': formData['kriteria'],
                'rasional': formData['rasional'],
              }
            : null,
      },
    };
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
            Expanded(
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: formKey,
                  initialValue: initialValues,
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
                      const CustomTextField(
                        name: 'isi_catatan',
                        label: 'Isi Catatan',
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
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
                      Obx(() {
                        final nursingService =
                            Get.find<NursingDataGlobalService>();
                        final diagnoses = nursingService.diagnoses;

                        final items = diagnoses
                            .map(
                              (diag) => DropdownMenuItem<int>(
                                value: diag.id,
                                child: Text(diag.name),
                              ),
                            )
                            .toList();

                        if (items.isEmpty) {
                          return const Text('Tidak ada diagnosis tersedia');
                        }

                        return CustomDropdown<int>(
                          name: 'diagnosis',
                          label: 'Diagnosis',
                          items: items,
                          hint: 'Pilih Diagnosis atau Tidak Ada',
                          onChanged: (value) {
                            setState(() {
                              _selectedDiagnosis = value;
                              // Clear dependent fields if diagnosis is cleared
                              if (value == null) {
                                formKey.currentState?.fields['intervensi']
                                    ?.didChange([]);
                                formKey.currentState?.fields['tujuan']
                                    ?.didChange(null);
                                formKey.currentState?.fields['kriteria']
                                    ?.didChange(null);
                                formKey.currentState?.fields['rasional']
                                    ?.didChange(null);
                              }
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 16),

                      // Intervensi checkboxes (only if renpra is selected)
                      if (_selectedDiagnosis != null) ...[
                        const Text('Intervensi'),
                        const SizedBox(height: 8),
                        Obx(() {
                          final interventions =
                              _interventionController.interventions;
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
                        const CustomTextField(
                          name: 'tujuan',
                          label: 'Tujuan',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        const CustomTextField(
                          name: 'kriteria',
                          label: 'Kriteria',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        const CustomTextField(
                          name: 'rasional',
                          label: 'Rasional',
                          maxLines: 3,
                        ),
                      ],
                    ],
                  ),
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
