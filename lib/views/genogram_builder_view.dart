import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class GenogramBuilderView extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const GenogramBuilderView({super.key, this.initialData});

  @override
  State<GenogramBuilderView> createState() => _GenogramBuilderViewState();
}

class _GenogramBuilderViewState extends State<GenogramBuilderView> {
  // Data structure to store genogram relationships
  final List<Map<String, dynamic>> _familyMembers = [];

  // Data for the genogram structure
  final List<Map<String, dynamic>> _connections = [];

  // Controllers for the form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _otherRelationshipController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedGender = 'L';
  String _selectedStatus = 'alive';
  String? _selectedRelationship;
  bool _isOtherRelationship = false;
  bool _isReadOnly = false;
  // editingIndex removed as we use a dialog for edits

  // Connections state
  int? _selectedFromMemberId;
  int? _selectedToMemberId;
  String? _selectedConnectionType;

  final List<Map<String, String>> _connectionTypes = [
    {'id': 'parent_child', 'label': 'Orang Tua - Anak'},
    {'id': 'sibling', 'label': 'Saudara Kandung'},
    {'id': 'marriage', 'label': 'Pernikahan'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _relationshipController.dispose();
    _otherRelationshipController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Parse any initial data passed via widget.initialData or Get.arguments
    final Map<String, dynamic>? args = widget.initialData ?? (Get.arguments as Map<String, dynamic>?);
    if (args != null) {
      final struct = args['structure'] ?? args;
      if (struct != null) {
        // if struct is a list, treat it as the members list directly
        final dynamic rawMembers = (struct is List) ? struct : (struct['members'] ?? struct['family'] ?? null);
        final dynamic rawConnections = (struct is Map) ? (struct['connections'] ?? struct['edges'] ?? null) : null;
        List<Map<String, dynamic>> parsedMembers = [];
        List<Map<String, dynamic>> parsedConnections = [];

        if (rawMembers != null) {
          try {
            // Accept List or JSON string
            if (rawMembers is String) {
              final dynamicJson = json.decode(rawMembers);
              if (dynamicJson is List) {
                parsedMembers = List<Map<String, dynamic>>.from(dynamicJson.map((e) => (e is Map) ? Map<String, dynamic>.from(e) : json.decode(e)));
              }
            } else if (rawMembers is List) {
              parsedMembers = rawMembers.map<Map<String, dynamic>>((e) {
                if (e is Map) return Map<String, dynamic>.from(e);
                if (e is String) return Map<String, dynamic>.from(json.decode(e));
                return <String, dynamic>{};
              }).toList();
            }
          } catch (e) {
            // ignore parse issues
          }
        }

        if (rawConnections != null) {
          try {
            if (rawConnections is String) {
              final dynamicJson = json.decode(rawConnections);
              if (dynamicJson is List) {
                parsedConnections = List<Map<String, dynamic>>.from(dynamicJson.map((e) => (e is Map) ? Map<String, dynamic>.from(e) : json.decode(e)));
              }
            } else if (rawConnections is List) {
              parsedConnections = rawConnections.map<Map<String, dynamic>>((e) {
                if (e is Map) return Map<String, dynamic>.from(e);
                if (e is String) return Map<String, dynamic>.from(json.decode(e));
                return <String, dynamic>{};
              }).toList();
            }
          } catch (e) {
            // ignore
          }
        }
        // Ensure we replace the lists to avoid stale data
        _familyMembers.clear();
        _connections.clear();
        _familyMembers.addAll(parsedMembers);
        _connections.addAll(parsedConnections);
      }
      final notes = args['notes'] ?? (args['structure']?['notes']);
      if (notes != null) _notesController.text = notes;
      // read-only mode if passed via args
      final dynamic readOnlyArg = args['readOnly'];
      if (readOnlyArg != null) {
        try {
          _isReadOnly = readOnlyArg == true || readOnlyArg.toString() == 'true';
        } catch (e) {
          _isReadOnly = false;
        }
      }
      // Ensure UI updates after initial load
      setState(() {});
    }
  }

  void _addFamilyMember() {
    if (_nameController.text.isEmpty) {
      Get.snackbar('Error', 'Nama harus diisi');
      return;
    }

    final relationshipValue = _isOtherRelationship && _otherRelationshipController.text.isNotEmpty
      ? _otherRelationshipController.text
      : (_selectedRelationship != null && _selectedRelationship!.isNotEmpty ? _selectedRelationship : _relationshipController.text);
    if (relationshipValue == null || relationshipValue.isEmpty) {
      Get.snackbar('Error', 'Hubungan harus dipilih');
      return;
    }

    final member = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': _nameController.text,
      'age': int.tryParse(_ageController.text) ?? 0,
      'gender': _selectedGender,
      'status': _selectedStatus, // alive, deceased, pregnant
      'relationship': relationshipValue,
      'is_client': false,
    };

    _familyMembers.add(member);
    setState(() {});

    // Clear the form
    _nameController.clear();
    _ageController.clear();
    _relationshipController.clear();
    _otherRelationshipController.clear();
    _selectedRelationship = null;
    _isOtherRelationship = false;
    _selectedGender = 'L';
    _selectedStatus = 'alive';

    Get.snackbar('Success', 'Anggota keluarga ditambahkan');
  }

