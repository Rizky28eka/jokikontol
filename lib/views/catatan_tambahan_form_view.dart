import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tamajiwa/services/logger_service.dart';

import '../controllers/form_controller.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../controllers/patient_controller.dart';
import '../models/patient_model.dart';
import '../services/nursing_data_global_service.dart';
import '../utils/form_builder_mixin.dart';
import '../widgets/form_components/custom_checkbox_group.dart';

class CatatanTambahanFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const CatatanTambahanFormView({super.key, this.patient, this.formId});

  @override
  State<CatatanTambahanFormView> createState() =>
      _CatatanTambahanFormViewState();
}

class _CatatanTambahanFormViewState extends State<CatatanTambahanFormView> with FormBuilderMixin {
  final LoggerService _logger = LoggerService();
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

  int? _selectedDiagnosis;

  @override
  void initState() {
    super.initState();
    _currentPatient = widget.patient ?? Get.arguments?['patient'] as Patient?;
    _currentPatientId =
        _currentPatient?.id ?? Get.arguments?['patientId'] as int?;

    _logger.info(
      'Initializing CatatanTambahanFormView',
      context: {
        'formId': formId,
        'patientId': _currentPatientId,
        'isNewForm': formId == null,
      },
    );

    initializeForm(
      patient: _currentPatient,
      patientId: _currentPatientId,
      formId: formId,
    );
  }

  @override
  Map<String, dynamic> transformInitialData(Map<String, dynamic> data) {
    _logger.debug('Transforming initial data for CatatanTambahan view', context: {'data': data});
    // The reverse mapper has already flattened the data.
    // We just need to handle view-specific state here.
    if (data['diagnosis'] != null) {
      _selectedDiagnosis = data['diagnosis'];
    }
    return data;
  }

  @override
  Map<String, dynamic> transformFormData(Map<String, dynamic> formData) {
    _logger.debug('Transforming form data for submission from CatatanTambahan view', context: {'formData': formData});
    // The forward mapper will handle the complex transformation.
    // The mixin's transform handles generic conversions like DateTime.
    return super.transformFormData(formData);
  }

