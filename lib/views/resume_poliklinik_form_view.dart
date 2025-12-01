import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../models/patient_model.dart';
import '../services/nursing_data_global_service.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../utils/form_base_mixin.dart';

class ResumePoliklinikFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const ResumePoliklinikFormView({super.key, this.patient, this.formId});

  @override
  State<ResumePoliklinikFormView> createState() =>
      _ResumePoliklinikFormViewState();
}

class _ResumePoliklinikFormViewState extends State<ResumePoliklinikFormView> with FormBaseMixin {
  @override
  final FormController formController = Get.put(FormController());
  @override
  final PatientController patientController = Get.find();
  final NursingInterventionController _interventionController = Get.put(NursingInterventionController());

  int _currentSection = 0;

  // Controllers for the form fields
  final List<TextEditingController> _controllers = List.generate(
    26,
    (index) => TextEditingController(),
  );

  @override
  String get formType => 'resume_poliklinik';
  
  @override
  int? get formId => widget.formId ?? Get.arguments?['formId'] as int?;
  
  Patient? _currentPatient;
  int? _currentPatientId;
  
  @override
  Patient? get currentPatient => _currentPatient;
  
  @override
  int? get currentPatientId => _currentPatientId;

  // Data structure for the form - similar to pengkajian but without genogram section
  @override
  final Map<String, dynamic> formData = {
    'section_1': {}, // Identitas Klien
    'section_2': {}, // Riwayat Kehidupan
    'section_3': {}, // Riwayat Psikososial
    'section_4': {}, // Riwayat Psikiatri
    'section_5': {}, // Pemeriksaan Psikologis
    'section_6': {}, // Fungsi Psikologis
    'section_7': {}, // Fungsi Sosial
    'section_8': {}, // Fungsi Spiritual
    'section_9': {}, // Renpra (Rencana Perawatan) - moved from section 10 to 9
    'section_10': {}, // Penutup - moved from section 11 to 10
  };

