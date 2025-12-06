import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../models/patient_model.dart';
import '../services/nursing_data_global_service.dart';
import '../utils/form_builder_mixin.dart';
import '../widgets/form_components/custom_checkbox_group.dart';
import '../widgets/form_components/custom_date_time_picker.dart';

class MentalHealthAssessmentFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const MentalHealthAssessmentFormView({super.key, this.patient, this.formId});

  @override
  State<MentalHealthAssessmentFormView> createState() =>
      _MentalHealthAssessmentFormViewState();
}

class _MentalHealthAssessmentFormViewState
    extends State<MentalHealthAssessmentFormView>
    with FormBuilderMixin {
  @override
  final FormController formController = Get.put(FormController());
  @override
  final PatientController patientController = Get.find();
  final NursingInterventionController _interventionController = Get.put(
    NursingInterventionController(),
  );

  int _currentSection = 0;
  final int _totalSections = 14; // Increased from 11 to 14 to accommodate new sections

  @override
  String get formType => 'pengkajian';

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

  void _nextSection() {
    updateFormData();
    if (_currentSection < _totalSections - 1) {
      setState(() => _currentSection++);
    }
  }

  void _previousSection() {
    updateFormData();
    if (_currentSection > 0) {
      setState(() => _currentSection--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Pengkajian Kesehatan Jiwa'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentSection + 1) / _totalSections,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          ),
        ),
      ),
      body: FormBuilder(
        key: formKey,
        initialValue: initialValues,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
                child: _buildSection(context, _currentSection),
              ),
            ),
            _buildBottomActionBar(colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, int sectionNumber) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String title;
    Widget content;

    switch (sectionNumber) {
      case 0:
        title = 'Identitas Pasien';
        content = _buildIdentitasPasienSection(colorScheme);
        break;
      case 1:
        title = 'Riwayat Kesehatan';
        content = _buildRiwayatKesehatanSection(colorScheme);
        break;
      case 2:
        title = 'Pemeriksaan Fisik';
        content = _buildPemeriksaanFisikSection(colorScheme);
        break;
      case 3:
        title = 'Riwayat Kehidupan';
        content = _buildRiwayatKehidupanSection(colorScheme);
        break;
      case 4:
        title = 'Riwayat Psikososial';
        content = _buildRiwayatPsikososialSection(colorScheme);
        break;
      case 5:
        title = 'Riwayat Psikiatri';
        content = _buildRiwayatPsikiatriSection(colorScheme);
        break;
      case 6:
        title = 'Pemeriksaan Psikologis';
        content = _buildPemeriksaanPsikologisSection(colorScheme);
        break;
      case 7:
        title = 'Fungsi Psikologis';
        content = _buildFungsiPsikologisSection(colorScheme);
        break;
      case 8:
        title = 'Fungsi Sosial';
        content = _buildFungsiSosialSection(colorScheme);
        break;
      case 9:
        title = 'Fungsi Spiritual';
        content = _buildFungsiSpiritualSection(colorScheme);
        break;
      case 10:
        title = 'Genogram';
        content = _buildGenogramSection(colorScheme);
        break;
      case 11:
        title = 'Status Mental';
        content = _buildStatusMentalSection(colorScheme);
        break;
      case 12:
        title = 'Rencana Perawatan (Renpra)';
        content = _buildRenpraSection(colorScheme);
        break;
      case 13:
        title = 'Penutup';
        content = _buildPenutupSection(colorScheme);
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      key: ValueKey('section_content_$sectionNumber'),
      child: _buildInfoCard(
        colorScheme: colorScheme,
        textTheme: textTheme,
        title: 'Bagian ${sectionNumber + 1}: $title',
        child: content,
      ),
    );
  }

  Widget _buildIdentitasPasienSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildTextFieldWithTooltip(name: 'nama_lengkap', label: 'Nama Lengkap', tooltip: 'Nama lengkap pasien sesuai identitas', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'tempat_lahir', label: 'Tempat Lahir', tooltip: 'Tempat kelahiran pasien', colorScheme: colorScheme),
        const SizedBox(height: 20),
        CustomDateTimePicker(
          name: 'tanggal_lahir',
          label: 'Tanggal Lahir',
          tooltip: 'Tanggal lahir pasien',
          inputType: InputType.date,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        ),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'umur', label: 'Umur', tooltip: 'Usia pasien dalam tahun', keyboardType: TextInputType.number, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildDropdownWithTooltip<String>(name: 'jenis_kelamin', label: 'Jenis Kelamin', tooltip: 'Jenis kelamin pasien', items: const [
          DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
          DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
        ], colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildDropdownWithTooltip<String>(name: 'status_perkawinan', label: 'Status Perkawinan', tooltip: 'Status perkawinan pasien saat ini', items: const [
          DropdownMenuItem(value: 'belum_kawin', child: Text('Belum Kawin')),
          DropdownMenuItem(value: 'menikah', child: Text('Menikah')),
          DropdownMenuItem(value: 'cerai_hidup', child: Text('Cerai Hidup')),
          DropdownMenuItem(value: 'cerai_mati', child: Text('Cerai Mati')),
          DropdownMenuItem(value: 'duda', child: Text('Duda')),
          DropdownMenuItem(value: 'janda', child: Text('Janda')),
        ], colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'agama', label: 'Agama', tooltip: 'Agama yang dianut pasien', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'suku', label: 'Suku', tooltip: 'Suku asal pasien', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'pendidikan', label: 'Pendidikan', tooltip: 'Pendidikan terakhir pasien', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'pekerjaan', label: 'Pekerjaan', tooltip: 'Pekerjaan pasien saat ini', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'alamat', label: 'Alamat', tooltip: 'Alamat tempat tinggal pasien', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'no_rm', label: 'Nomor Rekam Medis', tooltip: 'Nomor rekam medis pasien', colorScheme: colorScheme),
        const SizedBox(height: 20),
        CustomDateTimePicker(
          name: 'tanggal_masuk',
          label: 'Tanggal Masuk',
          tooltip: 'Tanggal pasien masuk ke fasilitas kesehatan',
          inputType: InputType.date,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        ),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'diagnosa_medis', label: 'Diagnosa Medis', tooltip: 'Diagnosa medis awal pasien', colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildRiwayatKesehatanSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildTextFieldWithTooltip(name: 'keluhan_utama', label: 'Keluhan Utama', tooltip: 'Keluhan utama yang dirasakan pasien', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'riwayat_penyakit_sekarang', label: 'Riwayat Penyakit Sekarang', tooltip: 'Riwayat penyakit yang sedang dialami pasien', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'riwayat_penyakit_dahulu', label: 'Riwayat Penyakit Dahulu', tooltip: 'Riwayat penyakit yang pernah dialami pasien sebelumnya', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'riwayat_penyakit_keluarga', label: 'Riwayat Penyakit Keluarga', tooltip: 'Riwayat penyakit dalam keluarga pasien', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'riwayat_pengobatan', label: 'Riwayat Pengobatan', tooltip: 'Riwayat pengobatan atau terapi sebelumnya', maxLines: 3, colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildPemeriksaanFisikSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildTextFieldWithTooltip(name: 'tekanan_darah', label: 'Tekanan Darah', tooltip: 'Tekanan darah pasien (sistolik/diastolik)', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'nadi', label: 'Nadi (x/menit)', tooltip: 'Frekuensi denyut nadi pasien per menit', keyboardType: TextInputType.number, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'suhu', label: 'Suhu (Celsius)', tooltip: 'Suhu tubuh pasien dalam satuan Celsius', keyboardType: TextInputType.number, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'pernapasan', label: 'Pernapasan (x/menit)', tooltip: 'Frekuensi pernapasan pasien per menit', keyboardType: TextInputType.number, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'tinggi_badan', label: 'Tinggi Badan (cm)', tooltip: 'Tinggi badan pasien dalam satuan sentimeter', keyboardType: TextInputType.number, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'berat_badan', label: 'Berat Badan (kg)', tooltip: 'Berat badan pasien dalam satuan kilogram', keyboardType: TextInputType.number, colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildRiwayatKehidupanSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildTextFieldWithTooltip(name: 'riwayat_pendidikan', label: 'Riwayat Pendidikan', tooltip: 'Pendidikan yang pernah ditempuh pasien', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'riwayat_keluarga', label: 'Riwayat Keluarga', tooltip: 'Kondisi sosial dan hubungan dalam keluarga pasien', maxLines: 3, colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildRiwayatPsikososialSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildTextFieldWithTooltip(name: 'konsep_diri', label: 'Konsep Diri', tooltip: 'Pandangan pasien terhadap dirinya sendiri', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'hubungan_sosial', label: 'Hubungan Sosial', tooltip: 'Hubungan pasien dengan lingkungan sosialnya', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'dukungan_sosial', label: 'Dukungan Sosial', tooltip: 'Jenis dukungan yang diterima pasien dari lingkungan', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'stresor_psikososial', label: 'Stresor Psikososial', tooltip: 'Faktor-faktor yang menyebabkan stres pada pasien', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'spiritual', label: 'Spiritual', tooltip: 'Aspek spiritual atau kepercayaan pasien', maxLines: 3, colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildRiwayatPsikiatriSection(ColorScheme colorScheme) {
    return _buildTextFieldWithTooltip(name: 'riwayat_gangguan_psikiatri', label: 'Riwayat Gangguan Psikiatri', tooltip: 'Riwayat gangguan psikiatri sebelumnya pada pasien', maxLines: 3, colorScheme: colorScheme);
  }

  Widget _buildPemeriksaanPsikologisSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildDropdownWithTooltip<String>(name: 'kesadaran', label: 'Kesadaran', tooltip: 'Tingkat kesadaran pasien saat pemeriksaan', items: const [
          DropdownMenuItem(value: 'sadar_penuh', child: Text('Sadar Penuh')),
          DropdownMenuItem(value: 'somnolent', child: Text('Somnolent')),
          DropdownMenuItem(value: 'stupor', child: Text('Stupor')),
          DropdownMenuItem(value: 'coma', child: Text('Coma')),
        ], colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildDropdownWithTooltip<String>(name: 'orientasi', label: 'Orientasi', tooltip: 'Kemampuan pasien mengenal diri dan lingkungan', items: const [
          DropdownMenuItem(value: 'utuh', child: Text('Utuh')),
          DropdownMenuItem(value: 'gangguan', child: Text('Gangguan')),
        ], colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'penampilan', label: 'Penampilan', tooltip: 'Deskripsi penampilan fisik pasien', colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildFungsiPsikologisSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildDropdownWithTooltip<String>(name: 'mood', label: 'Mood', tooltip: 'Perasaan umum pasien dalam periode waktu tertentu', items: const [
          DropdownMenuItem(value: 'normal', child: Text('Normal')),
          DropdownMenuItem(value: 'depresi', child: Text('Depresi')),
          DropdownMenuItem(value: 'ansietas', child: Text('Ansietas')),
          DropdownMenuItem(value: 'iritabel', child: Text('Iritabel')),
          DropdownMenuItem(value: 'labil', child: Text('Labil')),
        ], colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildDropdownWithTooltip<String>(name: 'afect', label: 'Afect', tooltip: 'Ekspresi emosional yang dapat diamati pada pasien', items: const [
          DropdownMenuItem(value: 'normal', child: Text('Normal')),
          DropdownMenuItem(value: 'flat', child: Text('Flat')),
          DropdownMenuItem(value: 'terhambat', child: Text('Terhambat')),
          DropdownMenuItem(value: 'labil', child: Text('Labil')),
          DropdownMenuItem(value: 'iritabel', child: Text('Iritabel')),
        ], colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'alam_pikiran', label: 'Alam Pikiran', tooltip: 'Isi pikiran yang dipercakapkan pasien', colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildFungsiSosialSection(ColorScheme colorScheme) {
    return _buildTextFieldWithTooltip(name: 'fungsi_sosial', label: 'Fungsi Sosial', tooltip: 'Kemampuan pasien dalam berinteraksi sosial', maxLines: 3, colorScheme: colorScheme);
  }

  Widget _buildFungsiSpiritualSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildTextFieldWithTooltip(name: 'kepercayaan', label: 'Kepercayaan', tooltip: 'Keyakinan atau kepercayaan yang dianut pasien', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'praktik_ibadah', label: 'Praktik Ibadah', tooltip: 'Aktivitas keagamaan atau spiritual yang dilakukan pasien', colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildGenogramSection(ColorScheme colorScheme) {
    final structure = formKey.currentState?.fields['genogram_structure']?.value;
    final notes = formKey.currentState?.fields['genogram_notes']?.value ?? '';
    final List members = structure != null && structure is Map ? (structure['members'] ?? []) as List : [];

    return Column(
      children: [
        FormBuilderField<Map<String, dynamic>>(name: 'genogram_structure', builder: (field) => const SizedBox.shrink()),
        _buildTextFieldWithTooltip(name: 'genogram_notes', label: 'Catatan Genogram', tooltip: 'Catatan tambahan mengenai hubungan keluarga', maxLines: 4, colorScheme: colorScheme),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () async {
              final result = await Get.toNamed('/genogram-builder', arguments: {'structure': structure ?? {'members': [], 'connections': []}, 'notes': notes});
              if (result != null && result is Map<String, dynamic>) {
                formKey.currentState?.fields['genogram_structure']?.didChange(result['structure'] ?? result);
                formKey.currentState?.fields['genogram_notes']?.didChange(result['notes'] ?? '');
                setState(() {});
              }
            },
            icon: const Icon(Icons.family_restroom_rounded),
            label: Text(members.isEmpty ? 'Buka Genogram Builder' : 'Edit Genogram (${members.length} Anggota)'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMentalSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildTextFieldWithTooltip(name: 'pembicaraan', label: 'Pembicaraan', tooltip: 'Gaya dan kecepatan berbicara pasien', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'aktivitas_motorik', label: 'Aktivitas Motorik', tooltip: 'Kemampuan gerak dan aktivitas fisik pasien', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'alam_perasaan', label: 'Alam Perasaan', tooltip: 'Perasaan yang dialami pasien', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'afek', label: 'Afek', tooltip: 'Ekspresi emosional yang dapat diamati', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'interaksi', label: 'Interaksi', tooltip: 'Cara pasien berinteraksi dengan orang lain', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'persepsi', label: 'Persepsi', tooltip: 'Kemampuan pasien dalam menangkap dan memahami informasi', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'proses_pikir', label: 'Proses Pikir', tooltip: 'Jalannya proses berpikir pasien', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'isi_pikir', label: 'Isi Pikir', tooltip: 'Isi pikiran yang dikembangkan pasien', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'tingkat_kesadaran', label: 'Tingkat Kesadaran', tooltip: 'Tingkat kesadaran dan kewaspadaan pasien', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'memori', label: 'Memori', tooltip: 'Kemampuan mengingat dan mengingat kembali informasi', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'tingkat_konsentrasi', label: 'Tingkat Konsentrasi', tooltip: 'Kemampuan memusatkan perhatian', colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'daya_tilik_diri', label: 'Daya Tilik Diri', tooltip: 'Kemampuan pasien menyadari kondisi dan keadaannya', colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildRenpraSection(ColorScheme colorScheme) {
    final nursingService = Get.find<NursingDataGlobalService>();
    return Column(
      children: [
        Obx(() {
          final diagnoses = nursingService.diagnoses;
          if (diagnoses.isEmpty) return const Center(child: Text('Data diagnosis tidak tersedia.'));
          return _buildDropdownWithTooltip<int>(name: 'diagnosis', label: 'Diagnosis', tooltip: 'Pilih diagnosis keperawatan yang sesuai', items: diagnoses.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(), colorScheme: colorScheme);
        }),
        const SizedBox(height: 20),
        _buildInterventionSection(colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'tujuan', label: 'Tujuan', tooltip: 'Tujuan perawatan yang ingin dicapai', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'kriteria', label: 'Kriteria Evaluasi', tooltip: 'Kriteria untuk mengevaluasi pencapaian tujuan', maxLines: 3, colorScheme: colorScheme),
        const SizedBox(height: 20),
        _buildTextFieldWithTooltip(name: 'rasional', label: 'Rasional', tooltip: 'Alasan atau landasan mengapa intervensi dipilih', maxLines: 3, colorScheme: colorScheme),
      ],
    );
  }

  Widget _buildInterventionSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Intervensi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest.withOpacity(0.3), borderRadius: BorderRadius.circular(12), border: Border.all(color: colorScheme.outline.withOpacity(0.2), width: 1)),
          child: Obx(() {
            final interventions = _interventionController.interventions;
            if (interventions.isEmpty) return const Center(child: Text('Tidak ada intervensi tersedia.'));
            final options = interventions.map((iv) => FormBuilderFieldOption(value: iv.id, child: Text(iv.name))).toList();
            return CustomCheckboxGroup<int>(name: 'intervensi', label: '', tooltip: 'Pilih intervensi yang akan dilakukan', options: options);
          }),
        ),
      ],
    );
  }

  Widget _buildPenutupSection(ColorScheme colorScheme) {
    final rawDate = initialValues['tanggal_pengisian'];
    DateTime? initialDate;
    if (rawDate is DateTime) {
      initialDate = rawDate;
    } else if (rawDate is String) {
      initialDate = DateTime.tryParse(rawDate);
    }

    return Column(
      children: [
        _buildTextFieldWithTooltip(name: 'catatan_tambahan', label: 'Catatan Tambahan', tooltip: 'Catatan tambahan atau informasi penting lainnya', maxLines: 5, colorScheme: colorScheme),
        const SizedBox(height: 20),
        CustomDateTimePicker(
          name: 'tanggal_pengisian',
          label: 'Tanggal Pengisian',
          tooltip: 'Tanggal formulir ini diisi',
          inputType: InputType.date,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required ColorScheme colorScheme, required TextTheme textTheme, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        const SizedBox(height: 24),
        child,
      ]),
    );
  }

  Widget _buildTextFieldWithTooltip({required String name, required String label, required ColorScheme colorScheme, TextInputType? keyboardType, int? maxLines = 1, String? tooltip}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
            const SizedBox(width: 4),
            tooltip != null ? Tooltip(
              message: tooltip,
              child: Icon(Icons.info_outline, size: 16, color: colorScheme.onSurfaceVariant),
            ) : const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 8),
        FormBuilderTextField(
          name: name,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownWithTooltip<T>({required String name, required String label, required List<DropdownMenuItem<T>> items, required ColorScheme colorScheme, ValueChanged<T?>? onChanged, String? tooltip}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
            const SizedBox(width: 4),
            tooltip != null ? Tooltip(
              message: tooltip,
              child: Icon(Icons.info_outline, size: 16, color: colorScheme.onSurfaceVariant),
            ) : const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 8),
        FormBuilderDropdown<T>(
          name: name,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
          ),
          dropdownColor: colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: colorScheme.surface, border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3), width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentSection > 0)
            TextButton.icon(
              onPressed: _previousSection,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              label: const Text('Sebelumnya'),
              style: TextButton.styleFrom(foregroundColor: colorScheme.onSurface),
            ),
          const Spacer(),
          SizedBox(
            height: 52,
            child: Obx(
              () => FilledButton.icon(
                onPressed: formController.isLoading ? null : (_currentSection == _totalSections - 1 ? submitForm : _nextSection),
                icon: formController.isLoading ? const SizedBox.shrink() : Icon(_currentSection == _totalSections - 1 ? Icons.save_alt_rounded : Icons.arrow_forward_ios_rounded),
                label: formController.isLoading
                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: colorScheme.onPrimary))
                    : Text(_currentSection == _totalSections - 1 ? 'Simpan' : 'Selanjutnya'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}