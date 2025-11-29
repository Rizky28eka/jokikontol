import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GenogramBuilderView extends StatefulWidget {
  const GenogramBuilderView({super.key});

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
  final TextEditingController _notesController = TextEditingController();
  
  String _selectedGender = 'L';
  String _selectedStatus = 'alive';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _relationshipController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addFamilyMember() {
    if (_nameController.text.isEmpty) {
      Get.snackbar('Error', 'Nama harus diisi');
      return;
    }
    
    final member = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': _nameController.text,
      'age': int.tryParse(_ageController.text) ?? 0,
      'gender': _selectedGender,
      'status': _selectedStatus, // alive, deceased, pregnant
      'relationship': _relationshipController.text,
    };
    
    _familyMembers.add(member);
    setState(() {});
    
    // Clear the form
    _nameController.clear();
    _ageController.clear();
    _relationshipController.clear();
    _selectedGender = 'L';
    _selectedStatus = 'alive';
    
    Get.snackbar('Success', 'Anggota keluarga ditambahkan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Genogram Builder'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                  Row(
                    children: [
                      const Text('♂ - Laki-laki, '),
                      const Text('♀ - Perempuan, '),
                      const Text('☠ - Meninggal, '),
                      Text('○ - Hamil, ', style: TextStyle(fontSize: 20)),
                      const Text('Klien - Individu utama'),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
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
                              DropdownMenuItem(value: 'L', child: Text('♂ Laki-laki')),
                              DropdownMenuItem(value: 'P', child: Text('♀ Perempuan')),
                            ],
                            onChanged: (value) {
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
                          child: TextFormField(
                            controller: _relationshipController,
                            decoration: const InputDecoration(
                              labelText: 'Hubungan',
                              helperText: 'Contoh: Ayah, Ibu, Kakak, Adik',
                              border: OutlineInputBorder(),
                            ),
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
                              DropdownMenuItem(value: 'alive', child: Text('Hidup')),
                              DropdownMenuItem(value: 'deceased', child: Text('☠ Meninggal')),
                              DropdownMenuItem(value: 'pregnant', child: Text('○ Hamil')),
                            ],
                            onChanged: (value) {
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
                      onPressed: _addFamilyMember,
                      child: const Text('Tambah Anggota'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Genogram visualization
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Visualisasi Genogram',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (_familyMembers.isEmpty)
                        const Center(
                          child: Text('Belum ada anggota keluarga. Tambahkan anggota untuk memulai.'),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: _familyMembers.length,
                            itemBuilder: (context, index) {
                              final member = _familyMembers[index];
                              String symbol = '';
                              Color bgColor = Colors.blue;
                              
                              if (member['gender'] == 'L') {
                                symbol = member['status'] == 'pregnant' ? '○♂' : '♂';
                              } else {
                                symbol = member['status'] == 'pregnant' ? '○♀' : '♀';
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
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              member['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${member['age']} tahun, ${member['relationship']}',
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          _familyMembers.removeAt(index);
                                          setState(() {});
                                        },
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Pola asuh, komunikasi, pengambilan keputusan',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Save genogram data and return
          Get.back(result: {
            'structure': {
              'members': _familyMembers,
              'connections': _connections,
            },
            'notes': _notesController.text,
          });
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}