import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/form_model.dart';
import '../services/logger_service.dart';

class FormDetailView extends StatefulWidget {
  const FormDetailView({super.key});

  @override
  State<FormDetailView> createState() => _FormDetailViewState();
}

class _FormDetailViewState extends State<FormDetailView> {
  final FormController formController = Get.find<FormController>();
  final AuthController authController = Get.find<AuthController>();
  final LoggerService _logger = LoggerService();
  final TextEditingController _commentController = TextEditingController();

  late FormModel form;
  bool isLecturer = false;

  @override
  void initState() {
    super.initState();
    // Retrieve form from arguments or fetch if only ID is passed
    final args = Get.arguments;
    if (args is FormModel) {
      form = args;
    } else if (args is Map<String, dynamic> && args['form'] is FormModel) {
      form = args['form'];
    } else {
      // Fallback or error handling
      Get.back();
      return;
    }

    _commentController.text = form.comments ?? '';
    isLecturer = authController.user?.role == 'dosen';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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

  Future<void> _updateStatus(String status) async {
    _logger.userAction(
      action: 'Updating form status',
      metadata: {'formId': form.id.toString(), 'status': status},
    );

    await formController.updateForm(
      id: form.id,
      status: status,
      comments: _commentController.text,
    );

    // Update local form object to reflect changes
    setState(() {
      form = form.copyWith(status: status, comments: _commentController.text);
    });

    Get.snackbar(
      'Sukses',
      'Status form berhasil diperbarui',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Form'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFormTitle(form.type),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Status: ', style: TextStyle(fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              form.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _getStatusColor(form.status),
                            ),
                          ),
                          child: Text(
                            _getStatusText(form.status),
                            style: TextStyle(
                              color: _getStatusColor(form.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tanggal Dibuat: ${form.createdAt.toString().substring(0, 16)}',
                    ),
                    Text(
                      'Terakhir Diupdate: ${form.updatedAt.toString().substring(0, 16)}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form Data Preview (Simplified)
            const Text(
              'Data Form',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: form.data != null && form.data!.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: form.data!.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text('${entry.key}: ${entry.value}'),
                          );
                        }).toList(),
                      )
                    : const Text('Tidak ada data form'),
              ),
            ),
            const SizedBox(height: 24),

            // Lecturer Feedback Section
            const Text(
              'Komentar & Persetujuan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (isLecturer) ...[
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Komentar Dosen',
                  border: OutlineInputBorder(),
                  hintText: 'Tambahkan catatan atau revisi disini...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('revised'),
                      icon: const Icon(Icons.warning, color: Colors.white),
                      label: const Text('Minta Revisi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('approved'),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text('Setujui'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Student View of Comments
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catatan Dosen:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      form.comments != null && form.comments!.isNotEmpty
                          ? form.comments!
                          : 'Belum ada komentar.',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
