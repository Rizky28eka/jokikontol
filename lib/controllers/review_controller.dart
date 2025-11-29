import 'package:get/get.dart';
import 'dart:convert';
import '../models/form_model.dart';
import '../services/review_service.dart';

class ReviewController extends GetxController {
  final RxList<FormModel> _submittedForms = <FormModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<FormModel> get submittedForms => _submittedForms;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchSubmittedForms();
  }

  Future<void> fetchSubmittedForms() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final response = await ReviewService.getSubmittedForms();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> formList = data['data'] as List<dynamic>; // Extract data from paginated response

        _submittedForms.value = formList
            .map((json) => FormModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to fetch submitted forms';
      }
    } catch (e) {
      _errorMessage.value = 'Error fetching submitted forms: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> reviewForm(int formId, String status, String? comment) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final response = await ReviewService.reviewForm(formId, status, comment);

      if (response.statusCode == 200) {
        await fetchSubmittedForms(); // Refresh the list after review
        Get.snackbar('Success', 'Form reviewed successfully');
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to review form';
        Get.snackbar('Error', _errorMessage.value);
      }
    } catch (e) {
      _errorMessage.value = 'Error reviewing form: $e';
      Get.snackbar('Error', _errorMessage.value);
    } finally {
      _isLoading.value = false;
    }
  }
}