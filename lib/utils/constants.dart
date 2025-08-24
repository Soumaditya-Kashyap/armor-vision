import 'package:flutter/material.dart';
import '../models/password_entry.dart';

class AppConstants {
  // App Information
  static const String appName = 'Armor';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Secure Offline Password Manager';

  // Security
  static const int minPinLength = 4;
  static const int maxPinLength = 8;
  static const int defaultSessionTimeoutMinutes = 5;
  static const int maxFailedAttempts = 5;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double cardElevation = 4.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Grid Layout
  static const int gridCrossAxisCount = 2;
  static const double gridAspectRatio = 1.2;
  static const double gridSpacing = 12.0;

  // Field Types
  static const Map<FieldType, String> fieldTypeLabels = {
    FieldType.text: 'Text',
    FieldType.password: 'Password',
    FieldType.email: 'Email',
    FieldType.url: 'Website',
    FieldType.number: 'Number',
    FieldType.note: 'Note',
    FieldType.phone: 'Phone',
    FieldType.date: 'Date',
    FieldType.bankAccount: 'Bank Account',
    FieldType.creditCard: 'Credit Card',
    FieldType.socialSecurity: 'Social Security',
    FieldType.username: 'Username',
    FieldType.pin: 'PIN',
  };

  // Colors
  static const Map<EntryColor, Color> entryColors = {
    EntryColor.blue: Colors.blue,
    EntryColor.green: Colors.green,
    EntryColor.orange: Colors.orange,
    EntryColor.red: Colors.red,
    EntryColor.purple: Colors.purple,
    EntryColor.teal: Colors.teal,
    EntryColor.pink: Colors.pink,
    EntryColor.indigo: Colors.indigo,
    EntryColor.amber: Colors.amber,
    EntryColor.gray: Colors.grey,
  };

  // Common Field Templates
  static List<CustomField> getCommonFieldTemplates(String entryType) {
    switch (entryType.toLowerCase()) {
      case 'social':
        return [
          CustomField(
            label: 'Username',
            value: '',
            type: FieldType.username,
            isRequired: true,
          ),
          CustomField(
            label: 'Email',
            value: '',
            type: FieldType.email,
            isRequired: true,
          ),
          CustomField(
            label: 'Password',
            value: '',
            type: FieldType.password,
            isRequired: true,
            isHidden: true,
          ),
        ];
      case 'banking':
        return [
          CustomField(
            label: 'Account Number',
            value: '',
            type: FieldType.bankAccount,
            isRequired: true,
            isHidden: true,
          ),
          CustomField(
            label: 'Routing Number',
            value: '',
            type: FieldType.number,
            isRequired: true,
          ),
          CustomField(
            label: 'PIN',
            value: '',
            type: FieldType.pin,
            isRequired: false,
            isHidden: true,
          ),
        ];
      case 'work':
        return [
          CustomField(
            label: 'Employee ID',
            value: '',
            type: FieldType.text,
            isRequired: true,
          ),
          CustomField(
            label: 'Email',
            value: '',
            type: FieldType.email,
            isRequired: true,
          ),
          CustomField(
            label: 'Password',
            value: '',
            type: FieldType.password,
            isRequired: true,
            isHidden: true,
          ),
        ];
      default: // general
        return [
          CustomField(
            label: 'Username',
            value: '',
            type: FieldType.username,
            isRequired: true,
          ),
          CustomField(
            label: 'Password',
            value: '',
            type: FieldType.password,
            isRequired: true,
            isHidden: true,
          ),
          CustomField(
            label: 'Website',
            value: '',
            type: FieldType.url,
            isRequired: false,
          ),
        ];
    }
  }
}

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3), // Blue
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3), // Blue
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
      ),
    ),
  );
}

class AppValidators {
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is usually optional
    }

    final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  static String? validatePin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN is required';
    }

    final pin = value.trim();
    if (pin.length < AppConstants.minPinLength ||
        pin.length > AppConstants.maxPinLength) {
      return 'PIN must be ${AppConstants.minPinLength}-${AppConstants.maxPinLength} digits';
    }

    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return 'PIN must contain only numbers';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is usually optional
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }

    return null;
  }
}

class AppHelpers {
  /// Generate a unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Format file size
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get icon for field type
  static IconData getFieldTypeIcon(FieldType type) {
    switch (type) {
      case FieldType.text:
        return Icons.text_fields;
      case FieldType.password:
        return Icons.lock;
      case FieldType.email:
        return Icons.email;
      case FieldType.url:
        return Icons.link;
      case FieldType.number:
        return Icons.numbers;
      case FieldType.note:
        return Icons.note;
      case FieldType.phone:
        return Icons.phone;
      case FieldType.date:
        return Icons.calendar_today;
      case FieldType.bankAccount:
        return Icons.account_balance;
      case FieldType.creditCard:
        return Icons.credit_card;
      case FieldType.socialSecurity:
        return Icons.security;
      case FieldType.username:
        return Icons.person;
      case FieldType.pin:
        return Icons.pin;
    }
  }

  /// Get color for entry color enum
  static Color getEntryColor(EntryColor entryColor) {
    return AppConstants.entryColors[entryColor] ?? Colors.blue;
  }

  /// Copy text to clipboard
  static void copyToClipboard(BuildContext context, String text,
      {String? successMessage}) {
    // Implementation will be added when we import services
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage ?? 'Copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? FilledButton.styleFrom(backgroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
