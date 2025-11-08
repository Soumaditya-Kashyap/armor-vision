import 'package:hive/hive.dart';

part 'export_models.g.dart';

/// Export file format options
@HiveType(typeId: 10)
enum ExportFormat {
  @HiveField(0)
  pdf,

  @HiveField(1)
  txt,
}

/// Extension methods for ExportFormat
extension ExportFormatExtension on ExportFormat {
  String get displayName {
    switch (this) {
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.txt:
        return 'TXT';
    }
  }

  String get fileExtension {
    switch (this) {
      case ExportFormat.pdf:
        return 'pdf';
      case ExportFormat.txt:
        return 'txt';
    }
  }

  String get description {
    switch (this) {
      case ExportFormat.pdf:
        return 'Professional document format with formatting';
      case ExportFormat.txt:
        return 'Plain text format, universal compatibility';
    }
  }
}

/// Status of an export operation
enum ExportStatus { success, failed, cancelled, inProgress }

/// Result of an export operation
class ExportResult {
  final ExportStatus status;
  final String? filePath;
  final int? fileSizeBytes;
  final String? errorMessage;
  final DateTime timestamp;
  final ExportFormat format;
  final int entriesExported;

  ExportResult({
    required this.status,
    this.filePath,
    this.fileSizeBytes,
    this.errorMessage,
    required this.timestamp,
    required this.format,
    this.entriesExported = 0,
  });

  /// Check if export was successful
  bool get isSuccess => status == ExportStatus.success;

  /// Check if export failed
  bool get isFailed => status == ExportStatus.failed;

  /// Check if export was cancelled
  bool get isCancelled => status == ExportStatus.cancelled;

  /// Check if export is in progress
  bool get isInProgress => status == ExportStatus.inProgress;

  /// Get human-readable file size
  String get fileSizeFormatted {
    if (fileSizeBytes == null) return 'Unknown';

    final kb = fileSizeBytes! / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }

    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  /// Get display message based on status
  String get displayMessage {
    switch (status) {
      case ExportStatus.success:
        return 'Export completed successfully';
      case ExportStatus.failed:
        return errorMessage ?? 'Export failed';
      case ExportStatus.cancelled:
        return 'Export cancelled';
      case ExportStatus.inProgress:
        return 'Exporting...';
    }
  }

  /// Create a success result
  factory ExportResult.success({
    required String filePath,
    required int fileSizeBytes,
    required ExportFormat format,
    required int entriesExported,
  }) {
    return ExportResult(
      status: ExportStatus.success,
      filePath: filePath,
      fileSizeBytes: fileSizeBytes,
      timestamp: DateTime.now(),
      format: format,
      entriesExported: entriesExported,
    );
  }

  /// Create a failed result
  factory ExportResult.failed({
    required String errorMessage,
    required ExportFormat format,
  }) {
    return ExportResult(
      status: ExportStatus.failed,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
      format: format,
    );
  }

  /// Create a cancelled result
  factory ExportResult.cancelled({required ExportFormat format}) {
    return ExportResult(
      status: ExportStatus.cancelled,
      timestamp: DateTime.now(),
      format: format,
    );
  }

  /// Create an in-progress result
  factory ExportResult.inProgress({required ExportFormat format}) {
    return ExportResult(
      status: ExportStatus.inProgress,
      timestamp: DateTime.now(),
      format: format,
    );
  }

  /// Copy with method for updates
  ExportResult copyWith({
    ExportStatus? status,
    String? filePath,
    int? fileSizeBytes,
    String? errorMessage,
    DateTime? timestamp,
    ExportFormat? format,
    int? entriesExported,
  }) {
    return ExportResult(
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      errorMessage: errorMessage ?? this.errorMessage,
      timestamp: timestamp ?? this.timestamp,
      format: format ?? this.format,
      entriesExported: entriesExported ?? this.entriesExported,
    );
  }
}

/// Configuration for an export operation
class ExportConfig {
  final ExportFormat format;
  final String password;
  final bool useDefaultPassword;
  final bool includeArchived;
  final bool includeNotes;
  final bool includeTags;
  final List<String>? selectedCategoryIds;
  final String? customFileName;

  ExportConfig({
    required this.format,
    required this.password,
    this.useDefaultPassword = false,
    this.includeArchived = false,
    this.includeNotes = true,
    this.includeTags = true,
    this.selectedCategoryIds,
    this.customFileName,
  });

  /// Validate export configuration
  bool get isValid {
    // Password must not be empty
    if (password.isEmpty) return false;

    // Password must be at least 8 characters
    if (password.length < 8) return false;

    return true;
  }

  /// Get validation error message
  String? get validationError {
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  /// Check password strength
  PasswordStrength get passwordStrength {
    if (password.length < 8) return PasswordStrength.weak;

    int score = 0;

    // Length check
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;

    // Character type checks
    if (password.contains(RegExp(r'[a-z]'))) score++; // Lowercase
    if (password.contains(RegExp(r'[A-Z]'))) score++; // Uppercase
    if (password.contains(RegExp(r'[0-9]'))) score++; // Numbers
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')))
      score++; // Special chars

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  /// Generate default filename
  String generateFileName() {
    if (customFileName != null && customFileName!.isNotEmpty) {
      return customFileName!;
    }

    final timestamp = DateTime.now();
    final formattedDate =
        '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}';
    final formattedTime =
        '${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}';

    return 'armor_export_${formattedDate}_$formattedTime.${format.fileExtension}.enc';
  }

  /// Copy with method
  ExportConfig copyWith({
    ExportFormat? format,
    String? password,
    bool? useDefaultPassword,
    bool? includeArchived,
    bool? includeNotes,
    bool? includeTags,
    List<String>? selectedCategoryIds,
    String? customFileName,
  }) {
    return ExportConfig(
      format: format ?? this.format,
      password: password ?? this.password,
      useDefaultPassword: useDefaultPassword ?? this.useDefaultPassword,
      includeArchived: includeArchived ?? this.includeArchived,
      includeNotes: includeNotes ?? this.includeNotes,
      includeTags: includeTags ?? this.includeTags,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      customFileName: customFileName ?? this.customFileName,
    );
  }
}

/// Password strength levels
enum PasswordStrength { weak, medium, strong }

/// Extension for password strength display
extension PasswordStrengthExtension on PasswordStrength {
  String get displayName {
    switch (this) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  String get description {
    switch (this) {
      case PasswordStrength.weak:
        return 'Too short or simple';
      case PasswordStrength.medium:
        return 'Acceptable but could be stronger';
      case PasswordStrength.strong:
        return 'Excellent password!';
    }
  }

  /// Get color indicator for strength
  int get colorValue {
    switch (this) {
      case PasswordStrength.weak:
        return 0xFFEF5350; // Red
      case PasswordStrength.medium:
        return 0xFFFFA726; // Orange
      case PasswordStrength.strong:
        return 0xFF66BB6A; // Green
    }
  }

  /// Get progress value (0.0 to 1.0)
  double get progressValue {
    switch (this) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}