  @override
  Widget build(BuildContext context) {
    _logger.trace('Building CatatanTambahanFormView');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isNew = formId == null;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(isNew ? 'Form Catatan Tambahan' : 'Edit Catatan Tambahan'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;
          return FormBuilder(
            key: formKey,
            initialValue: initialValues,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWideScreen ? 48.0 : 20.0,
                      vertical: 24.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildInfoCard(
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                              title: 'Catatan Perkembangan',
                              child: _buildTextField(
                                name: 'kategori',
                                label: 'Kategori',
                                tooltip: 'Kategori catatan (misal: Perkembangan, Observasi, Evaluasi)',
                                colorScheme: colorScheme,
                                hint: 'Misal: Perkembangan / Observasi / Evaluasi',
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoCard(
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                              title: 'Detail Catatan',
                              child: Column(
                                children: [
                                  _buildDateField(
                                    name: 'tanggal_catatan',
                                    label: 'Tanggal Catatan',
                                    tooltip: 'Tanggal catatan dibuat',
                                    colorScheme: colorScheme,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    name: 'waktu_catatan',
                                    label: 'Waktu Catatan',
                                    tooltip: 'Waktu catatan dibuat (Format: HH:mm)',
                                    colorScheme: colorScheme,
                                    hint: 'HH:mm',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    name: 'isi_catatan',
                                    label: 'Isi Catatan',
                                    tooltip: 'Isi dari catatan perkembangan pasien',
                                    colorScheme: colorScheme,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    name: 'tindak_lanjut',
                                    label: 'Tindak Lanjut',
                                    tooltip: 'Tindakan lanjutan yang direncanakan atau dilakukan',
                                    colorScheme: colorScheme,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoCard(
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                              title: 'Rencana Perawatan (Renpra) - Opsional',
                              child: _buildRenpraSection(
                                colorScheme,
                                textTheme,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildBottomActionBar(colorScheme, textTheme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRenpraSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Obx(() {
          final diagnoses = Get.find<NursingDataGlobalService>().diagnoses;
          if (diagnoses.isEmpty) {
            return const Center(child: Text('Data diagnosis tidak tersedia.'));
          }
          return _buildDropdown<int>(
            name: 'diagnosis',
            label: 'Diagnosis',
            tooltip: 'Pilih diagnosis keperawatan yang sesuai',
            items: diagnoses
                .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                .toList(),
            hint: 'Pilih Diagnosis (Opsional)',
            onChanged: (value) {
              _logger.info('Diagnosis changed', context: {'newDiagnosisId': value});
              setState(() {
                _selectedDiagnosis = value;
                // Clear dependent fields if diagnosis is cleared
                if (value == null) {
                  formKey.currentState?.fields['intervensi']?.didChange([]);
                  formKey.currentState?.fields['tujuan']?.didChange(null);
                  formKey.currentState?.fields['kriteria']?.didChange(null);
                  formKey.currentState?.fields['rasional']?.didChange(null);
                }
              });
            },
            colorScheme: colorScheme,
            icon: Icons.medical_information_outlined,
          );
        }),
        if (_selectedDiagnosis != null)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInterventionSection(colorScheme, textTheme),
                const SizedBox(height: 20),
                _buildTextField(
                  name: 'tujuan',
                  label: 'Tujuan',
                  tooltip: 'Tujuan perawatan yang ingin dicapai',
                  colorScheme: colorScheme,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  name: 'kriteria',
                  label: 'Kriteria Evaluasi',
                  tooltip: 'Kriteria untuk mengevaluasi pencapaian tujuan',
                  colorScheme: colorScheme,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  name: 'rasional',
                  label: 'Rasional',
                  tooltip: 'Alasan atau landasan mengapa intervensi dipilih',
                  colorScheme: colorScheme,
                  maxLines: 3,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInterventionSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intervensi',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Obx(() {
            final interventions = _interventionController.interventions;
            if (interventions.isEmpty) {
              return const Center(
                child: Text('Tidak ada intervensi tersedia.'),
              );
            }
            return CustomCheckboxGroup<int>(
              name: 'intervensi',
              label: '', // Label is handled outside
              tooltip: 'Pilih intervensi yang akan dilakukan',
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
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String name,
    required String label,
    required ColorScheme colorScheme,
    TextInputType? keyboardType,
    int? maxLines = 1,
    String? hint,
    String? tooltip,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            if (tooltip != null) Tooltip(
              message: tooltip,
              child: Icon(Icons.info_outline, size: 16, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FormBuilderTextField(
          name: name,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String name,
    required String label,
    required ColorScheme colorScheme,
    String? tooltip,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            if (tooltip != null) Tooltip(
              message: tooltip,
              child: Icon(Icons.info_outline, size: 16, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FormBuilderDateTimePicker(
          name: name,
          inputType: InputType.date,
          format: DateFormat('dd/MM/yyyy'),
          decoration: InputDecoration(
            hintText: 'Pilih tanggal',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            suffixIcon: const Icon(Icons.calendar_today),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String name,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required ColorScheme colorScheme,
    IconData? icon,
    String? hint,
    ValueChanged<T?>? onChanged,
    String? tooltip,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            if (tooltip != null) Tooltip(
              message: tooltip,
              child: Icon(Icons.info_outline, size: 16, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FormBuilderDropdown<T>(
          name: name,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            prefixIcon: icon != null
                ? Icon(icon, color: colorScheme.primary, size: 22)
                : null,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
          dropdownColor: colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: formController.isLoading
                      ? null
                      : () {
                          _logger.userInteraction(
                            'Save Catatan Tambahan',
                            page: 'CatatanTambahanFormView',
                            element: 'SaveButton',
                          );
                          submitForm();
                        },
                  icon: formController.isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.save_alt_rounded),
                  label: formController.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme
                                .onPrimary, // Changed to onPrimary for visibility on dark backgrounds if any
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme
                        .primary, // Ensure button has a background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}