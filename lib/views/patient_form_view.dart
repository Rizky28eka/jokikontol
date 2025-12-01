import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'genogram_builder_view.dart';
import '../controllers/patient_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/form_controller.dart';
import '../models/patient_model.dart';
import '../services/logger_service.dart';

class PatientFormView extends StatefulWidget {
  final Patient? patient;
  final String? formType;

  const PatientFormView({super.key, this.patient, this.formType});

  @override
  State<PatientFormView> createState() => _PatientFormViewState();
}

class _PatientFormViewState extends State<PatientFormView> {
  final PatientController patientController = Get.find();
  final FormController formController = Get.find();
  final LoggerService _logger = LoggerService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _addressController;
  late final TextEditingController _rmNumberController;

  String _selectedGender = 'L';
  Map<String, dynamic>? _lastGenogramStructure;
  String _lastGenogramNotes = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _addressController = TextEditingController();
    _rmNumberController = TextEditingController();

    _logger.form(
      operation: 'PatientFormView initialized',
      formType: widget.formType ?? 'PatientForm',
      patientId: widget.patient?.id.toString(),
      metadata: {
        'isEditing': widget.patient != null,
        'formType': widget.formType ?? 'PatientForm',
      },
    );

    _populateFormData();
    // Load the latest genogram for this patient if available
    Future.microtask(() async {
      await _loadLatestGenogram();
    });
  }

  void _populateFormData() {
    if (widget.patient != null) {
      _nameController.text = widget.patient!.name;
      _selectedGender = widget.patient!.gender;
      _ageController.text = widget.patient!.age.toString();
      _addressController.text = widget.patient!.address;
      _rmNumberController.text = widget.patient!.rmNumber;

      _logger.form(
        operation: 'Patient form loaded for editing',
        formType: widget.formType ?? 'PatientForm',
        patientId: widget.patient?.id.toString(),
        data: {
          'name': widget.patient!.name,
          'gender': widget.patient!.gender,
          'age': widget.patient!.age,
          'address': widget.patient!.address,
          'rmNumber': widget.patient!.rmNumber,
        },
        metadata: {'formType': widget.formType ?? 'PatientForm'},
      );
    } else {
      _logger.form(
        operation: 'Patient form loaded for creation',
        formType: widget.formType ?? 'PatientForm',
        patientId: null,
        metadata: {'formType': widget.formType ?? 'PatientForm'},
      );
    }
  }

  Future<void> _loadLatestGenogram() async {
    final patientId = widget.patient?.id;
    if (patientId == null) return;
    try {
      await formController.fetchForms(patientId: patientId);
      final formsWithGenogram = formController.forms
          .where((f) => f.patientId == patientId && f.genogram != null)
          .toList();
      if (formsWithGenogram.isNotEmpty) {
        final latest = formsWithGenogram.first;
        if (latest.genogram?.structure != null) {
          setState(() {
            _lastGenogramStructure = Map<String, dynamic>.from(
              latest.genogram!.structure!,
            );
            _lastGenogramNotes = latest.genogram!.notes ?? '';
          });
        }
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  void dispose() {
    _logger.form(
      operation: 'PatientFormView disposed',
      formType: widget.formType ?? 'PatientForm',
      patientId: widget.patient?.id.toString(),
    );

    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _rmNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Prevent double submission
    if (_isSubmitting) return;

    // Unfocus to trigger validation and hide keyboard
    FocusScope.of(context).unfocus();

    _logger.form(
      operation: 'Patient form submission started',
      formType: widget.formType ?? 'PatientForm',
      patientId: widget.patient?.id.toString(),
      data: {
        'name': _nameController.text.trim(),
        'gender': _selectedGender,
        'age': _ageController.text.trim(),
        'address': _addressController.text.trim(),
        'rmNumber': _rmNumberController.text.trim(),
      },
      metadata: {
        'isEditing': widget.patient != null,
        'formType': widget.formType ?? 'PatientForm',
      },
    );

    if (!_formKey.currentState!.validate()) {
      _logger.warning(
        'Patient form validation failed',
        context: {
          'formType': widget.formType ?? 'PatientForm',
          'patientId': widget.patient?.id.toString(),
          'formData': {
            'name': _nameController.text.trim(),
            'gender': _selectedGender,
            'age': _ageController.text.trim(),
            'address': _addressController.text.trim(),
            'rmNumber': _rmNumberController.text.trim(),
          },
        },
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final name = _nameController.text.trim();
      final age = int.parse(_ageController.text.trim());
      final address = _addressController.text.trim();
      final rmNumber = _rmNumberController.text.trim();

      if (widget.patient == null) {
        // Create new patient
        _logger.patient(
          operation: 'Creating new patient',
          metadata: {
            'formType': widget.formType ?? 'PatientForm',
            'name': name,
            'gender': _selectedGender,
            'age': age,
            'address': address,
            'rmNumber': rmNumber,
          },
        );

        final createdPatient = await patientController.createPatient(
          name: name,
          gender: _selectedGender,
          age: age,
          address: address,
          rmNumber: rmNumber,
        );

        _logger.patient(
          operation: 'Patient created successfully',
          metadata: {
            'formType': widget.formType ?? 'PatientForm',
            'name': name,
            'gender': _selectedGender,
            'age': age,
            'address': address,
            'rmNumber': rmNumber,
          },
        );

        if (mounted) {
          // If the dashboard controller is active, update its data as well (handles direct navigation case)
          if (Get.isRegistered<DashboardController>()) {
            await Get.find<DashboardController>().fetchLatestPatients();
            await Get.find<DashboardController>().fetchMahasiswaStats();
          }
          // Return the created patient to the previous screen so it can refresh or use the new record
          Get.back(result: createdPatient ?? true);
          Get.snackbar(
            'Berhasil',
            'Pasien berhasil ditambahkan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        // Update existing patient
        _logger.patient(
          operation: 'Updating existing patient',
          patientId: widget.patient!.id.toString(),
          metadata: {
            'formType': widget.formType ?? 'PatientForm',
            'name': name,
            'gender': _selectedGender,
            'age': age,
            'address': address,
            'rmNumber': rmNumber,
          },
        );

        final updatedPatient = await patientController.updatePatient(
          id: widget.patient!.id,
          name: name,
          gender: _selectedGender,
          age: age,
          address: address,
          rmNumber: rmNumber,
        );

        _logger.patient(
          operation: 'Patient updated successfully',
          patientId: widget.patient!.id.toString(),
          metadata: {
            'formType': widget.formType ?? 'PatientForm',
            'name': name,
            'gender': _selectedGender,
            'age': age,
            'address': address,
            'rmNumber': rmNumber,
          },
        );

        if (mounted) {
          if (Get.isRegistered<DashboardController>()) {
            await Get.find<DashboardController>().fetchLatestPatients();
            await Get.find<DashboardController>().fetchMahasiswaStats();
          }
          Get.back(result: updatedPatient ?? true);
          Get.snackbar(
            'Berhasil',
            'Data pasien berhasil diperbarui',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      }

      _logger.navigation(
        from: 'PatientFormView',
        to: 'PreviousScreen',
        arguments: {
          'formType': widget.formType ?? 'PatientForm',
          'patientId': widget.patient?.id.toString(),
          'isEditing': widget.patient != null,
          'success': true,
        },
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Patient form submission failed',
        error: e,
        stackTrace: stackTrace,
        context: {
          'formType': widget.formType ?? 'PatientForm',
          'patientId': widget.patient?.id.toString(),
          'isEditing': widget.patient != null,
          'formData': {
            'name': _nameController.text.trim(),
            'gender': _selectedGender,
            'age': _ageController.text.trim(),
            'address': _addressController.text.trim(),
            'rmNumber': _rmNumberController.text.trim(),
          },
        },
      );

      if (mounted) {
        Get.snackbar(
          'Error',
          'Gagal menyimpan data pasien: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    // Check if form has been modified
    final hasChanges = widget.patient == null
        ? _nameController.text.isNotEmpty ||
              _ageController.text.isNotEmpty ||
              _addressController.text.isNotEmpty ||
              _rmNumberController.text.isNotEmpty
        : (widget.patient != null)
        ? _nameController.text != widget.patient!.name ||
              _selectedGender != widget.patient!.gender ||
              _ageController.text != widget.patient!.age.toString() ||
              _addressController.text != widget.patient!.address ||
              _rmNumberController.text != widget.patient!.rmNumber
        : _nameController.text.isNotEmpty ||
              _ageController.text.isNotEmpty ||
              _addressController.text.isNotEmpty ||
              _rmNumberController.text.isNotEmpty;

    if (!hasChanges) {
      _logger.userInteraction(
        'Patient form back button pressed - no changes',
        page: 'PatientFormView',
        element: 'BackButton',
      );
      return true;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
          'Ada perubahan yang belum disimpan. Yakin ingin keluar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldPop == true) {
      _logger.userInteraction(
        'Patient form back button pressed - changes discarded',
        page: 'PatientFormView',
        element: 'BackButton',
        data: {
          'formType': widget.formType ?? 'PatientForm',
          'patientId': widget.patient?.id.toString(),
          'isEditing': widget.patient != null,
        },
      );
    }

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient == null ? 'Tambah Pasien' : 'Edit Pasien'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildGenderSelection(),
                  const SizedBox(height: 16),
                  _buildAgeField(),
                  const SizedBox(height: 16),
                  _buildAddressField(),
                  const SizedBox(height: 16),
                  _buildRmNumberField(),
                  const SizedBox(height: 24),
                  // If there is a genogram saved for this patient (from forms), show a small preview
                  if (_lastGenogramStructure != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Genogram Terakhir',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            if ((_lastGenogramStructure?['members'] as List?)
                                    ?.isEmpty ??
                                true)
                              const Text('Tidak ada anggota genogram.'),
                            if ((_lastGenogramStructure?['members'] as List?)
                                    ?.isNotEmpty ??
                                false)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    (_lastGenogramStructure?['members'] as List)
                                        .length,
                                itemBuilder: (context, index) {
                                  final m =
                                      (_lastGenogramStructure?['members']
                                              as List)[index]
                                          as Map<String, dynamic>;
                                  return ListTile(
                                    title: Text(m['name'] ?? 'Unknown'),
                                    subtitle: Text(
                                      '${m['relationship'] ?? ''} • ${m['age'] ?? ''}',
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FilledButton.tonal(
                                  onPressed: () {
                                    final struct =
                                        _lastGenogramStructure ??
                                        {'members': [], 'connections': []};
                                    Get.to(
                                      () => GenogramBuilderView(
                                        initialData: {
                                          'structure': struct,
                                          'notes': _lastGenogramNotes,
                                        },
                                      ),
                                      arguments: {'readOnly': true},
                                    );
                                  },
                                  child: const Text('View Genogram'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Obx(() {
                    final isLoading =
                        patientController.isLoading.value || _isSubmitting;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _submitForm(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3.0,
                                ),
                              )
                            : Text(
                                widget.patient == null ? 'Simpan' : 'Perbarui',
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nama',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.person),
            hintText: 'Masukkan nama pasien',
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          validator: (value) {
            final trimmedValue = value?.trim();
            if (trimmedValue == null || trimmedValue.isEmpty) {
              _logger.warning(
                'Name validation failed',
                context: {
                  'formType': widget.formType ?? 'PatientForm',
                  'value': value,
                },
              );
              return 'Nama harus diisi';
            }
            if (trimmedValue.length < 3) {
              return 'Nama minimal 3 karakter';
            }
            return null;
          },
          onChanged: (value) {
            _logger.userInteraction(
              'Name field changed',
              page: 'PatientFormView',
              element: 'NameTextField',
              data: {
                'formType': widget.formType ?? 'PatientForm',
                'valueLength': value.length,
                'patientId': widget.patient?.id.toString(),
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jenis Kelamin',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Laki-laki'),
                    value: 'L',
                    groupValue: _selectedGender,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      if (value != null) {
                        _logger.userInteraction(
                          'Gender selected',
                          element: 'GenderRadio_L',
                          data: {
                            'formType': widget.formType ?? 'PatientForm',
                            'selectedValue': value,
                            'previousValue': _selectedGender,
                            'patientId': widget.patient?.id.toString(),
                          },
                        );
                        setState(() => _selectedGender = value);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Perempuan'),
                    value: 'P',
                    groupValue: _selectedGender,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      if (value != null) {
                        _logger.userInteraction(
                          'Gender selected',
                          element: 'GenderRadio_P',
                          data: {
                            'formType': widget.formType ?? 'PatientForm',
                            'selectedValue': value,
                            'previousValue': _selectedGender,
                            'patientId': widget.patient?.id.toString(),
                          },
                        );
                        setState(() => _selectedGender = value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeField() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: _ageController,
          decoration: const InputDecoration(
            labelText: 'Usia',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.cake),
            hintText: 'Masukkan usia',
            suffixText: 'tahun',
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          validator: (value) {
            final trimmedValue = value?.trim();
            if (trimmedValue == null || trimmedValue.isEmpty) {
              _logger.warning(
                'Age validation failed - empty value',
                context: {
                  'formType': widget.formType ?? 'PatientForm',
                  'value': value,
                },
              );
              return 'Usia harus diisi';
            }
            final age = int.tryParse(trimmedValue);
            if (age == null) {
              return 'Usia harus berupa angka';
            }
            if (age < 0) {
              return 'Usia tidak boleh negatif';
            }
            if (age > 150) {
              _logger.warning(
                'Age validation failed - invalid age',
                context: {
                  'formType': widget.formType ?? 'PatientForm',
                  'value': value,
                  'parsedAge': age,
                },
              );
              return 'Usia tidak valid (maksimal 150 tahun)';
            }
            return null;
          },
          onChanged: (value) {
            _logger.userInteraction(
              'Age field changed',
              element: 'AgeTextField',
              data: {
                'formType': widget.formType ?? 'PatientForm',
                'value': value,
                'patientId': widget.patient?.id.toString(),
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddressField() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Alamat',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.location_on),
            hintText: 'Masukkan alamat lengkap',
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          validator: (value) {
            final trimmedValue = value?.trim();
            if (trimmedValue == null || trimmedValue.isEmpty) {
              _logger.warning(
                'Address validation failed',
                context: {
                  'formType': widget.formType ?? 'PatientForm',
                  'value': value,
                },
              );
              return 'Alamat harus diisi';
            }
            if (trimmedValue.length < 10) {
              return 'Alamat minimal 10 karakter';
            }
            return null;
          },
          onChanged: (value) {
            _logger.userInteraction(
              'Address field changed',
              element: 'AddressTextField',
              data: {
                'formType': widget.formType ?? 'PatientForm',
                'valueLength': value.length,
                'patientId': widget.patient?.id.toString(),
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRmNumberField() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: _rmNumberController,
          decoration: const InputDecoration(
            labelText: 'Nomor RM',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.description),
            hintText: 'Masukkan nomor rekam medis',
          ),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submitForm(),
          validator: (value) {
            final trimmedValue = value?.trim();
            if (trimmedValue == null || trimmedValue.isEmpty) {
              _logger.warning(
                'RM number validation failed',
                context: {
                  'formType': widget.formType ?? 'PatientForm',
                  'value': value,
                },
              );
              return 'Nomor RM harus diisi';
            }
            if (trimmedValue.length < 3) {
              return 'Nomor RM minimal 3 karakter';
            }
            return null;
          },
          onChanged: (value) {
            _logger.userInteraction(
              'RM number field changed',
              element: 'RmNumberTextField',
              data: {
                'formType': widget.formType ?? 'PatientForm',
                'valueLength': value.length,
                'patientId': widget.patient?.id.toString(),
              },
            );
          },
        ),
      ),
    );
  }
}
