import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/nursing_service.dart';
import '../services/logger_service.dart';
import '../services/role_guard.dart';

class DiagnosesListView extends StatefulWidget {
  const DiagnosesListView({super.key});

  @override
  State<DiagnosesListView> createState() => _DiagnosesListViewState();
}

class _DiagnosesListViewState extends State<DiagnosesListView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final LoggerService _logger = LoggerService();
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await NursingService.listDiagnoses();
      _logger.info('Fetched diagnoses list', context: {'statusCode': res.statusCode});
      if (res.body.isEmpty) {
        if (mounted) setState(() { _error = 'Empty response'; });
        return;
      }
      final data = json.decode(res.body);
      if (res.statusCode == 200) {
        final list = (data is List) ? data : (data['data'] ?? []);
        _items = List<Map<String, dynamic>>.from(list);
      } else {
        _error = (data['error']?['message'] ?? data['message'] ?? 'Failed to load');
        _logger.error('Failed to load diagnoses', context: {'body': data});
      }
    } catch (e) {
      _error = e.toString();
      _logger.error('Error loading diagnoses', error: e);
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final colorScheme = Theme.of(context).colorScheme;
    final isDosen = RoleGuard.isDosen();
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Diagnosis Keperawatan')),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: _loading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
            : _error.isNotEmpty
                ? Center(child: Text('Error: $_error'))
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        child: ListTile(
                          title: Text(item['name'] ?? 'Tidak diketahui'),
                          subtitle: Text(item['description'] ?? ''),
                          trailing: isDosen
                              ? Icon(Icons.edit, color: colorScheme.primary)
                              : Icon(Icons.visibility, color: colorScheme.onSurfaceVariant),
                          onTap: () {
                            // Read-only for mahasiswa; show details dialog
                            if (!isDosen) {
                              Get.dialog(AlertDialog(
                                title: Text(item['name'] ?? 'Detail'),
                                content: Text(item['description'] ?? '—'),
                                actions: [TextButton(onPressed: () => Get.back(), child: const Text('Tutup'))],
                              ));
                            }
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
