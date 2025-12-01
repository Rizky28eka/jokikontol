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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pasien')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari nama/RM...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _fetch(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _fetch,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Cari'),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetch,
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
                  : _error.isNotEmpty
                  ? Center(child: Text('Error: $_error'))
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final p = _items[index];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(p['name'] ?? 'Nama Tidak Diketahui'),
                            subtitle: Text(
                              'RM: ${p['rm_number'] ?? 'N/A'} • ${p['age'] ?? '-'} th',
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              // Navigate to form selection for this patient
                              Get.toNamed(
                                '/form-selection',
                                arguments: {
                                  'patientId': p['id'],
                                  'patientName': p['name'],
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.toNamed('/patient-form');
          _fetch();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Pasien'),
      ),
    );
  }
}
