import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/form_model.dart';
import '../services/forms_service.dart';
import '../services/logger_service.dart';
import 'form_detail_view.dart';

class FormsListView extends StatefulWidget {
  const FormsListView({super.key});

  @override
  State<FormsListView> createState() => FormsListViewState();
}

class FormsListViewState extends State<FormsListView>
    with AutomaticKeepAliveClientMixin {
  final LoggerService _logger = LoggerService();
  String? _selectedType;
  String? _selectedStatus;
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _items = [];

  @override
  bool get wantKeepAlive => true;

  final List<Map<String, String>> _types = const [
    {'value': '', 'label': 'Semua Jenis'},
    {'value': 'pengkajian', 'label': 'Pengkajian'},
    {'value': 'resume_kegawatdaruratan', 'label': 'Kegawatdaruratan'},
    {'value': 'resume_poliklinik', 'label': 'Poliklinik'},
    {'value': 'sap', 'label': 'SAP'},
    {'value': 'catatan_tambahan', 'label': 'Catatan Tambahan'},
  ];

  final List<Map<String, String>> _statuses = const [
    {'value': '', 'label': 'Semua Status'},
    {'value': 'submitted', 'label': 'Menunggu Review'},
    {'value': 'revised', 'label': 'Perlu Revisi'},
    {'value': 'approved', 'label': 'Disetujui'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = _types.first['value'];
    _selectedStatus = _statuses.first['value'];
    _fetch();
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await FormsService.list(
        type: (_selectedType?.isNotEmpty ?? false) ? _selectedType : null,
        status: (_selectedStatus?.isNotEmpty ?? false) ? _selectedStatus : null,
      );
      _logger.info(
        'Fetched forms list',
        context: {'statusCode': res.statusCode},
      );
      if (res.body.isEmpty) {
        setState(() {
          _items = [];
        });
        return;
      }
      final data = json.decode(res.body);
      if (res.statusCode == 200) {
        final list = (data is List)
            ? data
            : (data['data'] ?? data['forms'] ?? data['items'] ?? []);
        _items = List<Map<String, dynamic>>.from(list);
      } else {
        _error =
            (data['error']?['message'] ?? data['message'] ?? 'Failed to load');
      }
    } catch (e) {
      _error = e.toString();
      _logger.error('Error loading forms', error: e);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void refresh() => _fetch();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 600;
            final maxContentWidth = isWideScreen ? 1200.0 : double.infinity;

            return Column(
              children: [
                _buildHeader(context, isWideScreen, maxContentWidth),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetch,
                    color: colorScheme.primary,
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: _loading
                            ? _buildLoadingState(colorScheme)
                            : _error.isNotEmpty
                            ? _buildErrorState(colorScheme, textTheme)
                            : _items.isEmpty
                            ? _buildEmptyState(colorScheme, textTheme)
                            : _buildFormsList(
                                colorScheme,
                                textTheme,
                                isWideScreen,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isWideScreen, double maxContentWidth) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWideScreen ? 32.0 : 20.0,
        vertical: 24.0,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Form',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_items.length} form ditemukan',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              isWideScreen
                  ? Row(
                      children: [
                        Expanded(child: _buildFilterDropdown(_types, _selectedType, Icons.filter_list_rounded, (v) => setState(() => _selectedType = v))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFilterDropdown(_statuses, _selectedStatus, Icons.checklist_rounded, (v) => setState(() => _selectedStatus = v))),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          onPressed: _fetch,
                          icon: const Icon(Icons.search),
                          label: const Text('Filter'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                          ),
                        )
                      ],
                    )
                  : Column(
                      children: [
                        _buildFilterDropdown(_types, _selectedType, Icons.filter_list_rounded, (v) => setState(() => _selectedType = v)),
                        const SizedBox(height: 12),
                        _buildFilterDropdown(_statuses, _selectedStatus, Icons.checklist_rounded, (v) => setState(() => _selectedStatus = v)),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
      List<Map<String, String>> items, String? currentValue, IconData icon, ValueChanged<String?> onChanged) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: currentValue,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: colorScheme.primary, size: 22),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.2), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item['value'],
                  child: Text(item['label']!),
                ))
            .toList(),
        onChanged: (v) {
          onChanged(v);
          _fetch();
        },
        dropdownColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildFormsList(
      ColorScheme colorScheme, TextTheme textTheme, bool isWideScreen) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(isWideScreen ? 32.0 : 20.0),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildFormCard(_items[index], colorScheme, textTheme),
    );
  }

  Widget _buildFormCard(
      Map<String, dynamic> form, ColorScheme colorScheme, TextTheme textTheme) {
    final model = FormModel.fromJson(form);
    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () async {
          await Get.to(() => const FormDetailView(), arguments: model);
          _fetch();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5), width: 1),
          ),
          child: Row(
            children: [
              _buildTypeIcon(form['type'], colorScheme),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleForType(form['type']),
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _patientName(form),
                            style: textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(form['status'], colorScheme),
                  const SizedBox(height: 8),
                  Icon(Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(String? type, ColorScheme colorScheme) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        _iconForType(type),
        color: colorScheme.onPrimaryContainer,
        size: 26,
      ),
    );
  }

  Widget _buildStatusBadge(String? status, ColorScheme colorScheme) {
    Color backgroundColor;
    Color foregroundColor;
    String label = _statusLabel(status);

    switch (status?.toLowerCase()) {
      case 'submitted':
        backgroundColor = Colors.orange.shade100;
        foregroundColor = Colors.orange.shade800;
        break;
      case 'revised':
        backgroundColor = colorScheme.errorContainer;
        foregroundColor = colorScheme.onErrorContainer;
        break;
      case 'approved':
        backgroundColor = Colors.green.shade100;
        foregroundColor = Colors.green.shade800;
        break;
      default:
        backgroundColor = colorScheme.secondaryContainer;
        foregroundColor = colorScheme.onSecondaryContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 3),
          const SizedBox(height: 16),
          Text('Memuat data form...',
              style:
                  TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text('Gagal memuat data',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_error,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            FilledButton.icon(
                onPressed: _fetch,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.find_in_page_outlined,
                size: 80, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text('Tidak ada form ditemukan',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Coba ubah filter atau kembali lagi nanti.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String? type) {
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

  String _titleForType(String? type) {
    switch (type) {
      case 'pengkajian':
        return 'Pengkajian Kesehatan Jiwa';
      case 'resume_kegawatdaruratan':
        return 'Resume Kegawatdaruratan';
      case 'resume_poliklinik':
        return 'Resume Poliklinik';
      case 'sap':
        return 'SAP';
      case 'catatan_tambahan':
        return 'Catatan Tambahan';
      default:
        return 'Form';
    }
  }

  String _statusLabel(String? status) {
    if (status == null) return '-';
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Menunggu';
      case 'revised':
        return 'Revisi';
      case 'approved':
        return 'Disetujui';
      default:
        return status.capitalizeFirst ?? status;
    }
  }

  String _patientName(Map<String, dynamic> f) {
    if (f['patient'] is Map) {
      final p = f['patient'];
      if (p['name'] != null && p['name'].toString().isNotEmpty) {
        return p['name'].toString();
      }
    }
    if (f['patient_name'] != null && f['patient_name'].toString().isNotEmpty) {
      return f['patient_name'].toString();
    }
    return 'Tanpa Nama';
  }
}