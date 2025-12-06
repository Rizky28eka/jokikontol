import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../services/logger_service.dart';

class DosenDashboardView extends StatelessWidget {
  const DosenDashboardView({super.key});

  Future<void> _refreshDashboard() async {
    final LoggerService logger = LoggerService();
    logger.info('Refreshing Dosen Dashboard');
    final AuthController authController = Get.find();
    final DashboardController dashboardController = Get.find();
    
    // Refresh user profile
    await authController.getUserProfile();
    await dashboardController.fetchDosenStats();
    
    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final LoggerService logger = LoggerService();
    logger.info('DosenDashboardView loaded');
    final AuthController authController = Get.find();
    final DashboardController dashboardController = Get.put(DashboardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosen Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  if (authController.user != null) {
                    return Text(
                      'Welcome, ${authController.user!.name} (Dosen)',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return const Text('Loading...');
                }),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                // List Form - Placeholder
                const Text(
                  'Form & Reports',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: const Text('Laporan Mingguan'),
                    subtitle: const Text('Laporan aktivitas minggu ini'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Get.snackbar('Coming Soon', 'Form will be implemented soon');
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.assignment),
                    title: const Text('Evaluasi Mahasiswa'),
                    subtitle: const Text('Evaluasi kinerja mahasiswa'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Get.snackbar('Coming Soon', 'Form will be implemented soon');
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.rate_review),
                    title: const Text('Review & Revisi Form'),
                    subtitle: const Text('Review form yang dikumpulkan mahasiswa'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Get.toNamed('/dosen-review-dashboard');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => authController.logout(),
        child: const Icon(Icons.logout),
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