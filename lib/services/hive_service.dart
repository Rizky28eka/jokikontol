import 'package:hive_flutter/hive_flutter.dart';
import '../services/logger_service.dart';

class HiveService {
  static final LoggerService _logger = LoggerService();

  static Future<void> init() async {
    await Hive.initFlutter();
    _logger.database(operation: 'init', table: 'Hive');
    // Register adapters if needed (for custom objects)
  }
}
