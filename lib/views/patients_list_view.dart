import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/patient_service.dart';
import '../services/logger_service.dart';

class PatientsListView extends StatefulWidget {
  const PatientsListView({super.key});

  @override
  State<PatientsListView> createState() => PatientsListViewState();
}

class PatientsListViewState extends State<PatientsListView>
    with AutomaticKeepAliveClientMixin {
  final LoggerService _logger = LoggerService();
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _items = [];
  bool _isSearchFocused = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await PatientService.list(
        query: _searchController.text.trim(),
      );
      _logger.info(
        'Fetched patients list',
        context: {'statusCode': res.statusCode},
      );
      if (res.body.isEmpty) {
        setState(() {
          _error = 'Empty response';
        });
        return;
      }
      final data = json.decode(res.body);
      if (res.statusCode == 200) {
        final list = (data is List)
            ? data
            : (data['data'] ?? data['patients'] ?? []);
        _items = List<Map<String, dynamic>>.from(list);
      } else {
        _error =
            (data['error']?['message'] ?? data['message'] ?? 'Failed to load');
      }
    } catch (e) {
      _error = e.toString();
      _logger.error('Error loading patients', error: e);
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            final crossAxisCount = isWideScreen
                ? (constraints.maxWidth > 900 ? 3 : 2)
                : 1;

            return Column(
              children: [
                // Header Section
                Container(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daftar Pasien',
                                      style: textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_items.length} pasien terdaftar',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isWideScreen)
                                IconButton.filledTonal(
                                  icon: const Icon(Icons.person_add_rounded),
                                  onPressed: () async {
                                    await Get.toNamed('/patient-form');
                                    _fetch();
                                  },
                                  tooltip: 'Tambah Pasien',
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Search Bar
                          _buildSearchBar(colorScheme, isWideScreen),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content Section
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
                            : _buildPatientsList(
                                colorScheme,
                                textTheme,
                                isWideScreen,
                                crossAxisCount,
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
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;
          if (!isWideScreen) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () async {
              await Get.toNamed('/patient-form');
              _fetch();
            },
            icon: const Icon(Icons.person_add_rounded),
            label: const Text(
              'Tambah Pasien',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            elevation: 4,
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme, bool isWideScreen) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSearchFocused
              ? colorScheme.primary
              : colorScheme.outlineVariant.withOpacity(0.5),
          width: _isSearchFocused ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Focus(
              onFocusChange: (focused) {
                setState(() => _isSearchFocused = focused);
              },
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Cari nama pasien atau nomor RM...',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.primary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _fetch();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _fetch(),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilledButton.icon(
              onPressed: _fetch,
              icon: const Icon(Icons.search_rounded, size: 20),
              label: Text(isWideScreen ? 'Cari' : ''),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? 20 : 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
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
          Text(
            'Memuat data pasien...',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme, TextTheme textTheme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Terjadi Kesalahan',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _fetch,
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
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_search_rounded,
                  size: 80,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _searchController.text.isEmpty
                    ? 'Belum Ada Pasien'
                    : 'Tidak Ada Hasil',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchController.text.isEmpty
                    ? 'Mulai dengan menambahkan pasien baru'
                    : 'Coba kata kunci pencarian yang berbeda',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (_searchController.text.isEmpty) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () async {
                    await Get.toNamed('/patient-form');
                    _fetch();
                  },
                  icon: const Icon(Icons.person_add_rounded),
                  label: const Text('Tambah Pasien Pertama'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientsList(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isWideScreen,
    int crossAxisCount,
  ) {
    if (crossAxisCount == 1) {
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isWideScreen ? 32.0 : 20.0),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _buildPatientCard(_items[index], colorScheme, textTheme, false),
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3.5,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) =>
          _buildPatientCard(_items[index], colorScheme, textTheme, true),
    );
  }

  Widget _buildPatientCard(
    Map<String, dynamic> patient,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isGrid,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: () {
            Get.toNamed(
              '/form-selection',
              arguments: {
                'patientId': patient['id'],
                'patientName': patient['name'],
              },
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(patient['name'] ?? 'N/A'),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        patient['name'] ?? 'Nama Tidak Diketahui',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'RM: ${patient['rm_number'] ?? 'N/A'}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.cake_outlined,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${patient['age'] ?? '-'} th',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'N/A';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }
}
