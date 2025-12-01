import 'package:get/get.dart';
import 'package:graphview/GraphView.dart' hide Node;
import 'package:graphview/GraphView.dart' as graph;
import '../models/genogram_member.dart';
import '../services/logger_service.dart';

class GenogramController extends GetxController {
  final LoggerService _logger = LoggerService();
  
  final RxList<GenogramMember> members = <GenogramMember>[].obs;
  final RxList<GenogramRelationship> relationships = <GenogramRelationship>[].obs;
  final RxString selectedMemberId = ''.obs;
  
  final graph.Graph graphInstance = graph.Graph();
  final graph.BuchheimWalkerConfiguration builder = graph.BuchheimWalkerConfiguration();

  @override
  void onInit() {
    super.onInit();
    builder
      ..siblingSeparation = 200
      ..levelSeparation = 200
      ..subtreeSeparation = 200
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
    _logger.info('GenogramController initialized');
  }

  void loadInitialData(Map<String, dynamic>? structure) {
    if (structure == null) return;
    
    try {
      final membersList = structure['members'] as List?;
      final relationsList = structure['connections'] as List?;
      
      if (membersList != null) {
        members.value = membersList.map((m) => GenogramMember.fromJson(m)).toList();
      }
      
      if (relationsList != null) {
        relationships.value = relationsList.map((r) => GenogramRelationship.fromJson(r)).toList();
      }
      
      _refreshGraph();
    } catch (e) {
      _logger.error('Error loading genogram data', error: e);
    }
  }

  void addMember(String name, int age, Gender gender, LifeStatus status, [String? relationship, int generation = 0]) {
    final member = GenogramMember(
      name: name,
      age: age,
      gender: gender,
      status: status,
      relationship: relationship,
      generation: generation,
    );
    members.add(member);
    _refreshGraph();
    _logger.genogram(operation: 'add_member', metadata: {'name': name, 'generation': generation});
  }

  void deleteMember(String memberId) {
    members.removeWhere((m) => m.id == memberId);
    relationships.removeWhere((r) => r.fromId == memberId || r.toId == memberId);
    _refreshGraph();
    _logger.genogram(operation: 'delete_member', metadata: {'memberId': memberId});
  }

  void addRelationship(String fromId, String toId, RelType type) {
    final rel = GenogramRelationship(fromId: fromId, toId: toId, type: type);
    relationships.add(rel);
    _refreshGraph();
    _logger.genogram(operation: 'add_relationship', metadata: {'type': type.name});
  }

  void setAsClient(String memberId) {
    members.value = members.map((m) => m.copyWith(isClient: m.id == memberId)).toList();
    update(['graph_view']);
  }

  void _refreshGraph() {
    graphInstance.nodes.clear();
    graphInstance.edges.clear();
    
    // Add nodes
    for (var member in members) {
      graphInstance.addNode(graph.Node.Id(member.id));
    }
    
    // Add edges
    for (var rel in relationships) {
      final fromNode = graphInstance.getNodeUsingId(rel.fromId);
      final toNode = graphInstance.getNodeUsingId(rel.toId);
      if (fromNode != null && toNode != null) {
        graphInstance.addEdge(fromNode, toNode);
      }
    }
    
    update(['graph_view']);
  }

  Map<String, dynamic> getStructure() {
    return {
      'members': members.map((m) => m.toJson()).toList(),
      'connections': relationships.map((r) => r.toJson()).toList(),
    };
  }

  void saveGenogram() {
    final structure = getStructure();
    Get.back(result: {'structure': structure, 'notes': ''});
    _logger.genogram(operation: 'save', metadata: {'memberCount': members.length});
  }
}
