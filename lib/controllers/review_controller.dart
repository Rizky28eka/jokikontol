import 'package:get/get.dart';
import 'dart:convert';
import '../models/form_model.dart';
import '../services/review_service.dart';
import '../services/logger_service.dart';
import '../constants/api_config.dart';

class ReviewController extends GetxController {
  final RxList<FormModel> _submittedForms = <FormModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final LoggerService _logger = LoggerService();

  List<FormModel> get submittedForms => _submittedForms;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    _logger.info('ReviewController initialized');
    fetchSubmittedForms();
  }

  Future<void> fetchSubmittedForms() async {
    _logger.debug('Fetching submitted forms for review');
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final response = await ReviewService.getSubmittedForms();

      _logger.network(
        method: 'GET',
        url: '${ApiConfig.currentBaseUrl}/forms/submitted',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> formList = data['data'] as List<dynamic>; // Extract data from paginated response

        _submittedForms.value = formList
            .map((json) => FormModel.fromJson(json as Map<String, dynamic>))
            .toList();

        _logger.info('Successfully fetched submitted forms', context: {'count': _submittedForms.length});
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to fetch submitted forms';
        _logger.error('Failed to fetch submitted forms', context: {'statusCode': response.statusCode, 'message': _errorMessage.value});
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error fetching submitted forms: $e';
      _logger.error('Error fetching submitted forms', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> reviewForm(int formId, String status, String? comment) async {
    _logger.info('Reviewing form', context: {'formId': formId, 'status': status, 'comment': comment ?? 'No comment'});
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final response = await ReviewService.reviewForm(formId, status, comment);

      _logger.network(
        method: 'POST',
        url: '${ApiConfig.currentBaseUrl}/forms/$formId/review',
        statusCode: response.statusCode,
        requestBody: {'status': status, 'comment': comment},
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        _logger.info('Form reviewed successfully', context: {'formId': formId, 'status': status});
        await fetchSubmittedForms(); // Refresh the list after review
        Get.snackbar('Success', 'Form reviewed successfully');
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to review form';
        _logger.error('Failed to review form', context: {'formId': formId, 'status': status, 'message': _errorMessage.value});
        Get.snackbar('Error', _errorMessage.value);
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error reviewing form: $e';
      _logger.error('Error reviewing form', error: e, stackTrace: stackTrace, context: {'formId': formId, 'status': status});
      Get.snackbar('Error', _errorMessage.value);
    } finally {
      _isLoading.value = false;
    }
  }
}