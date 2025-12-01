import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/form_model.dart';
import '../services/logger_service.dart';
import '../services/role_guard.dart';
import 'genogram_builder_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FormDetailView extends StatefulWidget {
  const FormDetailView({super.key});

  @override
  State<FormDetailView> createState() => _FormDetailViewState();
}

class _FormDetailViewState extends State<FormDetailView> {
  final FormController formController = Get.put(FormController());
  final AuthController authController = Get.find<AuthController>();
  final LoggerService _logger = LoggerService();
  final TextEditingController _commentController = TextEditingController();

  late FormModel form;
  bool isLecturer = false; // legacy flag retained for minimal change
  bool _genogramAvailable = false;

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
    isLecturer = RoleGuard.isDosen();
    _genogramAvailable = form.genogram != null || (form.data != null && (form.data!['section_9']?['structure'] != null || form.data!['genogram']?['structure'] != null));
  }

  // Prevent unexpected setState during hot reload by pausing auto-refresh logic
  @override
  void reassemble() {
    // Avoid triggering async refreshes automatically during hot reload.
    // Keeps the widget stable when Flutter rebuilds the tree.
    super.reassemble();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  int _genogramMemberCount() {
    if (form.genogram?.structure != null) return (form.genogram!.structure!['members'] as List?)?.length ?? 0;
    if (form.data?['section_9']?['structure'] != null) return (form.data!['section_9']['structure']['members'] as List?)?.length ?? 0;
    if (form.data?['genogram']?['structure'] != null) return (form.data!['genogram']['structure']['members'] as List?)?.length ?? 0;
    return 0;
  }

  int _genogramConnectionCount() {
    if (form.genogram?.structure != null) return (form.genogram!.structure!['connections'] as List?)?.length ?? 0;
    if (form.data?['section_9']?['structure'] != null) return (form.data!['section_9']['structure']['connections'] as List?)?.length ?? 0;
    if (form.data?['genogram']?['structure'] != null) return (form.data!['genogram']['structure']['connections'] as List?)?.length ?? 0;
    return 0;
  }

  Future<void> _refreshFormData() async {
    _logger.info('Refreshing form detail data');
    // Fetch the specific form by id to ensure we get the full payload (data included)
    final fetchedForm = await formController.getFormById(form.id);
    if (!mounted) return;
    if (fetchedForm != null) {
      setState(() {
        form = fetchedForm;
        _commentController.text = form.comments ?? '';
      });
    }
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

  List<Widget> _buildFormDataCards() {
    final cards = <Widget>[];
    form.data!.forEach((key, value) {
      if (value == null) return;
      
      String title = _formatSectionTitle(key);
      Widget content;

      if (value is Map) {
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: value.entries.map((e) {
            if (e.value == null || e.value.toString().isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      _formatFieldName(e.key),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text(
                      e.value.toString(),
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      } else {
        content = Text(
          value.toString(),
          style: TextStyle(color: Colors.grey[700]),
        );
      }

      cards.add(
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 16),
                content,
              ],
            ),
          ),
        ),
      );
    });
    return cards;
  }

  String _formatSectionTitle(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatFieldName(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
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
    if (!mounted) return;
    setState(() {
      form = form.copyWith(status: status, comments: _commentController.text);
    });

    if (!mounted) return;
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
      body: RefreshIndicator(
        onRefresh: _refreshFormData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                          const Text(
                            'Status: ',
                            style: TextStyle(fontSize: 16),
                          ),
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

              // Form Data Preview
              const Text(
                'Data Form',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (form.data != null && form.data!.isNotEmpty)
                ..._buildFormDataCards()
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Tidak ada data form',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              if (_genogramAvailable) ...[
                const Text(
                  'Genogram',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Anggota: ${_genogramMemberCount()}'),
                              const SizedBox(height: 6),
                              Text('Hubungan: ${_genogramConnectionCount()}'),
                            ],
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: () {
                            // open builder in read-only mode
                            final struct = form.genogram?.structure ?? (form.data?['genogram']?['structure'] ?? form.data?['section_9']?['structure']);
                            final notes = form.genogram?.notes ?? (form.data?['genogram']?['notes'] ?? form.data?['section_9']?['notes']) ?? '';
                            Get.to(() => GenogramBuilderView(initialData: {'structure': struct, 'notes': notes}), arguments: {'readOnly': true});
                          },
                          child: const Text('View Genogram'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.tonal(
                          onPressed: () async {
                            // fetch svg and show preview modal
                            final svg = await formController.fetchGenogramSvg(form.id);
                            if (svg == null) {
                              Get.snackbar('Not available', 'Genogram preview not available');
                              return;
                            }
                            Get.dialog(AlertDialog(
                              title: const Text('Genogram Preview'),
                              content: SizedBox(width: 400, height: 200, child: SvgPicture.string(svg, fit: BoxFit.contain)),
                              actions: [
                                TextButton(onPressed: () => Get.back(), child: const Text('Close')),
                              ],
                            ));
                          },
                          child: const Text('Preview SVG'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

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
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
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
      ),
    );
  }
}
