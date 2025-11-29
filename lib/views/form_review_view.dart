import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/review_controller.dart';
import '../models/form_model.dart';

class FormReviewView extends StatefulWidget {
  const FormReviewView({super.key});

  @override
  State<FormReviewView> createState() => _FormReviewViewState();
}

class _FormReviewViewState extends State<FormReviewView> {
  final FormController formController = Get.put(FormController());
  final TextEditingController _commentController = TextEditingController();
  final RxString _status = 'submitted'.obs;
  late int formId;

  @override
  void initState() {
    super.initState();
    formId = int.parse(Get.parameters['formId'] ?? '0');
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
    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Apakah Anda yakin ingin $status form ini?',
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            Get.back(); // Close dialog
            // Call the backend API to review the form
            final reviewController = Get.find<ReviewController>();
            await reviewController.reviewForm(formId, status, _commentController.text);

            if (status == 'approved') {
              Get.snackbar('Success', 'Form berhasil disetujui');
            } else {
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
        const Text('Form Pengkajian Kesehatan Jiwa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (data['section_1'] != null) ...[
          const Text('Identitas Klien', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildReadOnlyField('Nama Lengkap', data['section_1']['nama_lengkap']),
          _buildReadOnlyField('Umur', data['section_1']['umur']),
          _buildReadOnlyField('Jenis Kelamin', data['section_1']['jenis_kelamin']),
          _buildReadOnlyField('Status Perkawinan', data['section_1']['status_perkawinan']),
          const SizedBox(height: 16),
        ],
        if (data['section_2'] != null) ...[
          const Text('Riwayat Kehidupan', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildReadOnlyField('Riwayat Pendidikan', data['section_2']['riwayat_pendidikan']),
          _buildReadOnlyField('Pekerjaan', data['section_2']['pekerjaan']),
          _buildReadOnlyField('Riwayat Keluarga', data['section_2']['riwayat_keluarga']),
          const SizedBox(height: 16),
        ],
        if (data['section_10'] != null) ...[
          const Text('Rencana Perawatan', style: TextStyle(fontWeight: FontWeight.bold)),
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
        const Text('Resume Kegawatdaruratan Psikiatri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (data['identitas'] != null) ...[
          const Text('Identitas', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildReadOnlyField('Nama Lengkap', data['identitas']['nama_lengkap']),
          _buildReadOnlyField('Umur', data['identitas']['umur']),
          _buildReadOnlyField('Jenis Kelamin', data['identitas']['jenis_kelamin']),
          _buildReadOnlyField('Alamat', data['identitas']['alamat']),
          _buildReadOnlyField('Tanggal Masuk', data['identitas']['tanggal_masuk']),
          const SizedBox(height: 16),
        ],
        if (data['renpra'] != null) ...[
          const Text('Renpra (Rencana Perawatan)', style: TextStyle(fontWeight: FontWeight.bold)),
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
        const Text('Resume Poliklinik', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (data['section_1'] != null) ...[
          const Text('Identitas Klien', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildReadOnlyField('Nama Lengkap', data['section_1']['nama_lengkap']),
          _buildReadOnlyField('Umur', data['section_1']['umur']),
          _buildReadOnlyField('Jenis Kelamin', data['section_1']['jenis_kelamin']),
          _buildReadOnlyField('Status Perkawinan', data['section_1']['status_perkawinan']),
          const SizedBox(height: 16),
        ],
        if (data['section_9'] != null) ...[
          const Text('Renpra (Rencana Perawatan)', style: TextStyle(fontWeight: FontWeight.bold)),
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
        const Text('Form SAP (Satuan Acara Penyuluhan)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (data['identitas'] != null) ...[
          const Text('Identitas Kegiatan', style: TextStyle(fontWeight: FontWeight.bold)),
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
          const Text('Renpra (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
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
        const Text('Catatan Tambahan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (data['catatan'] != null) ...[
          const Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildReadOnlyField('Isi Catatan', data['catatan']['isi_catatan']),
          const SizedBox(height: 16),
        ],
        if (data['catatan'] != null && data['catatan']['renpra'] != null) ...[
          const Text('Renpra (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildReadOnlyField('Diagnosis', data['catatan']['renpra']['diagnosis']),
          _buildReadOnlyField('Tujuan', data['catatan']['renpra']['tujuan']),
          _buildReadOnlyField('Kriteria', data['catatan']['renpra']['kriteria']),
          _buildReadOnlyField('Rasional', data['catatan']['renpra']['rasional']),
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
        Text('Form Type: ${form.type}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text('Form Data: ${data.toString()}'), // Fallback for unknown form types
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
            child: Text(value?.toString() ?? '-'),
          ),
        ],
      ),
    );
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
                  return SingleChildScrollView(
                    child: _buildFormContent(form),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Comment section
            const Text('Komentar Review', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  child: Obx(() => ElevatedButton(
                    onPressed: _status.value == 'submitted' 
                        ? () => _reviewForm('revised') 
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Minta Revisi'),
                  )),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: _status.value == 'submitted' 
                        ? () => _reviewForm('approved') 
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Setujui'),
                  )),
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