  @override
  void initState() {
    super.initState();
    _currentPatient = widget.patient ?? Get.arguments?['patient'] as Patient?;
    _currentPatientId = _currentPatient?.id ?? Get.arguments?['patientId'] as int?;
    initializeForm();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextSection() {
    if (_currentSection < 9) {
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
        return _buildSection1IdentitasKlien();
      case 1:
        return _buildSection2RiwayatKehidupan();
      case 2:
        return _buildSection3RiwayatPsikososial();
      case 3:
        return _buildSection4RiwayatPsikiatri();
      case 4:
        return _buildSection5PemeriksaanPsikologis();
      case 5:
        return _buildSection6FungsiPsikologis();
      case 6:
        return _buildSection7FungsiSosial();
      case 7:
        return _buildSection8FungsiSpiritual();
      case 8:
        return _buildSection9Renpra();
      case 9:
        return _buildSection10Penutup();
      default:
        return const SizedBox();
    }
  }

  Widget _buildSection1IdentitasKlien() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 1: Identitas Klien',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[0],
          decoration: const InputDecoration(
            labelText: 'Nama Lengkap',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['section_1']['nama_lengkap'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[1],
          decoration: const InputDecoration(
            labelText: 'Umur',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            formData['section_1']['umur'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[2],
          decoration: const InputDecoration(
            labelText: 'Jenis Kelamin',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['section_1']['jenis_kelamin'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[3],
          decoration: const InputDecoration(
            labelText: 'Status Perkawinan',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['section_1']['status_perkawinan'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection2RiwayatKehidupan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 2: Riwayat Kehidupan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[4],
          decoration: const InputDecoration(
            labelText: 'Riwayat Pendidikan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['section_2']['riwayat_pendidikan'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[5],
          decoration: const InputDecoration(
            labelText: 'Pekerjaan',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['section_2']['pekerjaan'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[6],
          decoration: const InputDecoration(
            labelText: 'Riwayat Keluarga',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['section_2']['riwayat_keluarga'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection3RiwayatPsikososial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 3: Riwayat Psikososial',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[7],
          decoration: const InputDecoration(
            labelText: 'Hubungan Sosial',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['section_3']['hubungan_sosial'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[8],
          decoration: const InputDecoration(
            labelText: 'Dukungan Sosial',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['section_3']['dukungan_sosial'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[9],
          decoration: const InputDecoration(
            labelText: 'Stresor Psikososial',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['section_3']['stresor_psikososial'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection4RiwayatPsikiatri() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 4: Riwayat Psikiatri',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[10],
          decoration: const InputDecoration(
            labelText: 'Riwayat Gangguan Psikiatri',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['section_4']['riwayat_gangguan_psikiatri'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[11],
          decoration: const InputDecoration(
            labelText: 'Riwayat Pengobatan Sebelumnya',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['section_4']['riwayat_pengobatan'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection5PemeriksaanPsikologis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 5: Pemeriksaan Psikologis',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[12],
          decoration: const InputDecoration(
            labelText: 'Kesadaran',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['section_5']['kesadaran'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[13],
          decoration: const InputDecoration(
            labelText: 'Orientasi',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['section_5']['orientasi'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[14],
          decoration: const InputDecoration(
            labelText: 'Penampilan',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['section_5']['penampilan'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection6FungsiPsikologis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 6: Fungsi Psikologis',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[15],
          decoration: const InputDecoration(
            labelText: 'Mood',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['section_6']['mood'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[16],
          decoration: const InputDecoration(
            labelText: 'Afect',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['section_6']['afect'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[17],
          decoration: const InputDecoration(
            labelText: 'Alam pikiran',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['section_6']['alam_pikiran'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection7FungsiSosial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 7: Fungsi Sosial',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[18],
          decoration: const InputDecoration(
            labelText: 'Fungsi Sosial',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['section_7']['fungsi_sosial'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[19],
          decoration: const InputDecoration(
            labelText: 'Interaksi Sosial',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['section_7']['interaksi_sosial'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection8FungsiSpiritual() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 8: Fungsi Spiritual',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[20],
          decoration: const InputDecoration(
            labelText: 'Kepercayaan',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['section_8']['kepercayaan'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[21],
          decoration: const InputDecoration(
            labelText: 'Praktik Ibadah',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            formData['section_8']['praktik_ibadah'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection9Renpra() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 9: Rencana Perawatan (Renpra)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Diagnosis dropdown
        const Text('Diagnosis'),
        const SizedBox(height: 8),
        Obx(() {
          final nursingService = Get.find<NursingDataGlobalService>();
          final diagnoses = nursingService.diagnoses;

          // Create dropdown items from dynamic diagnoses
          final items = diagnoses
              .map(
                (diag) =>
                    DropdownMenuItem(value: diag.id, child: Text(diag.name)),
              )
              .toList();

          // Add a default option if no diagnoses available
          if (items.isEmpty) {
            items.add(
              DropdownMenuItem<int>(
                value: null,
                child: const Text('Tidak ada diagnosis tersedia'),
              ),
            );
          }

          return DropdownButtonFormField<int?>(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: items.cast<DropdownMenuItem<int?>>(),
            value: formData['section_9']['diagnosis'] as int?,
            onChanged: (value) {
              formData['section_9']['diagnosis'] = value;
            },
            hint: const Text('Pilih Diagnosis'),
          );
        }),
        const SizedBox(height: 16),
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
                  (formData['section_9']['intervensi'] as List?) ?? <int>[];
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
                  formData['section_9']['intervensi'] = intervensi;
                  setState(() {});
                },
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[22],
          decoration: const InputDecoration(
            labelText: 'Tujuan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['section_9']['tujuan'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[23],
          decoration: const InputDecoration(
            labelText: 'Kriteria',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['section_9']['kriteria'] = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[24],
          decoration: const InputDecoration(
            labelText: 'Rasional',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            formData['section_9']['rasional'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildSection10Penutup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section 10: Penutup',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[25],
          decoration: const InputDecoration(
            labelText: 'Catatan Tambahan',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          onChanged: (value) {
            formData['section_10']['catatan_tambahan'] = value;
          },
        ),
        const SizedBox(height: 16),
        const Text('Tanggal Pengisian:'),
        TextButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              formData['section_10']['tanggal_pengisian'] = pickedDate
                  .toIso8601String();
            }
          },
          child: Text(
            formData['section_10']['tanggal_pengisian'] ?? 'Pilih Tanggal',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.formId == null
              ? 'Resume Poliklinik Kesehatan Jiwa'
              : 'Edit Resume',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(value: (_currentSection + 1) / 10),
            const SizedBox(height: 16),
            Text('Section ${_currentSection + 1} dari 10'),
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

                if (_currentSection == 9)
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
