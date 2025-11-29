import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamajiwa/controllers/patient_controller.dart';
import '../controllers/form_controller.dart';
import '../models/patient_model.dart';
import '../models/form_model.dart';
import '../services/logger_service.dart';
import 'form_detail_view.dart';

class FormSelectionView extends StatelessWidget {
  final LoggerService _logger = LoggerService();

  FormSelectionView({super.key});

  final List<FormType> _formTypes = [
    FormType(
      type: 'pengkajian',
      title: 'Pengkajian Kesehatan Jiwa',
      description: 'Formulir pengkajian awal klien',
      icon: Icons.medical_information,
    ),
    FormType(
      type: 'resume_kegawatdaruratan',
      title: 'Resume Kegawatdaruratan Psikiatri',
      description: 'Resume untuk kasus kegawatdaruratan psikiatri',
      icon: Icons.emergency,
    ),
    FormType(
      type: 'resume_poliklinik',
      title: 'Resume Poliklinik',
      description: 'Resume untuk kunjungan poliklinik',
      icon: Icons.local_hospital,
    ),
    FormType(
      type: 'sap',
      title: 'SAP (Satuan Acara Penyuluhan)',
      description: 'Satuan acara penyuluhan kesehatan',
      icon: Icons.school,
    ),
    FormType(
      type: 'catatan_tambahan',
      title: 'Catatan Tambahan',
      description: 'Catatan tambahan untuk dokumentasi',
      icon: Icons.note_add,
    ),
  ];

  Future<void> _createForm(String formType) async {
    final int patientId =
        int.tryParse(Get.arguments?['patientId']?.toString() ?? '0') ?? 0;
    final String patientName =
        Get.arguments?['patientName']?.toString() ?? 'Unknown Patient';

    final formController = Get.find<FormController>();
    final patientController = Get.find<PatientController>();
    _logger.form(
      operation: 'Creating new form',
      formType: formType,
      patientId: patientId.toString(),
      metadata: {'patientName': patientName, 'formType': formType},
    );

    try {
      final patient = await patientController.getPatientById(patientId);

      // If patient is not found, create a placeholder with minimal required data
      final Patient selectedPatient =
          patient ??
          Patient(
            id: patientId,
            name: patientName,
            gender: 'N/A',
            age: 0,
            address: 'N/A',
            rmNumber: 'N/A',
            createdById: 0, // Default to 0 if not available
            createdAt: DateTime.now(), // Use current time as default
            updatedAt: DateTime.now(), // Use current time as default
          );

      await formController.createForm(
        type: formType,
        patientId: patientId,
        status: 'draft',
      );

      String route = _getFormRoute(formType);
      if (route.isNotEmpty) {
        final forms = formController.forms
            .where(
              (form) => form.type == formType && form.patientId == patientId,
            )
            .toList();

        if (forms.isNotEmpty) {
          Get.toNamed(
            route,
            arguments: {
              'formId': forms.last.id,
              'patient': selectedPatient,
              'formType': formType,
            },
          );
        } else {
          Get.toNamed(
            route,
            arguments: {'patient': selectedPatient, 'formType': formType},
          );
        }
      } else {
        _logger.warning(
          'Unknown form type selected',
          context: {'formType': formType},
        );
      }
    } catch (e) {
      _logger.error(
        'Failed to create form',
        error: e,
        context: {
          'formType': formType,
          'patientId': patientId,
          'patientName': patientName,
        },
      );
      Get.snackbar('Error', 'Gagal membuat form: ${e.toString()}');
    }
  }

  String _getFormRoute(String formType) {
    switch (formType) {
      case 'pengkajian':
        return '/mental-health-assessment-form';
      case 'resume_kegawatdaruratan':
        return '/resume-kegawatdaruratan-form';
      case 'resume_poliklinik':
        return '/resume-poliklinik-form';
      case 'sap':
        return '/sap-form';
      case 'catatan_tambahan':
        return '/catatan-tambahan-form';
      default:
        return '';
    }
  }