  void _showEditMemberDialog(int index) {
    final member = _familyMembers[index];
    final TextEditingController nameEdit = TextEditingController(text: member['name']);
    final TextEditingController ageEdit = TextEditingController(text: member['age']?.toString() ?? '');
    final TextEditingController otherRelEdit = TextEditingController(text: member['relationship'] ?? '');
    String genderEdit = member['gender'] ?? 'L';
    String statusEdit = member['status'] ?? 'alive';
    // NOTE: We'll simply use a TextFormField for relationship text in the edit dialog.

    Get.dialog(AlertDialog(
      title: const Text('Edit Anggota Keluarga'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameEdit,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: ageEdit,
              decoration: const InputDecoration(labelText: 'Usia'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: genderEdit,
              decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
              items: const [
                DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                DropdownMenuItem(value: 'P', child: Text('Perempuan')),
              ],
              onChanged: (v) => genderEdit = v ?? genderEdit,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: statusEdit,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'alive', child: Text('Hidup')),
                DropdownMenuItem(value: 'deceased', child: Text('Meninggal')),
                DropdownMenuItem(value: 'pregnant', child: Text('Hamil')),
              ],
              onChanged: (v) => statusEdit = v ?? statusEdit,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: otherRelEdit,
              decoration: const InputDecoration(labelText: 'Hubungan (isi)') ,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        TextButton(
          onPressed: () {
            setState(() {
              _familyMembers[index] = {
                'id': member['id'],
                'name': nameEdit.text,
                'age': int.tryParse(ageEdit.text) ?? member['age'],
                'gender': genderEdit,
                'status': statusEdit,
                'relationship': otherRelEdit.text,
              };
            });
            Get.back();
            Get.snackbar('Success', 'Anggota berhasil diperbarui');
          },
          child: const Text('Simpan'),
        ),
      ],
    ));
  }

  String _memberNameById(int id) {
    final f = _familyMembers.where((m) => m['id'] == id).toList();
    return f.isNotEmpty ? f.first['name'] : 'Unknown';
  }

  void _addConnection() {
    if (_selectedFromMemberId == null || _selectedToMemberId == null || _selectedConnectionType == null) {
      Get.snackbar('Error', 'Harap pilih kedua anggota dan tipe hubungan');
      return;
    }
    if (_selectedFromMemberId == _selectedToMemberId) {
      Get.snackbar('Error', 'Tidak boleh memilih anggota yang sama');
      return;
    }
    _connections.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'from': _selectedFromMemberId,
      'to': _selectedToMemberId,
      'type': _selectedConnectionType,
    });
    setState(() {});
  }

  Map<int, List<Map<String, dynamic>>> _connectionsMap() {
    final Map<int, List<Map<String, dynamic>>> map = {};
    for (final m in _familyMembers) {
      final id = m['id'];
      if (id is int) map[id] = [];
    }
    for (final c in _connections) {
      final from = c['from'] as int?;
      final to = c['to'] as int?;
      if (from == null || to == null) continue;
      map[from] = (map[from] ?? [])..add({'type': c['type'], 'to': to});
      map[to] = (map[to] ?? [])..add({'type': c['type'], 'from': from});
    }
    return map;
  }

  Color _relationshipColor(String rel) {
    final lower = rel.toLowerCase();
    if (lower.contains('ayah') || lower.contains('ibu')) return Colors.green;
    if (lower.contains('kakak') || lower.contains('adik')) return Colors.purple;
    if (lower.contains('anak')) return Colors.blue;
    if (lower.contains('pasangan')) return Colors.orange;
    if (lower.contains('istri') || lower.contains('suami')) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Genogram Builder'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Export JSON',
            onPressed: () async {
              final payload = json.encode({
                'structure': { 'members': _familyMembers, 'connections': _connections },
                'notes': _notesController.text
              });
              await Clipboard.setData(ClipboardData(text: payload));
              Get.snackbar('Copied', 'Genogram JSON copied to clipboard');
              // Also show a dialog
              Get.dialog(AlertDialog(
                title: const Text('Genogram JSON'),
                content: SingleChildScrollView(child: Text(payload)),
                actions: [
                  TextButton(onPressed: () => Get.back(), child: const Text('Close')),
                  TextButton(onPressed: () {
                    Clipboard.setData(ClipboardData(text: payload));
                    Get.back();
                  }, child: const Text('Copy')),
                ],
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Simbol Genogram:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: const [
                          Text('♂ - Laki-laki, '),
                          Text('♀ - Perempuan, '),
                          Text('☠ - Meninggal, '),
                          Text('○ - Hamil, ', style: TextStyle(fontSize: 20)),
                          Text('Klien - Individu utama'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Garis:'),
                      const Text('- Garis penuh = pernikahan'),
                      const Text('- Garis putus-putus = perceraian'),
                      const Text('- Garis sejajar = saudara kandung'),
                      const Text('- Garis vertikal = orang tua-anak'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Add family member form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tambah Anggota Keluarga',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          enabled: !_isReadOnly,
                          decoration: const InputDecoration(
                            labelText: 'Nama',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _ageController,
                                enabled: !_isReadOnly,
                                decoration: const InputDecoration(
                                  labelText: 'Usia',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: const InputDecoration(
                                  labelText: 'Jenis Kelamin',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'L',
                                    child: Text('♂ Laki-laki'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'P',
                                    child: Text('♀ Perempuan'),
                                  ),
                                ],
                                onChanged: _isReadOnly ? null : (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedGender = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: _selectedRelationship,
                                    decoration: const InputDecoration(
                                      labelText: 'Hubungan',
                                      helperText:
                                          'Contoh: Ayah, Ibu, Kakak, Adik',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Ayah',
                                        child: Text('Ayah'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Ibu',
                                        child: Text('Ibu'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Kakak',
                                        child: Text('Kakak'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Adik',
                                        child: Text('Adik'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Pasangan',
                                        child: Text('Pasangan'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Anak',
                                        child: Text('Anak'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'lainnya',
                                        child: Text('Lainnya'),
                                      ),
                                    ],
                                    onChanged: _isReadOnly ? null : (value) {
                                      setState(() {
                                        _selectedRelationship = value;
                                        _isOtherRelationship =
                                            value == 'lainnya';
                                      });
                                    },
                                    hint: const Text('Pilih Hubungan'),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_isOtherRelationship)
                                    TextFormField(
                                      controller: _otherRelationshipController,
                                      enabled: !_isReadOnly,
                                      decoration: const InputDecoration(
                                        labelText: 'Detail Hubungan lain',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'alive',
                                    child: Text('Hidup'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'deceased',
                                    child: Text('☠ Meninggal'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'pregnant',
                                    child: Text('○ Hamil'),
                                  ),
                                ],
                                onChanged: _isReadOnly ? null : (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedStatus = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isReadOnly ? null : _addFamilyMember,
                          child: const Text('Tambah Anggota'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Connections UI
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hubungan Antar Anggota',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (_familyMembers.length < 2)
                          const Text('Tambahkan minimal dua anggota untuk membuat hubungan.'),
                        if (_familyMembers.length >= 2) ...[
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _selectedFromMemberId,
                                  decoration: const InputDecoration(labelText: 'Dari', border: OutlineInputBorder()),
                                  items: _familyMembers.map((m) => DropdownMenuItem<int>(value: m['id'] as int, child: Text(m['name']))).toList(),
                                  onChanged: _isReadOnly ? null : (value) => setState(() { _selectedFromMemberId = value; }),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _selectedToMemberId,
                                  decoration: const InputDecoration(labelText: 'Ke', border: OutlineInputBorder()),
                                  items: _familyMembers.map((m) => DropdownMenuItem<int>(value: m['id'] as int, child: Text(m['name']))).toList(),
                                  onChanged: _isReadOnly ? null : (value) => setState(() { _selectedToMemberId = value; }),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedConnectionType,
                            decoration: const InputDecoration(labelText: 'Tipe Hubungan', border: OutlineInputBorder()),
                            items: _connectionTypes.map((ct) => DropdownMenuItem<String>(value: ct['id'], child: Text(ct['label']!))).toList(),
                            onChanged: _isReadOnly ? null : (v) => setState(() { _selectedConnectionType = v; }),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(onPressed: _isReadOnly ? null : _addConnection, child: const Text('Tambah Hubungan')),
                          const SizedBox(height: 8),
                          const Text('Daftar Hubungan:'),
                          const SizedBox(height: 8),
                          if (_connections.isEmpty) const Text('Belum ada hubungan.'),
                          if (_connections.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _connections.length,
                              itemBuilder: (context, idx) {
                                final conn = _connections[idx];
                                final fromName = _memberNameById(conn['from'] as int);
                                final toName = _memberNameById(conn['to'] as int);
                                final label = _connectionTypes.firstWhere((c) => c['id'] == conn['type'], orElse: () => {'label':'Hubungan'})['label'];
                                return ListTile(
                                  title: Text('$fromName → $toName'),
                                  subtitle: Text(label ?? ''),
                                  trailing: IconButton(onPressed: _isReadOnly ? null : () { _connections.removeAt(idx); setState(() {}); }, icon: const Icon(Icons.delete, color: Colors.red)),
                                );
                              },
                            ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Genogram visualization
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.38,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visualisasi Genogram',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_familyMembers.isEmpty)
                            const Center(
                              child: Text(
                                'Belum ada anggota keluarga. Tambahkan anggota untuk memulai.',
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: _familyMembers.length,
                                itemBuilder: (context, index) {
                                  final member = _familyMembers[index];
                                  String symbol = '';
                                  Color bgColor = Colors.blue;

                                  if (member['gender'] == 'L') {
                                    symbol = member['status'] == 'pregnant'
                                        ? '○♂'
                                        : '♂';
                                  } else {
                                    symbol = member['status'] == 'pregnant'
                                        ? '○♀'
                                        : '♀';
                                  }

                                  if (member['status'] == 'deceased') {
                                    bgColor = Colors.grey;
                                    symbol += ' ☠';
                                  }

                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: bgColor,
                                            child: Text(
                                              symbol,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        member['name'],
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    if (member['is_client'] == true)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.blueAccent,
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: const Text('Klien', style: TextStyle(color: Colors.white, fontSize: 12)),
                                                      ),
                                                  ],
                                                ),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 4,
                                                  children: [
                                                    Text('${member['age']} tahun'),
                                                    Tooltip(
                                                      message: member['relationship'] ?? '',
                                                      child: Chip(
                                                        backgroundColor: _relationshipColor(member['relationship'] ?? ''),
                                                        label: Text(
                                                          member['relationship'] ?? '',
                                                          style: const TextStyle(color: Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Builder(builder: (ctx) {
                                                  final connMap = _connectionsMap();
                                                  final myConns = connMap[member['id'] as int] ?? [];
                                                  if (myConns.isEmpty) return const SizedBox.shrink();
                                                  return Wrap(
                                                    spacing: 6,
                                                    children: myConns.map<Widget>((c) {
                                                      final otherId = (c['to'] ?? c['from']) as int;
                                                      final otherName = _memberNameById(otherId);
                                                      return Chip(
                                                        avatar: const Icon(Icons.link, size: 16, color: Colors.white),
                                                        label: Text('${c['type']}: $otherName', style: const TextStyle(color: Colors.white)),
                                                        backgroundColor: Colors.black54,
                                                      );
                                                    }).toList(),
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.grey),
                                                onPressed: _isReadOnly ? null : () => _showEditMemberDialog(index),
                                              ),
                                                IconButton(
                                                  icon: Icon(member['is_client'] == true ? Icons.star : Icons.star_border, color: Colors.amber),
                                                  onPressed: _isReadOnly ? null : () async {
                                                    // Set this member as client and unset others
                                                    for (int i = 0; i < _familyMembers.length; i++) {
                                                      _familyMembers[i]['is_client'] = (i == index);
                                                    }
                                                    setState(() {});
                                                  },
                                                ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: _isReadOnly
                                                    ? null
                                                    : () {
                                                        _familyMembers.removeAt(index);
                                                        setState(() {});
                                                      },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Notes input for parenting patterns, communication, decision making
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan Genogram',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText:
                                'Pola asuh, komunikasi, pengambilan keputusan',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
        floatingActionButton: _isReadOnly
          ? null
          : FloatingActionButton(
              onPressed: () {
      // Save genogram data and return (local validation first)
      if (!_validateBeforeSave()) return;
          Get.back(
            result: {
              'structure': {
                'members': _familyMembers,
                'connections': _connections,
              },
              'notes': _notesController.text,
            },
          );
        },
        child: const Icon(Icons.save),
      ),
    );
  }

    bool _validateBeforeSave() {
      if (_familyMembers.isEmpty) {
        Get.snackbar('Error', 'Harap tambahkan setidaknya satu anggota keluarga');
        return false;
      }
      // Ensure all connections point to existing members
      final ids = _familyMembers.map<int>((m) => m['id'] as int).toSet();
      for (final c in _connections) {
        final from = c['from'] as int;
        final to = c['to'] as int;
        if (!ids.contains(from) || !ids.contains(to)) {
          Get.snackbar('Error', 'Hubungan mengandung anggota yang tidak valid');
          return false;
        }
        if (from == to) {
          Get.snackbar('Error', 'Hubungan mengandung referensi ke anggota yang sama');
          return false;
        }
      }
      return true;
    }
}
