import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/logger_service.dart';

class DosenDashboardView extends StatelessWidget {
  const DosenDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final LoggerService logger = LoggerService();
    logger.info('DosenDashboardView loaded');
    final AuthController authController = Get.find();

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
      body: Padding(
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
            // Statistics Cards - Placeholder
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '120',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Total Mahasiswa'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            '8',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Active Classes'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
            Expanded(
              child: ListView(
                children: [
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
                      leading: const Icon(Icons.event_note),
                      title: const Text('Jadwal Kelas'),
                      subtitle: const Text('Rencana pembelajaran'),
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
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.bar_chart),
                      title: const Text('Statistik Dashboard'),
                      subtitle: const Text('Lihat statistik form dan mahasiswa'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Get.toNamed('/dosen-dashboard-stats');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => authController.logout(),
        child: const Icon(Icons.logout),
      ),
    );
  }
}