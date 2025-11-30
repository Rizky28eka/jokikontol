import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/auth_controller.dart';
import '../services/logger_service.dart';

class MahasiswaDashboardView extends GetView<DashboardController> {
  const MahasiswaDashboardView({super.key});

  Future<void> _refreshDashboard() async {
    final LoggerService logger = LoggerService();
    logger.info('Refreshing Mahasiswa Dashboard');

    await Future.wait([
      controller.fetchMahasiswaStats(),
      controller.fetchLatestPatients(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final LoggerService logger = LoggerService();
    logger.info('MahasiswaDashboardView loaded');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final isDesktop = constraints.maxWidth > 900;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40.0 : (isTablet ? 24.0 : 16.0),
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 32),
                      _buildStatsSection(context, isTablet, isDesktop),
                      const SizedBox(height: 40),
                      _buildPatientsSection(
                        context,
                        isTablet,
                        isDesktop,
                        logger,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context, logger),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final AuthController authController = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.dashboard_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Mahasiswa',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola data pasien dan form Anda',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => authController.logout(),
              icon: Icon(
                Icons.logout_rounded,
                color: colorScheme.error,
              ),
              tooltip: 'Logout',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    bool isTablet,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Form',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isMahasiswaStatsLoading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }

          if (controller.errorMessage.isNotEmpty) {
            return _buildErrorCard(context, controller.errorMessage);
          }

          final stats = controller.mahasiswaStats;
          if (stats.isEmpty) {
            return _buildEmptyStateCard(
              context,
              'Tidak ada statistik tersedia',
              Icons.bar_chart_rounded,
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 2;
              if (constraints.maxWidth > 900) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 3;
              }

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isDesktop ? 1.3 : (isTablet ? 1.2 : 1.1),
                children: [
                  _buildStatCard(
                    context,
                    'Total Pasien',
                    stats['total_pasien'].toString(),
                    Icons.people_rounded,
                    Theme.of(context).colorScheme.primary,
                  ),
                  _buildStatCard(
                    context,
                    'Total Form',
                    stats['total_form'].toString(),
                    Icons.description_rounded,
                    Theme.of(context).colorScheme.tertiary,
                  ),
                  _buildStatCard(
                    context,
                    'Form Disetujui',
                    stats['form_disetujui'].toString(),
                    Icons.check_circle_rounded,
                    Colors.green.shade600,
                  ),
                  _buildStatCard(
                    context,
                    'Form Menunggu',
                    stats['form_menunggu'].toString(),
                    Icons.pending_actions_rounded,
                    Colors.orange.shade600,
                  ),
                ],
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsSection(
    BuildContext context,
    bool isTablet,
    bool isDesktop,
    LoggerService logger,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Pasien Terbaru',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLatestPatientsLoading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }

          if (controller.latestPatients.isEmpty) {
            return _buildEmptyStateCard(
              context,
              'Belum ada data pasien. Tambahkan pasien baru untuk memulai.',
              Icons.person_add_rounded,
            );
          }

          return _buildPatientsList(context, logger, isTablet, isDesktop);
        }),
      ],
    );
  }

  Widget _buildPatientsList(
    BuildContext context,
    LoggerService logger,
    bool isTablet,
    bool isDesktop,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        itemCount: controller.latestPatients.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: colorScheme.outlineVariant.withOpacity(0.3),
        ),
        itemBuilder: (context, index) {
          final patient = controller.latestPatients[index];
          return _buildPatientTile(context, patient, logger);
        },
      ),
    );
  }

  Widget _buildPatientTile(
    BuildContext context,
    Map<String, dynamic> patient,
    LoggerService logger,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          logger.userAction(
            action: 'Patient item clicked',
            metadata: {
              'page': 'MahasiswaDashboardView',
              'patientId': patient['id']?.toString(),
              'patientName': patient['name'],
            },
          );
          Get.toNamed(
            '/form-selection',
            arguments: {
              'patientId': patient['id'],
              'patientName': patient['name'],
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.primaryContainer.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient['name'] ?? 'Nama Tidak Diketahui',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _buildInfoChip(
                          context,
                          Icons.medical_information_rounded,
                          'RM: ${patient['rm_number'] ?? 'N/A'}',
                        ),
                        _buildInfoChip(
                          context,
                          Icons.cake_rounded,
                          '${patient['age'] ?? 'N/A'} Th',
                        ),
                        _buildInfoChip(
                          context,
                          patient['gender'] == 'L'
                              ? Icons.male_rounded
                              : Icons.female_rounded,
                          patient['gender'] == 'L'
                              ? 'Laki-laki'
                              : patient['gender'] == 'P'
                              ? 'Perempuan'
                              : 'N/A',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateCard(
    BuildContext context,
    String message,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.error.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Error: $error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context, LoggerService logger) {
    return FloatingActionButton.extended(
      onPressed: () async {
        logger.userAction(
          action: 'Add Patient FAB pressed',
          metadata: {'page': 'MahasiswaDashboardView'},
        );
        final result = await Get.toNamed('/patient-form');
        // If a new patient was created (result is not null), refresh latest patients
        if (result != null) {
          await controller.fetchLatestPatients();
          // Also try to refresh stats in case totals changed
          await controller.fetchMahasiswaStats();
        }
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('Tambah Pasien'),
      elevation: 4,
    );
  }
}
