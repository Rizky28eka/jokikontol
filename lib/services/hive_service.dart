import 'package:hive_flutter/hive_flutter.dart';
import '../models/form_model.dart';
import '../services/logger_service.dart';

class HiveService {
  static const String draftFormsBox = 'draft_forms';
  static final LoggerService _logger = LoggerService();

  static Future<void> init() async {
    await Hive.initFlutter();
    _logger.database(operation: 'init', table: 'Hive');
    // Register adapters if needed (for custom objects)
  }

  static String _getDraftKey(String type, int patientId) {
    return '${type}_$patientId';
  }

  static Future<void> saveDraftForm(FormModel form) async {
    try {
      final box = await Hive.openBox<dynamic>(draftFormsBox);
      await box.put(_getDraftKey(form.type, form.patientId), form.toJson());
      _logger.database(
        operation: 'saveDraftForm',
        table: draftFormsBox,
        recordId: _getDraftKey(form.type, form.patientId),
        data: {'type': form.type, 'patientId': form.patientId},
      );
    } catch (e) {
      _logger.database(
        operation: 'saveDraftForm',
        table: draftFormsBox,
        error: e,
      );
      rethrow;
    }
  }

  static Future<FormModel?> getDraftForm(String type, int patientId) async {
    try {
      final box = await Hive.openBox<dynamic>(draftFormsBox);
      final json = box.get(_getDraftKey(type, patientId));

      _logger.database(
        operation: 'getDraftForm',
        table: draftFormsBox,
        recordId: _getDraftKey(type, patientId),
        data: {'found': json != null},
      );

      if (json != null) {
        return FormModel.fromJson(Map<String, dynamic>.from(json));
      }
      return null;
    } catch (e) {
      _logger.database(
        operation: 'getDraftForm',
        table: draftFormsBox,
        error: e,
      );
      rethrow;
    }
  }

  static Future<List<FormModel>> getDraftForms() async {
    try {
      final box = await Hive.openBox<dynamic>(draftFormsBox);
      final values = box.values.toList();

      _logger.database(
        operation: 'getDraftForms',
        table: draftFormsBox,
        data: {'count': values.length},
      );

      return values
          .map((json) => FormModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      _logger.database(
        operation: 'getDraftForms',
        table: draftFormsBox,
        error: e,
      );
      rethrow;
    }
  }

  static Future<void> deleteDraftForm(String type, int patientId) async {
    try {
      final box = await Hive.openBox<dynamic>(draftFormsBox);
      await box.delete(_getDraftKey(type, patientId));

      _logger.database(
        operation: 'deleteDraftForm',
        table: draftFormsBox,
        recordId: _getDraftKey(type, patientId),
      );
    } catch (e) {
      _logger.database(
        operation: 'deleteDraftForm',
        table: draftFormsBox,
        error: e,
      );
      rethrow;
    }
  }

  static Future<void> clearDraftForms() async {
    try {
      final box = await Hive.openBox<dynamic>(draftFormsBox);
      await box.clear();

      _logger.database(operation: 'clearDraftForms', table: draftFormsBox);
    } catch (e) {
      _logger.database(
        operation: 'clearDraftForms',
        table: draftFormsBox,
        error: e,
      );
      rethrow;
    }
  }
}
