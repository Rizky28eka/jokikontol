import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../models/patient_model.dart';
import '../models/form_model.dart';
import '../services/hive_service.dart';

class SapFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const SapFormView({super.key, this.patient, this.formId});

  @override
  State<SapFormView> createState() => _SapFormViewState();
}

class _SapFormViewState extends State<SapFormView> {
  final FormController formController = Get.put(FormController());
  final PatientController patientController = Get.find();

  int _currentSection = 0;

  // Data structure for the SAP form
  final Map<String, dynamic> _formData = {
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
  List<String> _materiFiles = [];
  List<String> _fotoFiles = [];

  @override
  void initState() {
    super.initState();

    // Initialize Hive
    HiveService.init();

    // If editing existing form, load the data
    if (widget.formId != null) {
      _loadFormData();
    } else {
      // Check for any existing draft forms to continue
      _checkForDrafts();
    }
  }

  Future<void> _checkForDrafts() async {
    if (widget.patient == null) return;

    final draft = await HiveService.getDraftForm('sap', widget.patient!.id);
    if (draft != null) {
      Get.defaultDialog(
        title: 'Draft Ditemukan',
        middleText:
            'Apakah Anda ingin melanjutkan pengisian form dari draft yang tersimpan?',
        textConfirm: 'Ya',
        textCancel: 'Tidak',
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
          setState(() {
            _formData.addAll(draft.data ?? {});
          });
        },
        onCancel: () {
          // Optional: Delete draft if user chooses not to restore
        },
      );
    }
  }

