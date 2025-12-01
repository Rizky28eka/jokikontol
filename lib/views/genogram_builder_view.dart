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
      floatingActionButton: !isReadOnly ? FloatingActionButton(
        child: const Icon(Icons.person_add),
        onPressed: () => _showAddMemberDialog(context, controller),
      ) : null,
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
    Gender selectedGender = Gender.male;
    LifeStatus selectedStatus = LifeStatus.alive;

    Get.defaultDialog(
      title: "Tambah Anggota",
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
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
              DropdownButton<Gender>(
                value: selectedGender,
                isExpanded: true,
                items: Gender.values
                    .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                    .toList(),
                onChanged: (v) => setState(() => selectedGender = v!),
              ),
              DropdownButton<LifeStatus>(
                value: selectedStatus,
                isExpanded: true,
                items: LifeStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => setState(() => selectedStatus = v!),
              ),
            ],
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

    String? selectedTargetId = potentialTargets.first.id;
    RelType selectedType = RelType.parentChild;

    Get.defaultDialog(
      title: "Hubungkan Dengan...",
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              items: RelType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
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
