import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class DosenDashboardViewWithStats extends StatelessWidget {
  const DosenDashboardViewWithStats({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController = Get.put(DashboardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Dosen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              if (dashboardController.isDosenStatsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (dashboardController.errorMessage.isNotEmpty) {
                return Center(child: Text('Error: ${dashboardController.errorMessage}'));
              }

              final stats = dashboardController.dosenStats;
              if (stats.isEmpty) {
                return const Center(child: Text('No statistics available'));
              }

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard(
                    'Total Mahasiswa',
                    stats['total_mahasiswa'].toString(),
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
                    'Form Menunggu Review',
                    stats['form_menunggu_review'].toString(),
                    Colors.orange,
                    Icons.pending_actions,
                  ),
                  _buildStatCard(
                    'Form Disetujui',
                    stats['form_disetujui'].toString(),
                    Colors.teal,
                    Icons.check_circle,
                  ),
                ],
              );
            }),
            const SizedBox(height: 30),
            const Text(
              'Daftar Form & Mahasiswa Aktif',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Active forms and students list - placeholder implementation
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Form & Mahasiswa Aktif (Placeholder)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text('Fitur ini akan menampilkan daftar form dan mahasiswa aktif'),
                      // In a real implementation, this would fetch actual data
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return SizedBox(
      width: 150,
      height: 100,
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