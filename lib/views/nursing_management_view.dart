import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/nursing_diagnosis_controller.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../models/nursing_diagnosis_model.dart';
import '../models/nursing_intervention_model.dart';

class NursingManagementView extends StatefulWidget {
  const NursingManagementView({super.key});

  @override
  State<NursingManagementView> createState() => _NursingManagementViewState();
}

class _NursingManagementViewState extends State<NursingManagementView> with TickerProviderStateMixin {
  late TabController _tabController;
  final NursingDiagnosisController _diagnosisController = Get.put(NursingDiagnosisController());
  final NursingInterventionController _interventionController = Get.put(NursingInterventionController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Diagnosis & Intervensi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Diagnosis'),
            Tab(text: 'Intervensi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DiagnosisTab(diagnosisController: _diagnosisController),
          InterventionTab(interventionController: _interventionController),
        ],
      ),
    );
  }
}

class DiagnosisTab extends StatelessWidget {
  final NursingDiagnosisController diagnosisController;

  const DiagnosisTab({super.key, required this.diagnosisController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add new diagnosis button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _showDiagnosisDialog(context, null),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Diagnosis'),
            ),
          ),
          const SizedBox(height: 16),
          // Diagnoses list
          Obx(() {
            if (diagnosisController.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (diagnosisController.errorMessage.isNotEmpty) {
              return Center(child: Text('Error: ${diagnosisController.errorMessage}'));
            }

            if (diagnosisController.diagnoses.isEmpty) {
              return const Center(child: Text('Tidak ada diagnosis ditemukan'));
            }
            
            return Expanded(
              child: ListView.builder(
                itemCount: diagnosisController.diagnoses.length,
                itemBuilder: (context, index) {
                  final diagnosis = diagnosisController.diagnoses[index];
                  return Card(
                    child: ListTile(
                      title: Text(diagnosis.name),
                      subtitle: Text(diagnosis.description ?? 'Tidak ada deskripsi'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showDiagnosisDialog(context, diagnosis),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteDiagnosis(diagnosis.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showDiagnosisDialog(BuildContext context, NursingDiagnosis? existingDiagnosis) {
    final nameController = TextEditingController(text: existingDiagnosis?.name);
    final descriptionController = TextEditingController(text: existingDiagnosis?.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingDiagnosis != null ? 'Edit Diagnosis' : 'Tambah Diagnosis Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Diagnosis'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (existingDiagnosis != null) {
                await diagnosisController.updateDiagnosis(
                  existingDiagnosis.id,
                  nameController.text,
                  descriptionController.text,
                );
              } else {
                await diagnosisController.createDiagnosis(
                  nameController.text,
                  descriptionController.text,
                );
              }
              Navigator.of(context).pop();
            },
            child: Text(existingDiagnosis != null ? 'Update' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteDiagnosis(int id) {
    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Apakah Anda yakin ingin menghapus diagnosis ini?',
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            await diagnosisController.deleteDiagnosis(id);
          },
          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

class InterventionTab extends StatelessWidget {
  final NursingInterventionController interventionController;

  const InterventionTab({super.key, required this.interventionController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add new intervention button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _showInterventionDialog(context, null),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Intervensi'),
            ),
          ),
          const SizedBox(height: 16),
          // Interventions list
          Obx(() {
            if (interventionController.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (interventionController.errorMessage.isNotEmpty) {
              return Center(child: Text('Error: ${interventionController.errorMessage}'));
            }

            if (interventionController.interventions.isEmpty) {
              return const Center(child: Text('Tidak ada intervensi ditemukan'));
            }
            
            return Expanded(
              child: ListView.builder(
                itemCount: interventionController.interventions.length,
                itemBuilder: (context, index) {
                  final intervention = interventionController.interventions[index];
                  return Card(
                    child: ListTile(
                      title: Text(intervention.name),
                      subtitle: Text(intervention.description ?? 'Tidak ada deskripsi'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showInterventionDialog(context, intervention),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteIntervention(intervention.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showInterventionDialog(BuildContext context, NursingIntervention? existingIntervention) {
    final nameController = TextEditingController(text: existingIntervention?.name);
    final descriptionController = TextEditingController(text: existingIntervention?.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingIntervention != null ? 'Edit Intervensi' : 'Tambah Intervensi Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Intervensi'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (existingIntervention != null) {
                await interventionController.updateIntervention(
                  existingIntervention.id,
                  nameController.text,
                  descriptionController.text,
                );
              } else {
                await interventionController.createIntervention(
                  nameController.text,
                  descriptionController.text,
                );
              }
              Navigator.of(context).pop();
            },
            child: Text(existingIntervention != null ? 'Update' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteIntervention(int id) {
    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Apakah Anda yakin ingin menghapus intervensi ini?',
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            await interventionController.deleteIntervention(id);
          },
          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}