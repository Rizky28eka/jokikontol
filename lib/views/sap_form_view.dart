import 'package:flutter/material.dart';
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
import '../utils/form_base_mixin.dart';

class SapFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const SapFormView({super.key, this.patient, this.formId});

  @override
  State<SapFormView> createState() => _SapFormViewState();
}

class _SapFormViewState extends State<SapFormView> with FormBaseMixin {
  @override
  final FormController formController = Get.put(FormController());
  @override
  final PatientController patientController = Get.find();
  final NursingInterventionController _interventionController = Get.put(NursingInterventionController());

  int _currentSection = 0;

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

  // Data structure for the SAP form
  @override
  final Map<String, dynamic> formData = {
    'identitas': {}, // Topik, sasaran, waktu, tempat
    'tujuan': {}, // Tujuan umum & khusus
    'materi_dan_metode': {}, // Materi, metode
    'joblist':
        {}, // 6 joblist (Penyuluh, Moderator, Fasilitator, Time Keeper, Dokumentator, Observer)
    'pengorganisasian': {}, // isi nama tiap peran
    'tabel_kegiatan': [], // Tahap, Waktu, Kegiatan Penyuluh/Peserta
    'evaluasi': {}, // Evaluasi Input/Proses/Hasil
    'feedback': {}, // Pertanyaan & saran peserta
    'renpra': {}, // Renpra opsional di akhir
  };
  // Lists for file uploads
  final List<String> _materiFiles = [];
  final List<String> _fotoFiles = [];

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

  void _nextSection() {
    if (_currentSection < 8) {
      setState(() {
        _currentSection++;
      });
    } else {
      submitForm();
    }
  }

  void _previousSection() {
    if (_currentSection > 0) {
      setState(() {
        _currentSection--;
      });
    }
  }

