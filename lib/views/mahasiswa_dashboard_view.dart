import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../services/logger_service.dart';

class MahasiswaDashboardView extends GetView<DashboardController> {
  const MahasiswaDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final LoggerService logger = LoggerService();
    logger.info('MahasiswaDashboardView loaded');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statistik Form',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Stats cards
              Obx(() {
                if (controller.isMahasiswaStatsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.isNotEmpty) {
                  return Center(child: Text('Error: ${controller.errorMessage}'));
                }

                final stats = controller.mahasiswaStats;
                if (stats.isEmpty) {
                  return const Center(child: Text('No statistics available'));
                }

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildStatCard(
                      'Total Pasien',
                      stats['total_pasien'].toString(),
                      Colors.blue,
                      Icons.people,
                    ),
                    _buildStatCard(
                      'Total Form',
                      stats['total_form'].toString(),
                      Colors.green,
                      Icons.description,
                    ),
                    _buildStatCard(
                      'Form Disetujui',
                      stats['form_disetujui'].toString(),
                      Colors.teal,
                      Icons.check_circle,
                    ),
                    _buildStatCard(
                      'Form Menunggu',
                      stats['form_menunggu'].toString(),
                      Colors.orange,
                      Icons.pending_actions,
                    ),
                  ],
                );
              }),
              const SizedBox(height: 30),
              const Text(
                'Daftar Pasien Terbaru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Latest patients list
              Obx(() {
                if (controller.isLatestPatientsLoading) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (controller.latestPatients.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Belum Ada Data Pasien',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text('Silakan tambah data pasien untuk melihatnya di sini'),
                        ],
                      ),
                    ),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: List.generate(controller.latestPatients.length, (index) {
                        final patient = controller.latestPatients[index];
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue[200],
                                ),
                                child: const Icon(Icons.person, color: Colors.blue),
                              ),
                              title: Text(
                                patient['name'] ?? 'Nama Tidak Diketahui',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RM: ${patient['rm_number'] ?? 'N/A'} | Usia: ${patient['age'] ?? 'N/A'} Tahun',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Jenis Kelamin: ${patient['gender'] == 'L' ? 'Laki-laki' : patient['gender'] == 'P' ? 'Perempuan' : 'N/A'}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                logger.userAction(
                                  action: 'Patient item clicked',
                                  metadata: {
                                    'page': 'MahasiswaDashboardView',
                                    'patientId': patient['id']?.toString(),
                                    'patientName': patient['name'],
                                  },
                                );
                                // Navigate to form selection view to choose form type for this patient
                                Get.toNamed('/form-selection', arguments: {
                                  'patientId': patient['id'],
                                  'patientName': patient['name'],
                                });
                              },
                            ),
                            if (index < controller.latestPatients.length - 1) const Divider(height: 1),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          logger.userAction(action: 'Add Patient FAB pressed', metadata: {'page': 'MahasiswaDashboardView'});
          Get.toNamed('/patient-form');
        },
        child: const Icon(Icons.add),
        
        tooltip: 'Tambah Data Pasien',
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      width: 150,
      height: 120,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}