import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphview/GraphView.dart' hide Node;
import '../controllers/genogram_controller.dart';
import '../models/genogram_member.dart';
import '../widgets/genogram_node_widget.dart';
import 'package:graphview/GraphView.dart' as graph;

class GenogramBuilderView extends StatelessWidget {
  final Map<String, dynamic>? initialData;

  const GenogramBuilderView({super.key, this.initialData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GenogramController());

    // Load initial data if provided
    final args = Get.arguments as Map<String, dynamic>?;
    final dataToLoad = initialData ?? args;
    final bool isReadOnly = args?['readOnly'] == true;

    if (dataToLoad != null && dataToLoad['structure'] != null) {
      controller.loadInitialData(dataToLoad['structure']);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Genogram Builder"),
        actions: [
          if (!isReadOnly)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: controller.saveGenogram,
            ),
        ],
      ),
      floatingActionButton: !isReadOnly
          ? FloatingActionButton(
              child: const Icon(Icons.person_add),
              onPressed: () => _showAddMemberDialog(context, controller),
            )
          : null,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: const Text("Tips: Cubit layar untuk zoom, geser untuk pan."),
          ),
          Expanded(
            child: GetBuilder<GenogramController>(
              id: 'graph_view',
              builder: (ctrl) {
                if (ctrl.members.isEmpty) {
                  return const Center(
                    child: Text("Belum ada data. Tambah anggota keluarga."),
                  );
                }

                return InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.1,
                  maxScale: 5.0,
                  child: GraphView(
                    graph: ctrl.graphInstance,
                    algorithm: BuchheimWalkerAlgorithm(
                      ctrl.builder,
                      TreeEdgeRenderer(ctrl.builder),
                    ),
                    paint: Paint()
                      ..color = Colors.black
                      ..strokeWidth = 1.5
                      ..style = PaintingStyle.stroke,
                    builder: (graph.Node node) {
                      var memberId = node.key!.value as String;
                      var member = ctrl.members.firstWhere(
                        (m) => m.id == memberId,
                      );

                      return GenogramNodeWidget(
                        member: member,
                        isSelected: ctrl.selectedMemberId.value == memberId,
                        onTap: () {
                          if (!isReadOnly) {
                            ctrl.selectedMemberId.value = memberId;
                            _showNodeOptions(context, controller, memberId);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(
    BuildContext context,
    GenogramController controller,
  ) {
    final nameC = TextEditingController();
    final ageC = TextEditingController();
    String? selectedRelation;
    Gender selectedGender = Gender.male;
    LifeStatus selectedStatus = LifeStatus.alive;
    int selectedGeneration = 0;

    Get.defaultDialog(
      title: "Tambah Anggota",
      content: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC,
                  decoration: const InputDecoration(labelText: "Nama"),
                ),
                TextField(
                  controller: ageC,
                  decoration: const InputDecoration(labelText: "Usia"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedRelation,
                  isExpanded: true,
                  hint: const Text('Pilih Hubungan'),
                  items: const [
                    DropdownMenuItem(value: 'Ayah', child: Text('Ayah')),
                    DropdownMenuItem(value: 'Ibu', child: Text('Ibu')),
                    DropdownMenuItem(value: 'Kakek', child: Text('Kakek')),
                    DropdownMenuItem(value: 'Nenek', child: Text('Nenek')),
                    DropdownMenuItem(value: 'Suami', child: Text('Suami')),
                    DropdownMenuItem(value: 'Istri', child: Text('Istri')),
                    DropdownMenuItem(value: 'Kakak', child: Text('Kakak')),
                    DropdownMenuItem(value: 'Adik', child: Text('Adik')),
                    DropdownMenuItem(value: 'Anak', child: Text('Anak')),
                    DropdownMenuItem(value: 'Cucu', child: Text('Cucu')),
                    DropdownMenuItem(value: 'Paman', child: Text('Paman')),
                    DropdownMenuItem(value: 'Bibi', child: Text('Bibi')),
                    DropdownMenuItem(value: 'Keponakan', child: Text('Keponakan')),
                  ],
                  onChanged: (v) => setState(() => selectedRelation = v),
                ),
                const SizedBox(height: 10),
                DropdownButton<Gender>(
                  value: selectedGender,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: Gender.male, child: Text('Laki-laki')),
                    DropdownMenuItem(value: Gender.female, child: Text('Perempuan')),
                    DropdownMenuItem(value: Gender.other, child: Text('Lainnya')),
                  ],
                  onChanged: (v) => setState(() => selectedGender = v!),
                ),
                DropdownButton<LifeStatus>(
                  value: selectedStatus,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: LifeStatus.alive, child: Text('Hidup')),
                    DropdownMenuItem(value: LifeStatus.deceased, child: Text('Meninggal')),
                    DropdownMenuItem(value: LifeStatus.unknown, child: Text('Tidak Diketahui')),
                  ],
                  onChanged: (v) => setState(() => selectedStatus = v!),
                ),
                DropdownButton<int>(
                  value: selectedGeneration,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: -2, child: Text('Kakek/Nenek')),
                    DropdownMenuItem(value: -1, child: Text('Orang Tua')),
                    DropdownMenuItem(value: 0, child: Text('Klien/Saudara')),
                    DropdownMenuItem(value: 1, child: Text('Anak')),
                    DropdownMenuItem(value: 2, child: Text('Cucu')),
                  ],
                  onChanged: (v) => setState(() => selectedGeneration = v!),
                ),
              ],
            ),
          );
        },
      ),
      textConfirm: "Simpan",
      onConfirm: () {
        if (nameC.text.isEmpty) return;
        controller.addMember(
          nameC.text,
          int.tryParse(ageC.text) ?? 0,
          selectedGender,
          selectedStatus,
          selectedRelation,
          selectedGeneration,
        );
        Get.back();
      },
    );
  }

  void _showNodeOptions(
    BuildContext context,
    GenogramController controller,
    String memberId,
  ) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Buat Hubungan'),
              onTap: () {
                Get.back();
                _showAddRelationDialog(context, controller, memberId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Jadikan Pasien Utama (Klien)'),
              onTap: () {
                controller.setAsClient(memberId);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Hapus Anggota',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                controller.deleteMember(memberId);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRelationDialog(
    BuildContext context,
    GenogramController ctrl,
    String fromId,
  ) {
    final potentialTargets = ctrl.members.where((m) => m.id != fromId).toList();
    if (potentialTargets.isEmpty) {
      Get.snackbar("Info", "Butuh minimal 2 orang untuk membuat hubungan");
      return;
    }

    final fromMember = ctrl.members.firstWhere((m) => m.id == fromId);
    String? selectedTargetId = potentialTargets.first.id;
    RelType selectedType = RelType.parentChild;

    Get.defaultDialog(
      title: "Hubungkan Dengan...",
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  const Text('Dari: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(fromMember.name, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ke:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedTargetId,
              isExpanded: true,
              items: potentialTargets
                  .map(
                    (m) => DropdownMenuItem(value: m.id, child: Text(m.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedTargetId = v),
            ),
            const SizedBox(height: 10),
            const Text("Tipe Hubungan:"),
            DropdownButton<RelType>(
              value: selectedType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: RelType.parentChild, child: Text('Orang Tua - Anak')),
                DropdownMenuItem(value: RelType.marriage, child: Text('Menikah')),
                DropdownMenuItem(value: RelType.divorced, child: Text('Cerai')),
                DropdownMenuItem(value: RelType.separated, child: Text('Pisah')),
                DropdownMenuItem(value: RelType.sibling, child: Text('Saudara Kandung')),
                DropdownMenuItem(value: RelType.twin, child: Text('Kembar')),
                DropdownMenuItem(value: RelType.adopted, child: Text('Adopsi')),
                DropdownMenuItem(value: RelType.foster, child: Text('Anak Asuh')),
                DropdownMenuItem(value: RelType.other, child: Text('Lainnya')),
              ],
              onChanged: (v) => setState(() => selectedType = v!),
            ),
          ],
        ),
      ),
      textConfirm: "Hubungkan",
      onConfirm: () {
        if (selectedTargetId != null) {
          ctrl.addRelationship(fromId, selectedTargetId!, selectedType);
          Get.back();
        }
      },
    );
  }
}