  Widget _buildSection(int sectionNumber) {
    switch (sectionNumber) {
      case 0:
        return _buildIdentitasSection();
      case 1:
        return _buildTujuanSection();
      case 2:
        return _buildMateriMetodeSection();
      case 3:
        return _buildJoblistSection();
      case 4:
        return _buildPengorganisasianSection();
      case 5:
        return _buildTabelKegiatanSection();
      case 6:
        return _buildEvaluasiSection();
      case 7:
        return _buildFeedbackSection();
      case 8:
        return _buildRenpraSection();
      default:
        return const SizedBox();
    }
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
        TextFormField(
          initialValue: formData['identitas']['topik'],
          decoration: const InputDecoration(
            labelText: 'Topik',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['identitas']['topik'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData['identitas']['sasaran'],
          decoration: const InputDecoration(
            labelText: 'Sasaran',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['identitas']['sasaran'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData['identitas']['waktu'],
          decoration: const InputDecoration(
            labelText: 'Waktu',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['identitas']['waktu'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData['identitas']['tempat'],
          decoration: const InputDecoration(
            labelText: 'Tempat',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['identitas']['tempat'] = value;
          },
        ),
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
        const Text(
          'Tujuan Umum',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          initialValue: formData['tujuan']['umum'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 3,
          onChanged: (value) {
            formData['tujuan']['umum'] = value;
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Tujuan Khusus',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          initialValue: formData['tujuan']['khusus'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 5,
          onChanged: (value) {
            formData['tujuan']['khusus'] = value;
          },
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
        const Text('Materi', style: TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          initialValue: formData['materi_dan_metode']['materi'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 5,
          onChanged: (value) {
            formData['materi_dan_metode']['materi'] = value;
          },
        ),
        const SizedBox(height: 16),
        const Text('Metode', style: TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          initialValue: formData['materi_dan_metode']['metode'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 3,
          onChanged: (value) {
            formData['materi_dan_metode']['metode'] = value;
          },
        ),
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
        // Penyuluh
        CheckboxListTile(
          title: const Text('Penyuluh'),
          value:
              (formData['joblist']['roles'] as List?)?.contains('Penyuluh') ??
              false,
          onChanged: (bool? value) {
            final roles = formData['joblist']['roles'] as List? ?? <String>[];
            if (value == true) {
              roles.add('Penyuluh');
            } else {
              roles.remove('Penyuluh');
            }
            formData['joblist']['roles'] = roles;
          },
        ),
        // Moderator
        CheckboxListTile(
          title: const Text('Moderator'),
          value:
              (formData['joblist']['roles'] as List?)?.contains('Moderator') ??
              false,
          onChanged: (bool? value) {
            final roles = formData['joblist']['roles'] as List? ?? <String>[];
            if (value == true) {
              roles.add('Moderator');
            } else {
              roles.remove('Moderator');
            }
            formData['joblist']['roles'] = roles;
          },
        ),
        // Fasilitator
        CheckboxListTile(
          title: const Text('Fasilitator'),
          value:
              (formData['joblist']['roles'] as List?)?.contains(
                'Fasilitator',
              ) ??
              false,
          onChanged: (bool? value) {
            final roles = formData['joblist']['roles'] as List? ?? <String>[];
            if (value == true) {
              roles.add('Fasilitator');
            } else {
              roles.remove('Fasilitator');
            }
            formData['joblist']['roles'] = roles;
          },
        ),
        // Time Keeper
        CheckboxListTile(
          title: const Text('Time Keeper'),
          value:
              (formData['joblist']['roles'] as List?)?.contains(
                'Time Keeper',
              ) ??
              false,
          onChanged: (bool? value) {
            final roles = formData['joblist']['roles'] as List? ?? <String>[];
            if (value == true) {
              roles.add('Time Keeper');
            } else {
              roles.remove('Time Keeper');
            }
            formData['joblist']['roles'] = roles;
          },
        ),
        // Dokumentator
        CheckboxListTile(
          title: const Text('Dokumentator'),
          value:
              (formData['joblist']['roles'] as List?)?.contains(
                'Dokumentator',
              ) ??
              false,
          onChanged: (bool? value) {
            final roles = formData['joblist']['roles'] as List? ?? <String>[];
            if (value == true) {
              roles.add('Dokumentator');
            } else {
              roles.remove('Dokumentator');
            }
            formData['joblist']['roles'] = roles;
          },
        ),
        // Observer
        CheckboxListTile(
          title: const Text('Observer'),
          value:
              (formData['joblist']['roles'] as List?)?.contains('Observer') ??
              false,
          onChanged: (bool? value) {
            final roles = formData['joblist']['roles'] as List? ?? <String>[];
            if (value == true) {
              roles.add('Observer');
            } else {
              roles.remove('Observer');
            }
            formData['joblist']['roles'] = roles;
          },
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
        TextFormField(
          initialValue: formData['pengorganisasian']['penyuluh'],
          decoration: const InputDecoration(
            labelText: 'Nama Penyuluh',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['pengorganisasian']['penyuluh'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData['pengorganisasian']['moderator'],
          decoration: const InputDecoration(
            labelText: 'Nama Moderator',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['pengorganisasian']['moderator'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData['pengorganisasian']['fasilitator'],
          decoration: const InputDecoration(
            labelText: 'Nama Fasilitator',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['pengorganisasian']['fasilitator'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData['pengorganisasian']['time_keeper'],
          decoration: const InputDecoration(
            labelText: 'Nama Time Keeper',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['pengorganisasian']['time_keeper'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData['pengorganisasian']['dokumentator'],
          decoration: const InputDecoration(
            labelText: 'Nama Dokumentator',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['pengorganisasian']['dokumentator'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData['pengorganisasian']['observer'],
          decoration: const InputDecoration(
            labelText: 'Nama Observer',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['pengorganisasian']['observer'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildTabelKegiatanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tabel Kegiatan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            _showTabelKegiatanDialog();
          },
          child: const Text('Tambah Kegiatan'),
        ),
        const SizedBox(height: 16),
        formData['tabel_kegiatan'] != null &&
                formData['tabel_kegiatan'] is List
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (formData['tabel_kegiatan'] as List).length,
                itemBuilder: (context, index) {
                  final kegiatan = (formData['tabel_kegiatan'] as List)[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tahap: ${kegiatan['tahap'] ?? '-'}'),
                          Text('Waktu: ${kegiatan['waktu'] ?? '-'}'),
                          Text(
                            'Kegiatan Penyuluh: ${kegiatan['kegiatan_penyuluh'] ?? '-'}',
                          ),
                          Text(
                            'Kegiatan Peserta: ${kegiatan['kegiatan_peserta'] ?? '-'}',
                          ),
                          TextButton(
                            onPressed: () {
                              _editTabelKegiatanDialog(index, kegiatan);
                            },
                            child: const Text('Edit'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                (formData['tabel_kegiatan'] as List).removeAt(
                                  index,
                                );
                              });
                            },
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : const Text('Belum ada kegiatan ditambahkan'),
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
        content: Column(
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
              decoration: const InputDecoration(labelText: 'Kegiatan Penyuluh'),
            ),
            TextField(
              controller: kegiatanPesertaController,
              decoration: const InputDecoration(labelText: 'Kegiatan Peserta'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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

              if (existingData != null && index != null) {
                // Update existing item
                (formData['tabel_kegiatan'] as List)[index] = newKegiatan;
              } else {
                // Add new item
                (formData['tabel_kegiatan'] as List).add(newKegiatan);
              }

              Navigator.of(context).pop();
              setState(() {}); // Refresh UI
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _editTabelKegiatanDialog(int index, Map<String, dynamic> existingData) {
    _showTabelKegiatanDialog(index: index, existingData: existingData);
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
        const Text(
          'Evaluasi Input',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          initialValue: formData['evaluasi']['input'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 3,
          onChanged: (value) {
            formData['evaluasi']['input'] = value;
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Evaluasi Proses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          initialValue: formData['evaluasi']['proses'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 3,
          onChanged: (value) {
            formData['evaluasi']['proses'] = value;
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Evaluasi Hasil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          initialValue: formData['evaluasi']['hasil'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 3,
          onChanged: (value) {
            formData['evaluasi']['hasil'] = value;
          },
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
        TextFormField(
          initialValue: formData['feedback']['pertanyaan'],
          decoration: const InputDecoration(
            labelText: 'Pertanyaan Peserta',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['feedback']['pertanyaan'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData['feedback']['saran'],
          decoration: const InputDecoration(
            labelText: 'Saran Peserta',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['feedback']['saran'] = value;
          },
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
        // Diagnosis dropdown
        const Text('Diagnosis'),
        const SizedBox(height: 8),
        Obx(() {
          final nursingService = Get.find<NursingDataGlobalService>();
          final diagnoses = nursingService.diagnoses;
          if (diagnoses.isEmpty) return const Text('Tidak ada diagnosis tersedia');
          final items = diagnoses.map((diag) => DropdownMenuItem(value: diag.id, child: Text(diag.name))).toList();
          return DropdownButtonFormField<int?>(
            value: formData['renpra']['diagnosis'] as int?,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: items,
            onChanged: (value) {
              formData['renpra']['diagnosis'] = value;
            },
            hint: const Text('Pilih Diagnosis'),
          );
        }),
        const SizedBox(height: 16),
        // Intervensi checkboxes
        const Text('Intervensi'),
        const SizedBox(height: 8),
        Obx(() {
          final interventions = _interventionController.interventions;
          if (interventions.isEmpty) {
            return const Text('Tidak ada intervensi tersedia');
          }
          return Column(
            children: interventions.map((iv) {
              final currentInterventions =
                  (formData['renpra']['intervensi'] as List?) ?? <int>[];
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
                  formData['renpra']['intervensi'] = intervensi;
                  setState(() {});
                },
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData['renpra']['tujuan'],
          decoration: const InputDecoration(
            labelText: 'Tujuan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['renpra']['tujuan'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData['renpra']['kriteria'],
          decoration: const InputDecoration(
            labelText: 'Kriteria',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['renpra']['kriteria'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Rasional',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['renpra']['rasional'] = value;
          },
        ),
        const SizedBox(height: 16),
        // File upload section
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
        const SizedBox(height: 8),
        if (_materiFiles.isNotEmpty)
          Column(
            children: [
              const Text(
                'Materi Terupload:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._materiFiles.map((file) => Text(file)).toList(),
            ],
          ),
        if (_fotoFiles.isNotEmpty)
          Column(
            children: [
              const Text(
                'Foto Terupload:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._fotoFiles.map((file) => Text(file)).toList(),
            ],
          ),
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
      List<File> files = result.paths.map((path) => File(path!)).toList();

      // Upload each file to the server
      for (File file in files) {
        bool success = await _uploadFileToServer(file, 'materi');
        if (success) {
          setState(() {
            _materiFiles.add(file.path.split('/').last);
          });
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
      List<File> files = result.paths.map((path) => File(path!)).toList();

      // Upload each file to the server
      for (File file in files) {
        bool success = await _uploadFileToServer(file, 'foto');
        if (success) {
          setState(() {
            _fotoFiles.add(file.path.split('/').last);
          });
        }
      }
    }
  }

  Future<bool> _uploadFileToServer(File file, String type) async {
    // Get the form ID after form submission
    int? formId = widget.formId;

    // If no form ID (new form), we need to save the form first
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

      // Add auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Add the file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.path.split('/').last,
        ),
      );

      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        Get.snackbar('Success', 'File uploaded successfully');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to upload file: ${responseString}');
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
            // Progress indicator
            LinearProgressIndicator(value: (_currentSection + 1) / 9),
            const SizedBox(height: 16),
            Text('Section ${_currentSection + 1} dari 9'),
            const SizedBox(height: 16),

            // Section content
            Expanded(
              child: SingleChildScrollView(
                child: _buildSection(_currentSection),
              ),
            ),

            // Navigation buttons
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
                  // Last section, show action buttons
                  Expanded(
                    child: buildActionButtons(),
                  )
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
