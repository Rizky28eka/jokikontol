import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_selection_controller.dart';
import '../utils/responsive.dart';
import '../models/form_model.dart';
import '../services/logger_service.dart';
import 'form_detail_view.dart';

class FormSelectionView extends GetView<FormSelectionController> {
  final LoggerService _logger = LoggerService();

  FormSelectionView({super.key});

  final List<FormType> _formTypes = [
    FormType(
      type: 'pengkajian',
      title: 'Pengkajian Kesehatan Jiwa',
      description: 'Formulir pengkajian awal klien',
      icon: Icons.medical_information,
    ),
    FormType(
      type: 'resume_kegawatdaruratan',
      title: 'Resume Kegawatdaruratan Psikiatri',
      description: 'Resume untuk kasus kegawatdaruratan psikiatri',
      icon: Icons.emergency,
    ),
    FormType(
      type: 'resume_poliklinik',
      title: 'Resume Poliklinik',
      description: 'Resume untuk kunjungan poliklinik',
      icon: Icons.local_hospital,
    ),
    FormType(
      type: 'sap',
      title: 'SAP (Satuan Acara Penyuluhan)',
      description: 'Satuan acara penyuluhan kesehatan',
      icon: Icons.school,
    ),
    FormType(
      type: 'catatan_tambahan',
      title: 'Catatan Tambahan',
      description: 'Catatan tambahan untuk dokumentasi',
      icon: Icons.note_add,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(FormSelectionController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final r = Responsive(constraints);
            final isWide = r.isMedium || r.isWide || r.isExpanded;
            final horizontalPadding = r.isCompact ? 20.0 : 32.0;
            final maxWidth = r.isExpanded
                ? 1100.0
                : (r.isWide ? 980.0 : (r.isMedium ? 900.0 : double.infinity));

            return RefreshIndicator(
              onRefresh: controller.fetchForms,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 32),
                          Obx(() => _buildContent(context, isWide)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.folder_open_rounded,
                color: colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formulir Pasien',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.patientName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, bool isWide) {
    if (controller.isLoading) {
      return _buildLoadingState(context);
    }

    if (controller.errorMessage.isNotEmpty) {
      return _buildErrorState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.forms.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            'Form yang Sudah Dibuat',
            Icons.history_rounded,
          ),
          const SizedBox(height: 16),
          _buildExistingFormsList(context, isWide),
          const SizedBox(height: 40),
        ],
        _buildSectionHeader(
          context,
          'Buat Form Baru',
          Icons.add_circle_outline_rounded,
        ),
        const SizedBox(height: 16),
        _buildNewFormsList(context, isWide),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 22, color: colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Memuat formulir...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Terjadi Kesalahan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: controller.fetchForms,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingFormsList(BuildContext context, bool isWide) {
    if (isWide) {
      final width = MediaQuery.of(context).size.width;
      int columns = 2;
      if (width > ResponsiveBreakpoints.medium &&
          width < ResponsiveBreakpoints.expanded) {
        columns = 3;
      }
      if (width >= ResponsiveBreakpoints.expanded) columns = 4;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: 3.6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: controller.forms.length,
        itemBuilder: (context, index) {
          return _buildExistingFormCard(
            context,
            controller.forms[index],
          );
        },
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.forms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildExistingFormCard(context, controller.forms[index]);
      },
    );
  }

  Widget _buildNewFormsList(BuildContext context, bool isWide) {
    if (isWide) {
      final width = MediaQuery.of(context).size.width;
      int columns = 2;
      if (width > ResponsiveBreakpoints.medium &&
          width < ResponsiveBreakpoints.expanded) {
        columns = 3;
      }
      if (width >= ResponsiveBreakpoints.expanded) columns = 4;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: 3.4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _formTypes.length,
        itemBuilder: (context, index) {
          return _buildFormTypeCard(context, _formTypes[index]);
        },
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _formTypes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildFormTypeCard(context, _formTypes[index]);
      },
    );
  }

  Widget _buildExistingFormCard(BuildContext context, FormModel form) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(form.status, colorScheme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showFormOptions(form),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withOpacity(0.2),
                      statusColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getFormIcon(form.type),
                  color: statusColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.getFormTitle(form.type),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(form.status),
                                  size: 14,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _getStatusText(form.status),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            form.createdAt.toString().substring(0, 10),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.more_vert_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormTypeCard(BuildContext context, FormType formType) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => controller.createForm(formType.type),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.primaryContainer.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  formType.icon,
                  color: colorScheme.onPrimaryContainer,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formType.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formType.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.add_circle_rounded,
                color: colorScheme.primary,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFormOptions(FormModel form) {
    final colorScheme = Get.theme.colorScheme;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Opsi Formulir',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              icon: Icons.edit_rounded,
              title: 'Edit Formulir',
              iconColor: colorScheme.primary,
              onTap: () {
                Get.back();
                controller.openExistingForm(form);
              },
            ),
            if (form.status != 'approved')
              _buildOptionTile(
                icon: Icons.delete_rounded,
                title: 'Hapus Formulir',
                iconColor: colorScheme.error,
                onTap: () {
                  Get.back();
                  _confirmDeleteForm(form);
                },
              ),
            _buildOptionTile(
              icon: Icons.info_rounded,
              title: 'Detail Formulir',
              subtitle:
                  'Status: ${_getStatusText(form.status)} • ${form.createdAt.toString().substring(0, 16)}',
              iconColor: colorScheme.tertiary,
              onTap: () {
                Get.back();
                _showFormDetails(form);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => Get.back(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Get.theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Get.theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  void _confirmDeleteForm(FormModel form) {
    final colorScheme = Get.theme.colorScheme;

    Get.dialog(
      AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text(
          "Apakah Anda yakin ingin menghapus formulir ${controller.getFormTitle(form.type)}?\n\nTindakan ini tidak dapat dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _logger.userAction(
                action: 'Delete form cancelled',
                metadata: {'formId': form.id.toString(), 'formType': form.type},
              );
            },
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.deleteForm(form);
            },
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showFormDetails(FormModel form) {
    Get.to(() => const FormDetailView(), arguments: form);
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'submitted':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'revised':
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'submitted':
        return Icons.send_rounded;
      case 'approved':
        return Icons.check_circle_rounded;
      case 'revised':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'submitted':
        return 'Menunggu Review';
      case 'approved':
        return 'Disetujui';
      case 'revised':
        return 'Perlu Revisi';
      default:
        return status;
    }
  }

  IconData _getFormIcon(String type) {
    switch (type) {
      case 'pengkajian':
        return Icons.medical_information_rounded;
      case 'resume_kegawatdaruratan':
        return Icons.emergency_rounded;
      case 'resume_poliklinik':
        return Icons.local_hospital_rounded;
      case 'sap':
        return Icons.school_rounded;
      case 'catatan_tambahan':
        return Icons.note_add_rounded;
      default:
        return Icons.description_rounded;
    }
  }
}

class FormType {
  final String type;
  final String title;
  final String description;
  final IconData icon;

  FormType({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
  });
}
