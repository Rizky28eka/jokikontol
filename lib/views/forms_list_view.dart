import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/forms_service.dart';
import '../services/logger_service.dart';
import '../models/form_model.dart';
import 'form_detail_view.dart';

class FormsListView extends StatefulWidget {
  const FormsListView({super.key});

  @override
  State<FormsListView> createState() => FormsListViewState();
}

class FormsListViewState extends State<FormsListView> with AutomaticKeepAliveClientMixin {
  final LoggerService _logger = LoggerService();
  String? _selectedType;
  String? _selectedStatus;
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _items = [];

  @override
  bool get wantKeepAlive => true;

  final List<Map<String, String>> _types = const [
    {'value': '', 'label': 'Semua'},
    {'value': 'pengkajian', 'label': 'Pengkajian'},
    {'value': 'resume_kegawatdaruratan', 'label': 'Kegawatdaruratan'},
    {'value': 'resume_poliklinik', 'label': 'Poliklinik'},
    {'value': 'sap', 'label': 'SAP'},
    {'value': 'catatan_tambahan', 'label': 'Catatan Tambahan'},
  ];

  final List<Map<String, String>> _statuses = const [
    {'value': '', 'label': 'Semua'},
    {'value': 'draft', 'label': 'Draft'},
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
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await FormsService.list(
        type: (_selectedType?.isNotEmpty ?? false) ? _selectedType : null,
        status: (_selectedStatus?.isNotEmpty ?? false) ? _selectedStatus : null,
      );
      _logger.info('Fetched forms list', context: {'statusCode': res.statusCode});
      if (res.body.isEmpty) {
        setState(() { _error = 'Empty response'; });
        return;
      }
      final data = json.decode(res.body);
      if (res.statusCode == 200) {
        final list = (data is List) ? data : (data['data'] ?? data['forms'] ?? data['items'] ?? []);
        _items = List<Map<String, dynamic>>.from(list);
      } else {
        _error = (data['error']?['message'] ?? data['message'] ?? 'Failed to load');
      }
    } catch (e) {
      _error = e.toString();
      _logger.error('Error loading forms', error: e);
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  void refresh() => _fetch();

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Form')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: _types.map((t) => DropdownMenuItem(
                      value: t['value'],
                      child: Text(t['label']!),
                    )).toList(),
                    onChanged: (v) { setState(() { _selectedType = v; }); _fetch(); },
                    decoration: const InputDecoration(
                      labelText: 'Tipe', border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: _statuses.map((s) => DropdownMenuItem(
                      value: s['value'],
                      child: Text(s['label']!),
                    )).toList(),
                    onChanged: (v) { setState(() { _selectedStatus = v; }); _fetch(); },
                    decoration: const InputDecoration(
                      labelText: 'Status', border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _fetch,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
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
                            final f = _items[index];
                            return Card(
                              child: ListTile(
                                leading: Icon(_iconForType(f['type'])),
                                title: Text(_titleForType(f['type'])),
                                subtitle: Text('Status: ${_statusLabel(f['status'])} • Pasien: ${_patientName(f)}'),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () {
                                  final model = FormModel.fromJson(f);
                                  Get.to(() => const FormDetailView(), arguments: model);
                                },
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'pengkajian': return Icons.medical_information_rounded;
      case 'resume_kegawatdaruratan': return Icons.emergency_rounded;
      case 'resume_poliklinik': return Icons.local_hospital_rounded;
      case 'sap': return Icons.school_rounded;
      case 'catatan_tambahan': return Icons.note_add_rounded;
      default: return Icons.description_rounded;
    }
  }

  String _titleForType(String? type) {
    switch (type) {
      case 'pengkajian': return 'Pengkajian Kesehatan Jiwa';
      case 'resume_kegawatdaruratan': return 'Resume Kegawatdaruratan Psikiatri';
      case 'resume_poliklinik': return 'Resume Poliklinik';
      case 'sap': return 'SAP (Satuan Acara Penyuluhan)';
      case 'catatan_tambahan': return 'Catatan Tambahan';
      default: return 'Form';
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'draft': return 'Draft';
      case 'submitted': return 'Menunggu Review';
      case 'revised': return 'Perlu Revisi';
      case 'approved': return 'Disetujui';
      default: return status ?? '-';
    }
  }

  String _patientName(Map<String, dynamic> f) {
    // Prefer nested patient name, fallback to flat fields
    String? nested;
    final patient = f['patient'];
    if (patient is Map) {
      final nameVal = patient['name'];
      if (nameVal is String) nested = nameVal;
    }
    final flatDyn = f['patient_name'] ?? f['patientName'] ?? f['name'];
    final flat = flatDyn is String ? flatDyn : null;
    return nested ?? flat ?? '-';
  }
}