  Future<List<FormModel>> _getExistingForms() async {
    final int patientId =
        int.tryParse(Get.arguments?['patientId']?.toString() ?? '0') ?? 0;

    final formController = Get.find<FormController>();

    // Fetch forms specifically for this patient
    await formController.fetchForms(patientId: patientId);

    return formController.forms;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.orange;
      case 'submitted':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'revised':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'draft':
        return Icons.drafts;
      case 'submitted':
        return Icons.send;
      case 'approved':
        return Icons.check_circle;
      case 'revised':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'submitted':
        return 'Menunggu Review';
      case 'approved':
        return 'Disetujui';
      case 'revised':
        return 'Perlu Revisi';
      default:
        return status;
    }
  }

  IconData _getFormIcon(String type) {
    switch (type) {
      case 'pengkajian':
        return Icons.medical_information;
      case 'resume_kegawatdaruratan':
        return Icons.emergency;
      case 'resume_poliklinik':
        return Icons.local_hospital;
      case 'sap':
        return Icons.school;
      case 'catatan_tambahan':
        return Icons.note_add;
      default:
        return Icons.description;
    }
  }

  String _getFormTitle(String type) {
    switch (type) {
      case 'pengkajian':
        return 'Pengkajian Kesehatan Jiwa';
      case 'resume_kegawatdaruratan':
        return 'Resume Kegawatdaruratan Psikiatri';
      case 'resume_poliklinik':
        return 'Resume Poliklinik';
      case 'sap':
        return 'SAP (Satuan Acara Penyuluhan)';
      case 'catatan_tambahan':
        return 'Catatan Tambahan';
      default:
        return type;
    }
  }

  void _openExistingForm(FormModel form) {
    final int patientId =
        int.tryParse(Get.arguments?['patientId']?.toString() ?? '0') ?? 0;
    final String patientName =
        Get.arguments?['patientName']?.toString() ?? 'Unknown Patient';

    // Get the route based on form type
    String route = _getFormRoute(form.type);
    if (route.isNotEmpty) {
      // Navigate to the form with the existing form data
      Get.toNamed(
        route,
        arguments: {
          'formId': form.id,
          'patientId': patientId,
          'patientName': patientName,
          'formType': form.type,
        },
      );
    } else {
      _logger.warning(
        'Unknown form type for existing form',
        context: {'formType': form.type, 'formId': form.id},
      );
      Get.snackbar('Error', 'Tipe form tidak dikenali');
    }
  }

  void _showFormOptions(FormModel form) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Opsi Form',
              style: Theme.of(
                Get.context!,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Form'),
              onTap: () {
                Get.back(); // Close bottom sheet
                _openExistingForm(form);
              },
            ),
            if (form.status !=
                'approved') // Only show delete option if form is not approved
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Form'),
                onTap: () {
                  Get.back(); // Close bottom sheet
                  _confirmDeleteForm(form);
                },
              ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.grey),
              title: Text('Status: ${_getStatusText(form.status)}'),
              subtitle: Text(
                'Dibuat: ${form.createdAt.toString().substring(0, 19)}',
              ),
              onTap: () {
                Get.back(); // Close bottom sheet
                _showFormDetails(form);
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Get.back(), // Close bottom sheet
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteForm(FormModel form) {
    Get.defaultDialog(
      title: "Konfirmasi Hapus",
      middleText:
          "Apakah Anda yakin ingin menghapus form ${_getFormTitle(form.type)}?\n\nTindakan ini tidak dapat dibatalkan.",
      textCancel: "Batal",
      cancelTextColor: Colors.black54,
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      backgroundColor: Colors.white,
      buttonColor: Colors.red,
      onCancel: () {
        _logger.userAction(
          action: 'Delete form cancelled',
          metadata: {'formId': form.id.toString(), 'formType': form.type},
        );
      },
      onConfirm: () {
        _deleteForm(form);
      },
    );
  }

  Future<void> _deleteForm(FormModel form) async {
    final formController = Get.find<FormController>();

    _logger.form(
      operation: 'Deleting form',
      formType: form.type,
      formId: form.id.toString(),
      metadata: {
        'status': form.status,
        'patientId': Get.arguments?['patientId']?.toString(),
      },
    );

    try {
      final success = await formController.deleteForm(form.id);

      if (success) {
        _logger.form(
          operation: 'Form deleted successfully',
          formType: form.type,
          formId: form.id.toString(),
        );

        Get.snackbar(
          'Berhasil',
          'Form berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        _logger.error(
          'Failed to delete form',
          context: {'formId': form.id.toString(), 'formType': form.type},
        );

        Get.snackbar(
          'Gagal',
          'Gagal menghapus form',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _logger.error(
        'Error deleting form',
        error: e,
        stackTrace: StackTrace.current,
        context: {'formId': form.id.toString(), 'formType': form.type},
      );

      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menghapus form: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showFormDetails(FormModel form) {
    Get.to(() => const FormDetailView(), arguments: form);
  }

  @override
  Widget build(BuildContext context) {
    final String patientName =
        Get.arguments?['patientName']?.toString() ?? 'Unknown Patient';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Jenis Form'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pasien: $patientName',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<FormModel>>(
                future: _getExistingForms(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Memuat Form...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          CircularProgressIndicator(),
                        ],
                      ),
                    );
                  }

                  final existingForms = snapshot.data ?? [];

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Daftar form baru
                        ..._formTypes.map((formType) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                ),
                                child: Icon(
                                  formType.icon,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              title: Text(formType.title),
                              subtitle: Text(formType.description),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                _logger.userAction(
                                  action: 'Form type selected',
                                  metadata: {
                                    'formType': formType.type,
                                    'patientId': Get.arguments?['patientId']
                                        ?.toString(),
                                    'patientName': patientName,
                                  },
                                );
                                _createForm(formType.type);
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                        // Section untuk form yang pernah dibuat
                        if (existingForms.isNotEmpty) ...[
                          const Text(
                            'Form yang Pernah Dibuat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...existingForms.map((form) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getStatusColor(
                                      form.status,
                                    ).withOpacity(0.1),
                                  ),
                                  child: Icon(
                                    _getFormIcon(form.type),
                                    color: _getStatusColor(form.status),
                                  ),
                                ),
                                title: Text(
                                  _getFormTitle(form.type),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status: ${_getStatusText(form.status)}',
                                      style: TextStyle(
                                        color: _getStatusColor(form.status),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Dibuat: ${form.createdAt.toString().substring(0, 19)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getStatusIcon(form.status),
                                      color: _getStatusColor(form.status),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.more_vert),
                                      onPressed: () => _showFormOptions(form),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  _showFormDetails(form);
                                },
                              ),
                            );
                          }),
                        ] else
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Text(
                              'Belum ada form yang pernah dibuat untuk pasien ini',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormType {
  final String type;
  final String title;
  final String description;
  final IconData icon;

  FormType({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
  });
}
