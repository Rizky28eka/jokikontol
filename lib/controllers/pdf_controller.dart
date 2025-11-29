import 'package:get/get.dart';
import 'dart:convert';
import '../services/pdf_service.dart';

class PdfController extends GetxController {
  final RxBool _isGenerating = false.obs;
  final RxString _errorMessage = ''.obs;

  bool get isGenerating => _isGenerating.value;
  String get errorMessage => _errorMessage.value;

  Future<String?> generatePdfForForm(int formId) async {
    _isGenerating.value = true;
    _errorMessage.value = '';

    try {
      final response = await PdfService.generatePdf(formId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url']; // Return the PDF URL
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to generate PDF';
        Get.snackbar('Error', _errorMessage.value);
        return null;
      }
    } catch (e) {
      _errorMessage.value = 'Error generating PDF: $e';
      Get.snackbar('Error', _errorMessage.value);
      return null;
    } finally {
      _isGenerating.value = false;
    }
  }
}