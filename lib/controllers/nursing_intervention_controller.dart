import 'package:get/get.dart';
import 'dart:convert';
import '../models/nursing_intervention_model.dart';
import '../services/nursing_intervention_service.dart';

class NursingInterventionController extends GetxController {
  final RxList<NursingIntervention> _interventions = <NursingIntervention>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<NursingIntervention> get interventions => _interventions;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchInterventions();
  }

  Future<void> fetchInterventions() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final response = await NursingInterventionService.getInterventions();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> interventionList = data as List<dynamic>;

        _interventions.value = interventionList
            .map((json) => NursingIntervention.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to fetch interventions';
      }
    } catch (e) {
      _errorMessage.value = 'Error fetching interventions: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createIntervention(String name, String? description) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final response = await NursingInterventionService.createIntervention({
        'name': name,
        'description': description,
      });

      if (response.statusCode == 201) {
        await fetchInterventions(); // Refresh the list
        Get.snackbar('Success', 'Intervention created successfully');
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to create intervention';
        Get.snackbar('Error', _errorMessage.value);
      }
    } catch (e) {
      _errorMessage.value = 'Error creating intervention: $e';
      Get.snackbar('Error', _errorMessage.value);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateIntervention(int id, String name, String? description) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final response = await NursingInterventionService.updateIntervention(id, {
        'name': name,
        'description': description,
      });

      if (response.statusCode == 200) {
        await fetchInterventions(); // Refresh the list
        Get.snackbar('Success', 'Intervention updated successfully');
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to update intervention';
        Get.snackbar('Error', _errorMessage.value);
      }
    } catch (e) {
      _errorMessage.value = 'Error updating intervention: $e';
      Get.snackbar('Error', _errorMessage.value);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteIntervention(int id) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final response = await NursingInterventionService.deleteIntervention(id);

      if (response.statusCode == 200) {
        await fetchInterventions(); // Refresh the list
        Get.snackbar('Success', 'Intervention deleted successfully');
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to delete intervention';
        Get.snackbar('Error', _errorMessage.value);
      }
    } catch (e) {
      _errorMessage.value = 'Error deleting intervention: $e';
      Get.snackbar('Error', _errorMessage.value);
    } finally {
      _isLoading.value = false;
    }
  }
}