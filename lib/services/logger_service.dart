import 'package:logger/logger.dart' as external_logger;

/// Enhanced Logger Service with modern architecture and comprehensive logging capabilities
///
/// Provides a centralized logging solution with structured logging, context management,
/// and environment-aware configuration.
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  external_logger.Logger? _logger;
  LogConfig _config = LogConfig();

  /// Gets or creates the logger instance
  external_logger.Logger get logger => _logger ??= _createLogger();

  /// Initialize the logger service
  void init() {
    // Initialization logic can be added here if needed
    // For now, just ensure the logger is properly configured
    _logger ??= _createLogger();
  }

  /// Configure the logger with custom settings
  void configure(LogConfig config) {
    _config = config;
    _logger = _createLogger();
  }

  /// Creates a configured logger instance
  external_logger.Logger _createLogger() {
    return external_logger.Logger(
      filter: _config.filter ?? external_logger.ProductionFilter(),
      printer: external_logger.PrettyPrinter(
        methodCount: _config.methodCount,
        errorMethodCount: _config.errorMethodCount,
        lineLength: _config.lineLength,
        colors: _config.enableColors,
        printEmojis: _config.enableEmojis,
        dateTimeFormat: _config.dateTimeFormat ?? (dateTime) => dateTime.toIso8601String(),
      ),
      output: _config.output,
    );
  }

  // ============================================================================
  // CORE LOGGING METHODS
  // ============================================================================

  /// Log a message with specified level and optional context
  void log(
    String message, {
    external_logger.Level level = external_logger.Level.info,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? page,
  }) {
    final enrichedContext = <String, dynamic>{};
    if (context != null) {
      enrichedContext.addAll(context);
    }
    if (page != null) {
      enrichedContext['page'] = page;
    }
    
    final enrichedMessage = _enrichMessage(message, enrichedContext);

    switch (level) {
      case external_logger.Level.trace:
        logger.t(enrichedMessage, error: error, stackTrace: stackTrace);
      case external_logger.Level.debug:
        logger.d(enrichedMessage, error: error, stackTrace: stackTrace);
      case external_logger.Level.info:
        logger.i(enrichedMessage, error: error, stackTrace: stackTrace);
      case external_logger.Level.warning:
        logger.w(enrichedMessage, error: error, stackTrace: stackTrace);
      case external_logger.Level.error:
        logger.e(enrichedMessage, error: error, stackTrace: stackTrace);
      case external_logger.Level.fatal:
        logger.f(enrichedMessage, error: error, stackTrace: stackTrace);
      default:
        logger.i(enrichedMessage, error: error, stackTrace: stackTrace);
    }
  }

  /// Log trace level message - for detailed diagnostic information
  void trace(String message, {Map<String, dynamic>? context}) =>
      log(message, level: external_logger.Level.trace, context: context);

  /// Log debug level message - for debugging information
  void debug(String message, {Map<String, dynamic>? context}) =>
      log(message, level: external_logger.Level.debug, context: context);

  /// Log info level message - for general information
  void info(String message, {Map<String, dynamic>? context}) =>
      log(message, level: external_logger.Level.info, context: context);

  /// Log warning level message - for potentially harmful situations
  void warning(String message, {Map<String, dynamic>? context}) =>
      log(message, level: external_logger.Level.warning, context: context);

  /// Log error level message - for error events
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? page,
  }) => log(
    message,
    level: external_logger.Level.error,
    error: error,
    stackTrace: stackTrace,
    context: context,
    page: page,
  );

  /// Log fatal level message - for very severe error events
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) => log(
    message,
    level: external_logger.Level.fatal,
    error: error,
    stackTrace: stackTrace,
    context: context,
  );

  // ============================================================================
  // DOMAIN-SPECIFIC LOGGING METHODS
  // ============================================================================

  /// Log HTTP/Network operations
  void network({
    required String method,
    required String url,
    int? statusCode,
    Duration? duration,
    Object? requestBody,
    Object? responseBody,
    Map<String, String>? headers,
    Object? error,
  }) {
    final context = <String, dynamic>{
      'method': method,
      'url': url,
      if (statusCode != null) 'statusCode': statusCode,
      if (duration != null) 'duration': '${duration.inMilliseconds}ms',
      if (requestBody != null) 'requestBody': requestBody,
      if (responseBody != null) 'responseBody': responseBody,
      if (headers != null) 'headers': headers,
    };

    final level = _getNetworkLogLevel(statusCode);
    final status = statusCode != null ? '[$statusCode]' : '';
    final time = duration != null ? '(${duration.inMilliseconds}ms)' : '';

    log(
      'HTTP $method $url $status $time',
      level: level,
      error: error,
      context: context,
    );
  }

  /// Log user actions and interactions
  void userAction({
    required String action,
    String? userId,
    String? userName,
    Map<String, dynamic>? metadata,
  }) {
    log(
      'User Action: $action',
      context: {
        'action': action,
        if (userId != null) 'userId': userId,
        if (userName != null) 'userName': userName,
        if (metadata != null) ...metadata,
      },
    );
  }

  /// Log database operations
  void database({
    required String operation,
    required String table,
    String? recordId,
    Object? data,
    Duration? duration,
    Object? error,
  }) {
    log(
      'Database: $operation on $table',
      level: error != null
          ? external_logger.Level.error
          : external_logger.Level.debug,
      error: error,
      context: {
        'operation': operation,
        'table': table,
        if (recordId != null) 'recordId': recordId,
        if (data != null) 'data': data,
        if (duration != null) 'duration': '${duration.inMilliseconds}ms',
      },
    );
  }

  /// Log authentication events
  void auth({
    required String event,
    String? userId,
    String? userEmail,
    bool success = true,
    String? errorMessage,
  }) {
    log(
      'Auth: $event ${success ? "✓" : "✗"}',
      level: success
          ? external_logger.Level.info
          : external_logger.Level.warning,
      context: {
        'event': event,
        'success': success,
        if (userId != null) 'userId': userId,
        if (userEmail != null) 'userEmail': userEmail,
        if (errorMessage != null) 'error': errorMessage,
      },
    );
  }

  /// Log navigation events
  void navigation({required String from, required String to, Map<String, dynamic>? arguments, Map<String, dynamic>? params}) {
    debug(
      'Navigation: $from → $to',
      context: {
        'from': from,
        'to': to,
        if (arguments != null) 'arguments': arguments,
        if (params != null && arguments == null) 'arguments': params, // fallback to params if arguments is null
      },
    );
  }

  /// Log patient-related operations
  void patient({
    required String operation,
    String? patientId,
    String? patientName,
    String? userId,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    info(
      'Patient: $operation',
      context: {
        'operation': operation,
        if (patientId != null) 'patientId': patientId,
        if (patientName != null) 'patientName': patientName,
        if (userId != null) 'userId': userId,
        if (metadata != null) ...metadata,
        if (error != null) 'error': error,
        if (stackTrace != null) 'stackTrace': stackTrace,
      },
    );
  }

  /// Log form operations
  void form({
    required String operation,
    required String formType,
    String? formId,
    String? patientId,
    String? status,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    info(
      'Form: $operation - $formType',
      context: {
        'operation': operation,
        'formType': formType,
        if (formId != null) 'formId': formId,
        if (patientId != null) 'patientId': patientId,
        if (status != null) 'status': status,
        if (data != null) 'data': data,
        if (metadata != null) ...metadata,
        if (error != null) 'error': error,
        if (stackTrace != null) 'stackTrace': stackTrace,
      },
    );
  }

  /// Log genogram operations
  void genogram({
    required String operation,
    String? genogramId,
    String? patientId,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    info(
      'Genogram: $operation',
      context: {
        'operation': operation,
        if (genogramId != null) 'genogramId': genogramId,
        if (patientId != null) 'patientId': patientId,
        if (userId != null) 'userId': userId,
        if (metadata != null) ...metadata,
      },
    );
  }

  /// Log file operations
  void file({
    required String operation,
    required String fileName,
    String? filePath,
    int? fileSize,
    Object? error,
  }) {
    log(
      'File: $operation - $fileName',
      level: error != null
          ? external_logger.Level.error
          : external_logger.Level.debug,
      error: error,
      context: {
        'operation': operation,
        'fileName': fileName,
        if (filePath != null) 'filePath': filePath,
        if (fileSize != null)
          'fileSize': '${(fileSize / 1024).toStringAsFixed(2)} KB',
      },
    );
  }

  /// Log permission requests
  void permission({
    required String permission,
    required String status,
    String? rationale,
  }) {
    info(
      'Permission: $permission - $status',
      context: {
        'permission': permission,
        'status': status,
        if (rationale != null) 'rationale': rationale,
      },
    );
  }

  /// Log UI interactions
  void ui({
    required String widget,
    required String action,
    Map<String, dynamic>? metadata,
  }) {
    trace(
      'UI: $widget - $action',
      context: {
        'widget': widget,
        'action': action,
        if (metadata != null) ...metadata,
      },
    );
  }

  /// Log user interaction events
  void userInteraction(String action, {String? page, String? element, Map<String, dynamic>? data}) {
    log(
      'User Interaction: $action',
      context: {
        'action': action,
        if (page != null) 'page': page,
        if (element != null) 'element': element,
        if (data != null) ...data,
      },
    );
  }

  /// Log API call events
  void apiCall({String? url, String? method, Object? requestBody, Object? responseData, int? statusCode, Duration? duration, Object? requestData, int? durationMs}) {
    network(
      method: method ?? 'API',
      url: url ?? 'unknown',
      statusCode: statusCode,
      duration: duration ?? (durationMs != null ? Duration(milliseconds: durationMs) : null),
      requestBody: requestBody ?? requestData,
      responseBody: responseData,
    );
  }

  /// Log authentication events
  void authEvent(String event, {String? page, String? userId, String? userEmail, bool? success, String? errorMessage}) {
    auth(
      event: event,
      userId: userId,
      userEmail: userEmail,
      success: success ?? true,
      errorMessage: errorMessage,
    );
  }

  // ============================================================================
  // PERFORMANCE LOGGING
  // ============================================================================

  /// Log performance metrics
  void performance({
    required String operation,
    required Duration duration,
    Map<String, dynamic>? metrics,
  }) {
    final level = duration.inMilliseconds > 1000
        ? external_logger.Level.warning
        : external_logger.Level.debug;

    log(
      'Performance: $operation took ${duration.inMilliseconds}ms',
      level: level,
      context: {
        'operation': operation,
        'duration': '${duration.inMilliseconds}ms',
        if (metrics != null) ...metrics,
      },
    );
  }

  /// Measure and log execution time of a function
  Future<T> measure<T>({
    required String operation,
    required Future<T> Function() function,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await function();
      stopwatch.stop();
      performance(operation: operation, duration: stopwatch.elapsed);
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      error(
        'Error in $operation after ${stopwatch.elapsedMilliseconds}ms',
        error: e,
        stackTrace: stackTrace,
        context: {'operation': operation},
      );
      rethrow;
    }
  }

  // ============================================================================
  // LIFECYCLE LOGGING
  // ============================================================================

  /// Log application startup
  void appStartup({String? version, String? environment}) {
    info(
      '🚀 Application Started',
      context: {
        'timestamp': DateTime.now().toIso8601String(),
        if (version != null) 'version': version,
        if (environment != null) 'environment': environment,
      },
    );
  }

  /// Log application shutdown
  void appShutdown({String? reason}) {
    info(
      '👋 Application Shutdown',
      context: {
        'timestamp': DateTime.now().toIso8601String(),
        if (reason != null) 'reason': reason,
      },
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Enrich message with context information
  String _enrichMessage(String message, Map<String, dynamic>? context) {
    if (context == null || context.isEmpty) return message;

    final contextStr = context.entries
        .map((e) => '${e.key}=${e.value}')
        .join(', ');

    return '$message | $contextStr';
  }

  /// Determine log level based on HTTP status code
  external_logger.Level _getNetworkLogLevel(int? statusCode) {
    if (statusCode == null) return external_logger.Level.debug;

    if (statusCode >= 200 && statusCode < 300) {
      return external_logger.Level.info;
    } else if (statusCode >= 300 && statusCode < 400) {
      return external_logger.Level.debug;
    } else if (statusCode >= 400 && statusCode < 500) {
      return external_logger.Level.warning;
    } else {
      return external_logger.Level.error;
    }
  }
}

/// Configuration class for LoggerService
class LogConfig {
  final int methodCount;
  final int errorMethodCount;
  final int lineLength;
  final bool enableColors;
  final bool enableEmojis;
  final external_logger.DateTimeFormatter? dateTimeFormat;
  final external_logger.LogFilter? filter;
  final external_logger.LogOutput? output;

  LogConfig({
    this.methodCount = 2,
    this.errorMethodCount = 8,
    this.lineLength = 120,
    this.enableColors = true,
    this.enableEmojis = true,
    this.dateTimeFormat,
    this.filter,
    this.output,
  });

  /// Development configuration
  factory LogConfig.development() => LogConfig(
    methodCount: 3,
    errorMethodCount: 10,
    enableColors: true,
    enableEmojis: true,
    dateTimeFormat: (dateTime) => dateTime.toIso8601String(),
    filter: external_logger.DevelopmentFilter(),
  );

  /// Production configuration
  factory LogConfig.production() => LogConfig(
    methodCount: 0,
    errorMethodCount: 5,
    enableColors: false,
    enableEmojis: false,
    dateTimeFormat: (dateTime) => dateTime.toIso8601String(),
    filter: external_logger.ProductionFilter(),
  );

  /// Testing configuration
  factory LogConfig.testing() => LogConfig(
    methodCount: 1,
    errorMethodCount: 3,
    enableColors: false,
    enableEmojis: false,
    dateTimeFormat: (dateTime) => dateTime.toIso8601String(),
  );
}

/// Extension for easier logging
extension LoggerExtension on Object {
  void logDebug(String message) => LoggerService().debug(message);
  void logInfo(String message) => LoggerService().info(message);
  void logWarning(String message) => LoggerService().warning(message);
  void logError(String message, [Object? error, StackTrace? stackTrace]) =>
      LoggerService().error(message, error: error, stackTrace: stackTrace);
}