  Future<void> _loadFormData() async {
    if (widget.formId == null) return;

    final form = await formController.getFormById(widget.formId!);
    if (form != null && form.data != null) {
      setState(() {
        _formData.addAll(form.data!);
      });
    }
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
      _submitForm();
    }
  }

  void _previousSection() {
    if (_currentSection > 0) {
      setState(() {
        _currentSection--;
      });
    }
  }

  Future<void> _saveDraft() async {
    if (widget.patient == null) {
      Get.snackbar('Error', 'Patient information is required to save draft');
      return;
    }

    try {
      final form = FormModel(
        id: widget.formId ?? DateTime.now().millisecondsSinceEpoch,
        type: 'sap',
        userId: 0,
        patientId: widget.patient!.id,
        status: 'draft',
        data: _formData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        genogram: null,
      );

      await HiveService.saveDraftForm(form);
      Get.snackbar('Success', 'Draft saved locally');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save draft: $e');
    }
  }

  Future<void> _submitForm() async {
    try {
      // Check if patient is available
      if (widget.patient == null) {
        Get.snackbar('Error', 'Patient information is required to submit form');
        return;
      }

      if (widget.formId != null) {
        // If editing existing form, update it
        await formController.updateForm(
          id: widget.formId!,
          type: 'sap',
          patientId: widget.patient!.id,
          data: _formData,
          status: 'submitted',
        );
      } else {
        // If creating new form, create it
        await formController.createForm(
          type: 'sap',
          patientId: widget.patient!.id,
          data: _formData,
          status: 'submitted',
        );
      }

      // If submission successful, remove any local draft
      await HiveService.deleteDraftForm('sap', widget.patient!.id);

      Get.snackbar('Success', 'Form submitted successfully');
      Get.back(); // Navigate back
    } catch (e) {
      // If submission fails, save as draft locally and notify user
      Get.snackbar('Error', 'Submission failed. Form saved as draft locally.');

      // Save to local storage as draft
      if (widget.patient != null) {
        // Only save if patient is available
        final form = FormModel(
          id: widget.formId ?? DateTime.now().millisecondsSinceEpoch,
          type: 'sap',
          userId: 0,
          patientId: widget.patient!.id,
          status: 'draft',
          data: _formData,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          genogram: null,
        );

        await HiveService.saveDraftForm(form);
      }
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
          initialValue: _formData['identitas']['topik'],
          decoration: const InputDecoration(
            labelText: 'Topik',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['identitas']['topik'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['identitas']['sasaran'],
          decoration: const InputDecoration(
            labelText: 'Sasaran',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['identitas']['sasaran'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['identitas']['waktu'],
          decoration: const InputDecoration(
            labelText: 'Waktu',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['identitas']['waktu'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['identitas']['tempat'],
          decoration: const InputDecoration(
            labelText: 'Tempat',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['identitas']['tempat'] = value;
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
          initialValue: _formData['tujuan']['umum'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 3,
          onChanged: (value) {
            _formData['tujuan']['umum'] = value;
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Tujuan Khusus',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          initialValue: _formData['tujuan']['khusus'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 5,
          onChanged: (value) {
            _formData['tujuan']['khusus'] = value;
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
          initialValue: _formData['materi_dan_metode']['materi'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 5,
          onChanged: (value) {
            _formData['materi_dan_metode']['materi'] = value;
          },
        ),
        const SizedBox(height: 16),
        const Text('Metode', style: TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          initialValue: _formData['materi_dan_metode']['metode'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 3,
          onChanged: (value) {
            _formData['materi_dan_metode']['metode'] = value;
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
              (_formData['joblist']['roles'] as List?)?.contains('Penyuluh') ??
              false,
          onChanged: (bool? value) {
            final roles = _formData['joblist']['roles'] as List? ?? <String>[];
            if (value == true) {
              roles.add('Penyuluh');
            } else {
              roles.remove('Penyuluh');
            }
            _formData['joblist']['roles'] = roles;
          },
        ),
        // Moderator
        CheckboxListTile(
          title: const Text('Moderator'),
          value:
              (_formData['joblist']['roles'] as List?)?.contains('Moderator') ??
              false,
          onChanged: (bool? value) {
            final roles = _formData['joblist']['roles'] as List? ?? <String>[];
            if (value == true) {
              roles.add('Moderator');
            } else {
              roles.remove('Moderator');
            }
            _formData['joblist']['roles'] = roles;
          },
        ),
        // Fasilitator
        CheckboxListTile(
          title: const Text('Fasilitator'),
          value:
              (_formData['joblist']['roles'] as List?)?.contains(
                'Fasilitator',
              ) ??
              false,
          onChanged: (bool? value) {
            final roles = _formData['joblist']['roles'] as List? ?? <String>[];
            if (value == true) {
              roles.add('Fasilitator');
            } else {
              roles.remove('Fasilitator');
            }
            _formData['joblist']['roles'] = roles;
          },
        ),
        // Time Keeper
        CheckboxListTile(
          title: const Text('Time Keeper'),
          value:
              (_formData['joblist']['roles'] as List?)?.contains(
                'Time Keeper',
              ) ??
              false,
          onChanged: (bool? value) {
            final roles = _formData['joblist']['roles'] as List? ?? <String>[];
            if (value == true) {
              roles.add('Time Keeper');
            } else {
              roles.remove('Time Keeper');
            }
            _formData['joblist']['roles'] = roles;
          },
        ),
        // Dokumentator
        CheckboxListTile(
          title: const Text('Dokumentator'),
          value:
              (_formData['joblist']['roles'] as List?)?.contains(
                'Dokumentator',
              ) ??
              false,
          onChanged: (bool? value) {
            final roles = _formData['joblist']['roles'] as List? ?? <String>[];
            if (value == true) {
              roles.add('Dokumentator');
            } else {
              roles.remove('Dokumentator');
            }
            _formData['joblist']['roles'] = roles;
          },
        ),
        // Observer
        CheckboxListTile(
          title: const Text('Observer'),
          value:
              (_formData['joblist']['roles'] as List?)?.contains('Observer') ??
              false,
          onChanged: (bool? value) {
            final roles = _formData['joblist']['roles'] as List? ?? <String>[];
            if (value == true) {
              roles.add('Observer');
            } else {
              roles.remove('Observer');
            }
            _formData['joblist']['roles'] = roles;
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
          initialValue: _formData['pengorganisasian']['penyuluh'],
          decoration: const InputDecoration(
            labelText: 'Nama Penyuluh',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['pengorganisasian']['penyuluh'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['pengorganisasian']['moderator'],
          decoration: const InputDecoration(
            labelText: 'Nama Moderator',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['pengorganisasian']['moderator'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['pengorganisasian']['fasilitator'],
          decoration: const InputDecoration(
            labelText: 'Nama Fasilitator',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['pengorganisasian']['fasilitator'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['pengorganisasian']['time_keeper'],
          decoration: const InputDecoration(
            labelText: 'Nama Time Keeper',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['pengorganisasian']['time_keeper'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['pengorganisasian']['dokumentator'],
          decoration: const InputDecoration(
            labelText: 'Nama Dokumentator',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['pengorganisasian']['dokumentator'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['pengorganisasian']['observer'],
          decoration: const InputDecoration(
            labelText: 'Nama Observer',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _formData['pengorganisasian']['observer'] = value;
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
        _formData['tabel_kegiatan'] != null &&
                _formData['tabel_kegiatan'] is List
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (_formData['tabel_kegiatan'] as List).length,
                itemBuilder: (context, index) {
                  final kegiatan = (_formData['tabel_kegiatan'] as List)[index];
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
                                (_formData['tabel_kegiatan'] as List).removeAt(
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
                (_formData['tabel_kegiatan'] as List)[index] = newKegiatan;
              } else {
                // Add new item
                (_formData['tabel_kegiatan'] as List).add(newKegiatan);
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
          initialValue: _formData['evaluasi']['input'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 3,
          onChanged: (value) {
            _formData['evaluasi']['input'] = value;
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Evaluasi Proses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          initialValue: _formData['evaluasi']['proses'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 3,
          onChanged: (value) {
            _formData['evaluasi']['proses'] = value;
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Evaluasi Hasil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          initialValue: _formData['evaluasi']['hasil'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 3,
          onChanged: (value) {
            _formData['evaluasi']['hasil'] = value;
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
          initialValue: _formData['feedback']['pertanyaan'],
          decoration: const InputDecoration(
            labelText: 'Pertanyaan Peserta',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['feedback']['pertanyaan'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['feedback']['saran'],
          decoration: const InputDecoration(
            labelText: 'Saran Peserta',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['feedback']['saran'] = value;
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
        DropdownButtonFormField<String>(
          value: _formData['renpra']['diagnosis'],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'Depresi', child: Text('Depresi')),
            DropdownMenuItem(value: 'Anxiety', child: Text('Anxiety')),
            DropdownMenuItem(value: 'Skizofrenia', child: Text('Skizofrenia')),
            DropdownMenuItem(value: 'Bipolar', child: Text('Gangguan Bipolar')),
            DropdownMenuItem(value: 'Tidak Ada', child: Text('Tidak Ada')),
          ],
          onChanged: (value) {
            if (value == 'Tidak Ada') {
              _formData['renpra']['diagnosis'] = null;
            } else {
              _formData['renpra']['diagnosis'] = value;
            }
          },
          hint: const Text('Pilih Diagnosis atau Tidak Ada'),
        ),
        const SizedBox(height: 16),
        // Intervensi checkboxes
        const Text('Intervensi'),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('Terapi Individu'),
          value:
              (_formData['renpra']['intervensi'] as List?)?.contains(
                'Terapi Individu',
              ) ??
              false,
          onChanged: (bool? value) {
            final intervensi =
                _formData['renpra']['intervensi'] as List? ?? <String>[];
            if (value == true) {
              intervensi.add('Terapi Individu');
            } else {
              intervensi.remove('Terapi Individu');
            }
            _formData['renpra']['intervensi'] = intervensi;
          },
        ),
        CheckboxListTile(
          title: const Text('Terapi Keluarga'),
          value:
              (_formData['renpra']['intervensi'] as List?)?.contains(
                'Terapi Keluarga',
              ) ??
              false,
          onChanged: (bool? value) {
            final intervensi =
                _formData['renpra']['intervensi'] as List? ?? <String>[];
            if (value == true) {
              intervensi.add('Terapi Keluarga');
            } else {
              intervensi.remove('Terapi Keluarga');
            }
            _formData['renpra']['intervensi'] = intervensi;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['renpra']['tujuan'],
          decoration: const InputDecoration(
            labelText: 'Tujuan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['renpra']['tujuan'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['renpra']['kriteria'],
          decoration: const InputDecoration(
            labelText: 'Kriteria',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _formData['renpra']['kriteria'] = value;
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
            _formData['renpra']['rasional'] = value;
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
      final token = prefs.getString('token');
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
        actions: [
          TextButton(
            onPressed: _saveDraft,
            child: const Text(
              'Simpan Draft',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
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

                ElevatedButton(
                  onPressed: _nextSection,
                  child: Text(_currentSection == 8 ? 'Simpan' : 'Selanjutnya'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
