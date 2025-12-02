import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/nursing_service.dart';
import '../services/logger_service.dart';
import '../services/role_guard.dart';

class InterventionsListView extends StatefulWidget {
  const InterventionsListView({super.key});

  @override
  State<InterventionsListView> createState() => _InterventionsListViewState();
}

class _InterventionsListViewState extends State<InterventionsListView>
    with AutomaticKeepAliveClientMixin {
  final LoggerService _logger = LoggerService();
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isSearchFocused = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetch();
    _searchController.addListener(_filterItems);
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await NursingService.listInterventions();
      _logger.info('Fetched interventions list',
          context: {'statusCode': res.statusCode});
      if (res.body.isEmpty) {
        if (mounted) {
          setState(() {
            _items = [];
            _filteredItems = [];
            _loading = false;
          });
        }
        return;
      }
      final data = json.decode(res.body);
      if (res.statusCode == 200) {
        final list = (data is List) ? data : (data['data'] ?? []);
        _items = List<Map<String, dynamic>>.from(list);
        _filteredItems = List.from(_items);
      } else {
        _error =
            (data['error']?['message'] ?? data['message'] ?? 'Failed to load');
        _logger.error('Failed to load interventions', context: {'body': data});
      }
    } catch (e) {
      _error = e.toString();
      _logger.error('Error loading interventions', error: e);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
  
  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _items.where((item) {
        final name = (item['name'] ?? '').toLowerCase();
        final description = (item['description'] ?? '').toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void refresh() => _fetch();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDosen = RoleGuard.isDosen();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Daftar Intervensi'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(
          color: colorScheme.onSurface,
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;
          return Column(
            children: [
              _buildHeader(context, isWideScreen),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetch,
                  color: colorScheme.primary,
                  child: _loading
                      ? _buildLoadingState(colorScheme)
                      : _error.isNotEmpty
                          ? _buildErrorState(colorScheme, textTheme)
                          : _filteredItems.isEmpty
                              ? _buildEmptyState(colorScheme, textTheme)
                              : _buildItemsList(
                                  colorScheme, textTheme, isDosen),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: isDosen
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Implement add new intervention
                Get.snackbar('Fitur Dalam Pengembangan', 'Kemampuan untuk menambah intervensi baru akan segera hadir.');
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Intervensi'),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context, bool isWideScreen) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_filteredItems.length} intervensi keperawatan tersedia',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(colorScheme),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar(ColorScheme colorScheme) {
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
      child: Focus(
        onFocusChange: (focused) {
          setState(() => _isSearchFocused = focused);
        },
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Cari nama atau deskripsi intervensi...',
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
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList(ColorScheme colorScheme, TextTheme textTheme, bool isDosen) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      itemCount: _filteredItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildItemCard(item, colorScheme, textTheme, isDosen);
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, ColorScheme colorScheme, TextTheme textTheme, bool isDosen) {
    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          if (!isDosen) {
            Get.dialog(
              AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: colorScheme.surface,
                title: Text(item['name'] ?? 'Detail Intervensi', style: textTheme.titleLarge),
                content: SingleChildScrollView(
                  child: Text(item['description'] ?? 'Tidak ada deskripsi.', style: textTheme.bodyMedium)
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Tutup', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          } else {
             Get.snackbar('Fitur Dalam Pengembangan', 'Kemampuan untuk mengedit intervensi akan segera hadir.');
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.volunteer_activism_outlined,
                  color: colorScheme.onSecondaryContainer,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'Nama Tidak Diketahui',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description'] ?? 'Tidak ada deskripsi.',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                isDosen ? Icons.edit_note_rounded : Icons.visibility_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ],
          ),
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
          Text(
            'Memuat intervensi...',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
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
            Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text('Gagal memuat data', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _fetch,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    final bool isSearching = _searchController.text.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off_rounded : Icons.list_alt_outlined,
              size: 80,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'Tidak Ada Hasil' : 'Belum Ada Intervensi',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Tidak ada intervensi yang cocok dengan pencarian Anda.'
                  : 'Daftar intervensi keperawatan masih kosong.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}