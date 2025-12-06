import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/nursing_diagnosis_controller.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../controllers/review_controller.dart';
import '../models/form_model.dart';
import '../services/logger_service.dart';

class FormReviewView extends StatefulWidget {
  const FormReviewView({super.key});

  @override
  State<FormReviewView> createState() => _FormReviewViewState();
}

class _FormReviewViewState extends State<FormReviewView> {
  final FormController formController = Get.put(FormController());
  final NursingDiagnosisController _diagnosisController = Get.put(
    NursingDiagnosisController(),
  );
  final NursingInterventionController _interventionController = Get.put(
    NursingInterventionController(),
  );
  final TextEditingController _commentController = TextEditingController();
  final RxString _status = 'submitted'.obs;
  final LoggerService _logger = LoggerService();
  late int formId;

  @override
  void initState() {
    super.initState();
    formId = int.parse(Get.parameters['formId'] ?? '0');
    _logger.info('FormReviewView initialized', context: {'formId': formId});
    if (formId != 0) {
      _loadForm(formId);
    }
  }

  Future<void> _loadForm(int id) async {
    final form = await formController.getFormById(id);
    if (form != null) {
      _status.value = form.status;
    }
  }

  Future<void> _reviewForm(String status) async {
    _logger.userInteraction('Review form action selected', page: 'FormReviewView', data: {
      'formId': formId,
      'selectedStatus': status,
      'hasComment': _commentController.text.isNotEmpty,
    });

    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Apakah Anda yakin ingin $status form ini?',
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        TextButton(
          onPressed: () async {
            _logger.userInteraction('Review form confirmed', page: 'FormReviewView', data: {
              'formId': formId,
              'status': status,
              'comment': _commentController.text,
            });

            Get.back(); // Close dialog
            // Call the backend API to review the form
            final reviewController = Get.find<ReviewController>();
            await reviewController.reviewForm(
              formId,
              status,
              _commentController.text,
            );

            if (status == 'approved') {
              _logger.info('Form approved successfully', context: {'formId': formId});
              Get.snackbar('Success', 'Form berhasil disetujui');
            } else {
              _logger.info('Form sent for revision', context: {'formId': formId});
              Get.snackbar('Info', 'Form berhasil dikembalikan untuk revisi');
            }

            // Navigate back to dashboard
            Get.back();
          },
          child: Text(status == 'approved' ? 'Setujui' : 'Minta Revisi'),
        ),
      ],
    );
  }

  Widget _buildFormContent(FormModel form) {
    // This function builds the form content based on its type
    switch (form.type) {
      case 'pengkajian':
        return _buildPengkajianForm(form);
      case 'resume_kegawatdaruratan':
        return _buildResumeKegawatdaruratanForm(form);
      case 'resume_poliklinik':
        return _buildResumePoliklinikForm(form);
      case 'sap':
        return _buildSapForm(form);
      case 'catatan_tambahan':
        return _buildCatatanTambahanForm(form);
      default:
        return _buildGenericForm(form);
    }
  }

  Widget _buildPengkajianForm(FormModel form) {
    final data = form.data ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Form Pengkajian Kesehatan Jiwa',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (data['section_1'] != null) ...[
          const Text(
            'Identitas Klien',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildReadOnlyField(
            'Nama Lengkap',
            data['section_1']['nama_lengkap'],
          ),
          _buildReadOnlyField('Umur', data['section_1']['umur']),
          _buildReadOnlyField(
            'Jenis Kelamin',
            data['section_1']['jenis_kelamin'],
          ),
          _buildReadOnlyField(
            'Status Perkawinan',
            data['section_1']['status_perkawinan'],
          ),
          const SizedBox(height: 16),
        ],
        if (data['section_2'] != null) ...[
          const Text(
            'Riwayat Kehidupan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildReadOnlyField(
            'Riwayat Pendidikan',
            data['section_2']['riwayat_pendidikan'],
          ),
          _buildReadOnlyField('Pekerjaan', data['section_2']['pekerjaan']),
          _buildReadOnlyField(
            'Riwayat Keluarga',
            data['section_2']['riwayat_keluarga'],
          ),
          const SizedBox(height: 16),
        ],
        if (data['section_10'] != null) ...[
          const Text(
            'Rencana Perawatan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildReadOnlyField('Diagnosis', data['section_10']['diagnosis']),
          _buildReadOnlyField('Tujuan', data['section_10']['tujuan']),
          _buildReadOnlyField('Kriteria', data['section_10']['kriteria']),
          _buildReadOnlyField('Rasional', data['section_10']['rasional']),
          const SizedBox(height: 16),
        ],
        // Add more sections as needed
      ],
    );
  }

  Widget _buildResumeKegawatdaruratanForm(FormModel form) {
    final data = form.data ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resume Kegawatdaruratan Psikiatri',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (data['identitas'] != null) ...[
          const Text(
            'Identitas',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildReadOnlyField(
            'Nama Lengkap',
            data['identitas']['nama_lengkap'],
          ),
          _buildReadOnlyField('Umur', data['identitas']['umur']),
          _buildReadOnlyField(
            'Jenis Kelamin',
            data['identitas']['jenis_kelamin'],
          ),
          _buildReadOnlyField('Alamat', data['identitas']['alamat']),
          _buildReadOnlyField(
            'Tanggal Masuk',
            data['identitas']['tanggal_masuk'],
          ),
          const SizedBox(height: 16),
        ],
        if (data['renpra'] != null) ...[
          const Text(
            'Renpra (Rencana Perawatan)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildReadOnlyField('Diagnosis', data['renpra']['diagnosis']),
          _buildReadOnlyField('Tujuan', data['renpra']['tujuan']),
          _buildReadOnlyField('Kriteria', data['renpra']['kriteria']),
          _buildReadOnlyField('Rasional', data['renpra']['rasional']),
          _buildReadOnlyField('Evaluasi', data['renpra']['evaluasi']),
          const SizedBox(height: 16),
        ],
        // Add more sections as needed
      ],
    );
  }

  Widget _buildResumePoliklinikForm(FormModel form) {
    final data = form.data ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resume Poliklinik',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (data['section_1'] != null) ...[
          const Text(
            'Identitas Klien',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildReadOnlyField(
            'Nama Lengkap',
            data['section_1']['nama_lengkap'],
          ),
          _buildReadOnlyField('Umur', data['section_1']['umur']),
          _buildReadOnlyField(
            'Jenis Kelamin',
            data['section_1']['jenis_kelamin'],
          ),
          _buildReadOnlyField(
            'Status Perkawinan',
            data['section_1']['status_perkawinan'],
          ),
          const SizedBox(height: 16),
        ],
        if (data['section_9'] != null) ...[
          const Text(
            'Renpra (Rencana Perawatan)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildReadOnlyField('Diagnosis', data['section_9']['diagnosis']),
          _buildReadOnlyField('Tujuan', data['section_9']['tujuan']),
          _buildReadOnlyField('Kriteria', data['section_9']['kriteria']),
          _buildReadOnlyField('Rasional', data['section_9']['rasional']),
          const SizedBox(height: 16),
        ],
        // Add more sections as needed
      ],
    );
  }

  Widget _buildSapForm(FormModel form) {
    final data = form.data ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Form SAP (Satuan Acara Penyuluhan)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (data['identitas'] != null) ...[
          const Text(
            'Identitas Kegiatan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildReadOnlyField('Topik', data['identitas']['topik']),
          _buildReadOnlyField('Sasaran', data['identitas']['sasaran']),
          _buildReadOnlyField('Waktu', data['identitas']['waktu']),
          _buildReadOnlyField('Tempat', data['identitas']['tempat']),
          const SizedBox(height: 16),
        ],
        if (data['tujuan'] != null) ...[
          const Text('Tujuan', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildReadOnlyField('Tujuan Umum', data['tujuan']['umum']),
          _buildReadOnlyField('Tujuan Khusus', data['tujuan']['khusus']),
          const SizedBox(height: 16),
        ],
        if (data['renpra'] != null) ...[
          const Text(
            'Renpra (Opsional)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildReadOnlyField('Diagnosis', data['renpra']['diagnosis']),
          _buildReadOnlyField('Tujuan', data['renpra']['tujuan']),
          _buildReadOnlyField('Kriteria', data['renpra']['kriteria']),
          _buildReadOnlyField('Rasional', data['renpra']['rasional']),
          const SizedBox(height: 16),
        ],
        // Add more sections as needed
      ],
    );
  }

  Widget _buildCatatanTambahanForm(FormModel form) {
    final data = form.data ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan Tambahan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (data['catatan'] != null) ...[
          const Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildReadOnlyField('Isi Catatan', data['catatan']['isi_catatan']),
          const SizedBox(height: 16),
        ],
        if (data['catatan'] != null && data['catatan']['renpra'] != null) ...[
          const Text(
            'Renpra (Opsional)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildReadOnlyField(
            'Diagnosis',
            data['catatan']['renpra']['diagnosis'],
          ),
          _buildReadOnlyField('Tujuan', data['catatan']['renpra']['tujuan']),
          _buildReadOnlyField(
            'Kriteria',
            data['catatan']['renpra']['kriteria'],
          ),
          _buildReadOnlyField(
            'Rasional',
            data['catatan']['renpra']['rasional'],
          ),
          const SizedBox(height: 16),
        ],
        // Add more sections as needed
      ],
    );
  }

  Widget _buildGenericForm(FormModel form) {
    final data = form.data ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Form Type: ${form.type}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Form Data: ${data.toString()}',
        ), // Fallback for unknown form types
      ],
    );
  }

  Widget _buildReadOnlyField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(_formatFieldValue(label, value) ?? '-'),
          ),
        ],
      ),
    );
  }

  String? _formatFieldValue(String label, dynamic value) {
    if (value == null) return null;
    final lower = label.toLowerCase();
    // Friendly display mapping for common select fields
    if (lower.contains('jenis kelamin')) {
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'l':
          case 'laki-laki':
            return 'Laki-laki';
          case 'p':
          case 'perempuan':
            return 'Perempuan';
          case 'o':
          case 'lainnya':
            return 'Lainnya';
          default:
            return value.toString();
        }
      }
    }
    if (lower.contains('status perkawinan')) {
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'belum_kawin':
          case 'belum kawin':
            return 'Belum Kawin';
          case 'menikah':
            return 'Menikah';
          case 'cerai_hidup':
          case 'cerai hidup':
            return 'Cerai Hidup';
          case 'cerai_mati':
          case 'cerai mati':
            return 'Cerai Mati';
          case 'duda':
            return 'Duda';
          case 'janda':
            return 'Janda';
          default:
            return value.toString();
        }
      }
    }
    if (lower.contains('kesadaran')) {
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'sadar_penuh':
          case 'sadar penuh':
            return 'Sadar Penuh';
          case 'somnolent':
            return 'Somnolent';
          case 'stupor':
            return 'Stupor';
          case 'coma':
            return 'Coma';
          default:
            return value.toString();
        }
      }
    }
    if (lower.contains('orientasi')) {
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'utuh':
            return 'Utuh';
          case 'gangguan':
            return 'Gangguan';
          default:
            return value.toString();
        }
      }
    }
    if (lower.contains('mood')) {
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'normal':
            return 'Normal';
          case 'depresi':
            return 'Depresi';
          case 'ansietas':
            return 'Ansietas';
          case 'iritabel':
            return 'Iritabel';
          case 'labil':
            return 'Labil';
          default:
            return value.toString();
        }
      }
    }
    if (lower.contains('afect') || lower.contains('affect')) {
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'normal':
            return 'Normal';
          case 'flat':
            return 'Flat';
          case 'terhambat':
            return 'Terhambat';
          case 'labil':
            return 'Labil';
          case 'iritabel':
            return 'Iritabel';
          default:
            return value.toString();
        }
      }
    }
    if (lower.contains('intervensi') || lower.contains('intervention')) {
      if (value is List) {
        final names = value.map((id) {
          final found = _interventionController.interventions
              .where((it) => it.id == id)
              .toList();
          final item = found.isNotEmpty ? found.first : null;
          return item != null ? item.name : id.toString();
        }).toList();
        return names.join(', ');
      }
    }

    if (lower.contains('diagnosis')) {
      if (value is int) {
        final found = _diagnosisController.diagnoses
            .where((d) => d.id == value)
            .toList();
        final item = found.isNotEmpty ? found.first : null;
        return item != null ? item.name : value.toString();
      }
      // If it's a list (maybe multiple diagnoses), map names
      if (value is List) {
        final names = value.map((id) {
          final found = _diagnosisController.diagnoses
              .where((d) => d.id == id)
              .toList();
          final item = found.isNotEmpty ? found.first : null;
          return item != null ? item.name : id.toString();
        }).toList();
        return names.join(', ');
      }
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Form'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form content in read-only mode
            Expanded(
              child: FutureBuilder<FormModel?>(
                future: formController.getFormById(formId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || snapshot.data == null) {
                    return const Center(child: Text('Gagal memuat form'));
                  }

                  final form = snapshot.data!;
                  return SingleChildScrollView(child: _buildFormContent(form));
                },
              ),
            ),
            const SizedBox(height: 16),
            // Comment section
            const Text(
              'Komentar Review',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Tambahkan komentar untuk revisi...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: _status.value == 'submitted'
                          ? () => _reviewForm('revised')
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Minta Revisi'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: _status.value == 'submitted'
                          ? () => _reviewForm('approved')
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Setujui'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}