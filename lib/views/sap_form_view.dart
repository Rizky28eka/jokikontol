import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/form_controller.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../controllers/patient_controller.dart';
import '../services/nursing_data_global_service.dart';
import '../models/patient_model.dart';
import '../utils/form_builder_mixin.dart';
import '../widgets/form_components/custom_text_field.dart';
import '../widgets/form_components/custom_dropdown.dart';
import '../widgets/form_components/custom_checkbox_group.dart';

class SapFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const SapFormView({super.key, this.patient, this.formId});

  @override
  State<SapFormView> createState() => _SapFormViewState();
}

class _SapFormViewState extends State<SapFormView> with FormBuilderMixin {
  @override
  final FormController formController = Get.put(FormController());
  @override
  final PatientController patientController = Get.find();
  final NursingInterventionController _interventionController = Get.put(
    NursingInterventionController(),
  );

  int _currentSection = 0;
  final List<String> _materiFiles = [];
  final List<String> _fotoFiles = [];

  @override
  String get formType => 'sap';

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
    // The reverse mapper has already flattened the data.
    return data;
  }

  @override
  Map<String, dynamic> transformFormData(Map<String, dynamic> formData) {
    // The forward mapper will handle the complex transformation.
    // The mixin's transform handles generic conversions like DateTime.
    return super.transformFormData(formData);
  }

  void _nextSection() {
    updateFormData();
    if (_currentSection < 8) {
      setState(() => _currentSection++);
    }
  }

  void _previousSection() {
    updateFormData();
    if (_currentSection > 0) {
      setState(() => _currentSection--);
    }
  }

  Widget _buildSection(int sectionNumber) {
    Widget sectionContent;
    switch (sectionNumber) {
      case 0:
        sectionContent = _buildIdentitasSection();
        break;
      case 1:
        sectionContent = _buildTujuanSection();
        break;
      case 2:
        sectionContent = _buildMateriMetodeSection();
        break;
      case 3:
        sectionContent = _buildJoblistSection();
        break;
      case 4:
        sectionContent = _buildPengorganisasianSection();
        break;
      case 5:
        sectionContent = _buildTabelKegiatanSection();
        break;
      case 6:
        sectionContent = _buildEvaluasiSection();
        break;
      case 7:
        sectionContent = _buildFeedbackSection();
        break;
      case 8:
        sectionContent = _buildRenpraSection();
        break;
      default:
        sectionContent = const SizedBox();
    }

    return KeyedSubtree(
      key: ValueKey('section_$sectionNumber'),
      child: sectionContent,
    );
  }

  Widget _buildIdentitasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Identitas Kegiatan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(name: 'topik', label: 'Topik', tooltip: 'Topik utama dari kegiatan penyuluhan'),
        const SizedBox(height: 16),
        CustomTextField(name: 'sub_topik', label: 'Sub Topik', tooltip: 'Sub topik dari kegiatan penyuluhan'),
        const SizedBox(height: 16),
        CustomTextField(name: 'sasaran', label: 'Sasaran', tooltip: 'Sasaran dari kegiatan penyuluhan'),
        const SizedBox(height: 16),
        CustomTextField(name: 'tanggal_pelaksanaan', label: 'Tanggal Pelaksanaan', tooltip: 'Tanggal kegiatan penyuluhan dilaksanakan'),
        const SizedBox(height: 16),
        CustomTextField(name: 'waktu_pelaksanaan', label: 'Waktu Pelaksanaan', tooltip: 'Waktu kegiatan penyuluhan dilaksanakan'),
        const SizedBox(height: 16),
        CustomTextField(name: 'durasi', label: 'Durasi', tooltip: 'Durasi kegiatan dalam menit'),
        const SizedBox(height: 16),
        CustomTextField(name: 'tempat', label: 'Tempat', tooltip: 'Tempat kegiatan penyuluhan dilaksanakan'),
      ],
    );
  }

  Widget _buildTujuanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tujuan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'tujuan_umum',
          label: 'Tujuan Umum',
          tooltip: 'Tujuan umum dari kegiatan penyuluhan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'tujuan_khusus',
          label: 'Tujuan Khusus',
          tooltip: 'Tujuan khusus dari kegiatan penyuluhan',
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildMateriMetodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Materi dan Metode',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(name: 'materi', label: 'Materi', tooltip: 'Materi penyuluhan yang akan disampaikan', maxLines: 5),
        const SizedBox(height: 16),
        CustomTextField(name: 'metode', label: 'Metode', tooltip: 'Metode yang digunakan dalam kegiatan penyuluhan', maxLines: 3),
        const SizedBox(height: 16),
        CustomTextField(name: 'media', label: 'Media', tooltip: 'Media yang digunakan dalam kegiatan penyuluhan', maxLines: 3),
      ],
    );
  }

  Widget _buildJoblistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Joblist Kegiatan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomCheckboxGroup<String>(
          name: 'joblist_roles',
          label: 'Pilih Peran',
          tooltip: 'Pilih peran yang akan dijalankan dalam kegiatan penyuluhan',
          options: const [
            FormBuilderFieldOption(value: 'Penyuluh', child: Text('Penyuluh')),
            FormBuilderFieldOption(
              value: 'Moderator',
              child: Text('Moderator'),
            ),
            FormBuilderFieldOption(
              value: 'Fasilitator',
              child: Text('Fasilitator'),
            ),
            FormBuilderFieldOption(
              value: 'Time Keeper',
              child: Text('Time Keeper'),
            ),
            FormBuilderFieldOption(
              value: 'Dokumentator',
              child: Text('Dokumentator'),
            ),
            FormBuilderFieldOption(value: 'Observer', child: Text('Observer')),
          ],
        ),
      ],
    );
  }

  Widget _buildPengorganisasianSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengorganisasian',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(name: 'penyuluh', label: 'Nama Penyuluh', tooltip: 'Nama petugas yang menjadi penyuluh'),
        const SizedBox(height: 16),
        CustomTextField(name: 'moderator', label: 'Nama Moderator', tooltip: 'Nama petugas yang menjadi moderator'),
        const SizedBox(height: 16),
        CustomTextField(name: 'fasilitator', label: 'Nama Fasilitator', tooltip: 'Nama petugas yang menjadi fasilitator'),
        const SizedBox(height: 16),
        CustomTextField(name: 'time_keeper', label: 'Nama Time Keeper', tooltip: 'Nama petugas yang menjadi time keeper'),
        const SizedBox(height: 16),
        CustomTextField(name: 'dokumentator', label: 'Nama Dokumentator', tooltip: 'Nama petugas yang menjadi dokumentator'),
        const SizedBox(height: 16),
        CustomTextField(name: 'observer', label: 'Nama Observer', tooltip: 'Nama petugas yang menjadi observer'),
      ],
    );
  }

  Widget _buildTabelKegiatanSection() {
    final tabelKegiatan =
        formKey.currentState?.fields['tabel_kegiatan']?.value as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tabel Kegiatan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _showTabelKegiatanDialog(),
          child: const Text('Tambah Kegiatan'),
        ),
        const SizedBox(height: 16),
        if (tabelKegiatan.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tabelKegiatan.length,
            itemBuilder: (context, index) {
              final kegiatan = tabelKegiatan[index];
              return Card(
                child: ListTile(
                  title: Text('Tahap: ${kegiatan['tahap'] ?? '-'}'),
                  subtitle: Text('Waktu: ${kegiatan['waktu'] ?? '-'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showTabelKegiatanDialog(
                          index: index,
                          existingData: kegiatan,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          final updated = List.from(tabelKegiatan)
                            ..removeAt(index);
                          formKey.currentState?.fields['tabel_kegiatan']
                              ?.didChange(updated);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        else
          const Text('Belum ada kegiatan ditambahkan'),
      ],
    );
  }

  void _showTabelKegiatanDialog({
    int? index,
    Map<String, dynamic>? existingData,
  }) {
    final tahapController = TextEditingController(text: existingData?['tahap']);
    final waktuController = TextEditingController(text: existingData?['waktu']);
    final kegiatanPenyuluhController = TextEditingController(
      text: existingData?['kegiatan_penyuluh'],
    );
    final kegiatanPesertaController = TextEditingController(
      text: existingData?['kegiatan_peserta'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingData != null ? 'Edit Kegiatan' : 'Tambah Kegiatan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tahapController,
                decoration: const InputDecoration(labelText: 'Tahap'),
              ),
              TextField(
                controller: waktuController,
                decoration: const InputDecoration(labelText: 'Waktu'),
              ),
              TextField(
                controller: kegiatanPenyuluhController,
                decoration: const InputDecoration(
                  labelText: 'Kegiatan Penyuluh',
                ),
              ),
              TextField(
                controller: kegiatanPesertaController,
                decoration: const InputDecoration(
                  labelText: 'Kegiatan Peserta',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final newKegiatan = {
                'tahap': tahapController.text,
                'waktu': waktuController.text,
                'kegiatan_penyuluh': kegiatanPenyuluhController.text,
                'kegiatan_peserta': kegiatanPesertaController.text,
              };

              final tabelKegiatan = List.from(
                formKey.currentState?.fields['tabel_kegiatan']?.value ?? [],
              );
              if (index != null) {
                tabelKegiatan[index] = newKegiatan;
              } else {
                tabelKegiatan.add(newKegiatan);
              }
              formKey.currentState?.fields['tabel_kegiatan']?.didChange(
                tabelKegiatan,
              );
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evaluasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'evaluasi_input',
          label: 'Evaluasi Input',
          tooltip: 'Evaluasi input dalam kegiatan penyuluhan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'evaluasi_proses',
          label: 'Evaluasi Proses',
          tooltip: 'Evaluasi proses pelaksanaan kegiatan penyuluhan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'evaluasi_hasil',
          label: 'Evaluasi Hasil',
          tooltip: 'Evaluasi hasil dari kegiatan penyuluhan',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pertanyaan & Saran Peserta',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'pertanyaan',
          label: 'Pertanyaan Peserta',
          tooltip: 'Pertanyaan yang diajukan oleh peserta',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'saran',
          label: 'Saran Peserta',
          tooltip: 'Saran yang diberikan oleh peserta',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRenpraSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rencana Perawatan (Renpra) - Opsional',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final nursingService = Get.find<NursingDataGlobalService>();
          final diagnoses = nursingService.diagnoses;
          if (diagnoses.isEmpty) {
            return const Text('Tidak ada diagnosis tersedia');
          }

          return CustomDropdown<int>(
            name: 'diagnosis',
            label: 'Diagnosis',
            tooltip: 'Pilih diagnosis keperawatan yang sesuai',
            items: diagnoses
                .map(
                  (diag) =>
                      DropdownMenuItem(value: diag.id, child: Text(diag.name)),
                )
                .toList(),
            hint: 'Pilih Diagnosis',
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          final interventions = _interventionController.interventions;
          if (interventions.isEmpty) {
            return const Text('Tidak ada intervensi tersedia');
          }

          return CustomCheckboxGroup<int>(
            name: 'intervensi',
            label: 'Intervensi',
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
        const SizedBox(height: 16),
        CustomTextField(name: 'tujuan', label: 'Tujuan', tooltip: 'Tujuan perawatan yang ingin dicapai', maxLines: 3),
        const SizedBox(height: 16),
        CustomTextField(name: 'kriteria', label: 'Kriteria', tooltip: 'Kriteria untuk mengevaluasi pencapaian tujuan', maxLines: 3),
        const SizedBox(height: 16),
        CustomTextField(name: 'rasional', label: 'Rasional', tooltip: 'Alasan atau landasan mengapa intervensi dipilih', maxLines: 3),
        const SizedBox(height: 16),
        const Text(
          'Upload Dokumentasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _uploadMaterials,
                icon: const Icon(Icons.upload),
                label: const Text('Upload Materi'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _uploadPhotos,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Upload Foto'),
              ),
            ),
          ],
        ),
        if (_materiFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Materi Terupload:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ..._materiFiles.map((file) => Text('• $file')),
        ],
        if (_fotoFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Foto Terupload:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ..._fotoFiles.map((file) => Text('• $file')),
        ],
      ],
    );
  }

  Future<void> _uploadMaterials() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
      allowMultiple: true,
    );

    if (result != null) {
      for (var path in result.paths) {
        if (path != null) {
          bool success = await _uploadFileToServer(File(path), 'materi');
          if (success) setState(() => _materiFiles.add(path.split('/').last));
        }
      }
    }
  }

  Future<void> _uploadPhotos() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      for (var path in result.paths) {
        if (path != null) {
          bool success = await _uploadFileToServer(File(path), 'foto');
          if (success) setState(() => _fotoFiles.add(path.split('/').last));
        }
      }
    }
  }

  Future<bool> _uploadFileToServer(File file, String type) async {
    int? formId = widget.formId;
    if (formId == null) {
      Get.snackbar(
        'Warning',
        'Please save the form first before uploading files',
      );
      return false;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '${ApiConfig.currentBaseUrl}/forms/$formId/upload-${type == 'materi' ? 'material' : 'photo'}',
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.path.split('/').last,
        ),
      );

      var response = await request.send();
      if (response.statusCode == 201) {
        Get.snackbar('Success', 'File uploaded successfully');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to upload file');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Upload failed: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.formId == null
              ? 'Form SAP (Satuan Acara Penyuluhan)'
              : 'Edit SAP',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_currentSection + 1) / 9),
            const SizedBox(height: 16),
            Text('Section ${_currentSection + 1} dari 9'),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: formKey,
                  initialValue: initialValues,
                  child: _buildSection(_currentSection),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentSection > 0)
                  ElevatedButton(
                    onPressed: _previousSection,
                    child: const Text('Sebelumnya'),
                  )
                else
                  const SizedBox.shrink(),
                if (_currentSection == 8)
                  Expanded(child: buildActionButtons())
                else
                  ElevatedButton(
                    onPressed: _nextSection,
                    child: const Text('Selanjutnya'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}