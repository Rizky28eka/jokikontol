import 'dart:convert';
import 'package:get/get.dart';
import '../models/nursing_diagnosis_model.dart';
import '../models/nursing_intervention_model.dart';
import '../services/nursing_data_service.dart';
import '../services/logger_service.dart';

class NursingDataGlobalService extends GetxService {
  static NursingDataGlobalService get to => Get.find();

  final LoggerService _logger = LoggerService();

  final RxList<NursingDiagnosis> _diagnoses = <NursingDiagnosis>[].obs;
  final RxList<NursingIntervention> _interventions = <NursingIntervention>[].obs;
  final RxBool _isLoading = false.obs;

  List<NursingDiagnosis> get diagnoses => _diagnoses;
  List<NursingIntervention> get interventions => _interventions;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadNursingData();
  }

  Future<void> loadNursingData() async {
    _isLoading.value = true;
    
    try {
      // Load diagnoses
      final diagnosesResponse = await NursingDataService.getDiagnoses();
      if (diagnosesResponse.statusCode == 200) {
        final data = json.decode(diagnosesResponse.body);
        final List<dynamic> diagnosisList = data as List<dynamic>;
        _diagnoses.assignAll(
          diagnosisList
          .map((json) => NursingDiagnosis.fromJson(json as Map<String, dynamic>))
          .toList()
        );
      }

      // Load interventions
      final interventionsResponse = await NursingDataService.getInterventions();
      if (interventionsResponse.statusCode == 200) {
        final data = json.decode(interventionsResponse.body);
        final List<dynamic> interventionList = data as List<dynamic>;
        _interventions.assignAll(
          interventionList
          .map((json) => NursingIntervention.fromJson(json as Map<String, dynamic>))
          .toList()
        );
      }
    } catch (e) {
      _logger.error('Error loading nursing data', error: e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Function to refresh nursing data
  Future<void> refreshNursingData() async {
    await loadNursingData();
  }
}