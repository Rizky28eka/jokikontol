import 'mappers/pengkajian_mapper.dart';
import 'mappers/resume_kegawatdaruratan_mapper.dart';
import 'mappers/resume_poliklinik_mapper.dart';
import 'mappers/sap_mapper.dart';
import 'mappers/catatan_tambahan_mapper.dart';
import 'mappers/pengkajian_reverse_mapper.dart';
import 'mappers/resume_kegawatdaruratan_reverse_mapper.dart';
import 'mappers/resume_poliklinik_reverse_mapper.dart';
import 'mappers/sap_reverse_mapper.dart';
import 'mappers/catatan_tambahan_reverse_mapper.dart';

/// Helper class to map form data to new structured format
class FormDataMapper {
  /// Convert old JSON data format to new structured format for API submission
  static Map<String, dynamic> mapToApiFormat(
    String formType,
    Map<String, dynamic> formData,
  ) {
    final flattenedData = _flattenSections(formData);

    return {
      'type': formType,
      'patient_id': flattenedData['patient_id'],
      'status': flattenedData['status'] ?? 'draft',
      'data': _extractFormFields(formType, flattenedData),
    };
  }

  /// Convert API response data back to form's expected structure (reverse mapping)
  static Map<String, dynamic> mapFromApiFormat(
    String formType,
    Map<String, dynamic> apiData,
  ) {
    switch (formType) {
      case 'sap':
        return SapReverseMapper.reverse(apiData);
      case 'resume_poliklinik':
        return ResumePoliklinikReverseMapper.reverse(apiData);
      case 'resume_kegawatdaruratan':
        return ResumeKegawatdaruratanReverseMapper.reverse(apiData);
      case 'catatan_tambahan':
        return CatatanTambahanReverseMapper.reverse(apiData);
      case 'pengkajian':
        return PengkajianReverseMapper.reverse(apiData);
      default:
        return apiData;
    }
  }

  /// Flatten section_1, section_2, etc into single level
  static Map<String, dynamic> _flattenSections(Map<String, dynamic> data) {
    final result = <String, dynamic>{};

    for (var entry in data.entries) {
      if (entry.key.startsWith('section_') && entry.value is Map) {
        result.addAll(Map<String, dynamic>.from(entry.value));
      } else {
        result[entry.key] = entry.value;
      }
    }

    return result;
  }

  /// Extract form-specific fields from formData
  static Map<String, dynamic> _extractFormFields(
    String formType,
    Map<String, dynamic> formData,
  ) {
    switch (formType) {
      case 'pengkajian':
        return PengkajianMapper.map(formData);
      case 'resume_kegawatdaruratan':
        return ResumeKegawatdaruratanMapper.map(formData);
      case 'resume_poliklinik':
        return ResumePoliklinikMapper.map(formData);
      case 'sap':
        return SapMapper.map(formData);
      case 'catatan_tambahan':
        return CatatanTambahanMapper.map(formData);
      default:
        return formData;
    }
  }
}
