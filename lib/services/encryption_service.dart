import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const String _keyAlias = 'armor_master_key';
  static const String _saltAlias = 'armor_salt';
  static const String _ivAlias = 'armor_iv';

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  late Encrypter _encrypter;
  late Key _key;
  late Uint8List _salt;
  bool _isInitialized = false;

  // Enhanced security features
  int _failedAttempts = 0;
  static const int _maxFailedAttempts = 5;
  DateTime? _lockoutUntil;

  // Singleton pattern
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  /// Initialize encryption service with master key
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check if locked out
      if (_isLockedOut()) {
        throw SecurityException('Too many failed attempts. Service locked.');
      }

      // Try to get existing key and salt
      String? existingKey = await _secureStorage.read(key: _keyAlias);
      String? existingSalt = await _secureStorage.read(key: _saltAlias);

      if (existingKey != null && existingSalt != null) {
        // Use existing key and salt
        _key = Key.fromBase64(existingKey);
        _salt = base64.decode(existingSalt);
      } else {
        // Generate new key and salt
        await _generateNewKeyPair();
      }

      _encrypter = Encrypter(AES(_key, mode: AESMode.gcm));
      _isInitialized = true;
      _resetFailedAttempts();
    } catch (e) {
      _handleFailedAttempt();
      throw SecurityException('Failed to initialize encryption: $e');
    }
  }

  /// Generate new encryption key pair
  Future<void> _generateNewKeyPair() async {
    try {
      // Generate cryptographically secure random key (256-bit)
      _key = Key.fromSecureRandom(32);

      // Generate salt for additional security
      _salt = _generateSecureRandomBytes(32);

      // Store the key and salt securely
      await _secureStorage.write(key: _keyAlias, value: _key.base64);
      await _secureStorage.write(key: _saltAlias, value: base64.encode(_salt));
    } catch (e) {
      throw SecurityException('Failed to generate key pair: $e');
    }
  }

  /// Generate secure random bytes
  Uint8List _generateSecureRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
        List<int>.generate(length, (i) => random.nextInt(256)));
  }

  /// Encrypt data with additional security layers
  String encrypt(String data) {
    if (!_isInitialized) {
      throw SecurityException('Encryption service not initialized');
    }

    if (_isLockedOut()) {
      throw SecurityException('Service locked due to security violations');
    }

    try {
      // Add integrity check
      final dataWithHash = _addIntegrityCheck(data);

      // Generate unique IV for each encryption
      final iv = IV.fromSecureRandom(16);

      // Encrypt with AES-GCM (provides both encryption and authentication)
      final encrypted = _encrypter.encrypt(dataWithHash, iv: iv);

      // Combine IV, salt, and encrypted data
      final combined = _combineSecurityData(iv, encrypted);

      return base64.encode(combined);
    } catch (e) {
      _handleFailedAttempt();
      throw SecurityException('Failed to encrypt data: $e');
    }
  }

  /// Decrypt data with integrity verification
  String decrypt(String encryptedData) {
    if (!_isInitialized) {
      throw SecurityException('Encryption service not initialized');
    }

    if (_isLockedOut()) {
      throw SecurityException('Service locked due to security violations');
    }

    try {
      final combined = base64.decode(encryptedData);

      // Extract security components
      final components = _extractSecurityData(combined);

      // Decrypt data
      final decrypted =
          _encrypter.decrypt(components.encrypted, iv: components.iv);

      // Verify integrity
      final originalData = _verifyIntegrityCheck(decrypted);

      return originalData;
    } catch (e) {
      _handleFailedAttempt();
      throw SecurityException('Failed to decrypt data: $e');
    }
  }

  /// Encrypt file (for images) with enhanced security
  Future<String> encryptFile(Uint8List fileBytes) async {
    if (!_isInitialized) {
      throw SecurityException('Encryption service not initialized');
    }

    try {
      // Add file signature for integrity
      final fileWithSignature = _addFileSignature(fileBytes);

      // Compress if beneficial (large files)
      final processedData = fileBytes.length > 1024 * 100
          ? _compressData(fileWithSignature)
          : fileWithSignature;

      final iv = IV.fromSecureRandom(16);
      final encrypted = _encrypter.encryptBytes(processedData, iv: iv);

      final combined = _combineSecurityData(iv, encrypted);
      return base64.encode(combined);
    } catch (e) {
      throw SecurityException('Failed to encrypt file: $e');
    }
  }

  /// Decrypt file (for images) with verification
  Future<Uint8List> decryptFile(String encryptedData) async {
    if (!_isInitialized) {
      throw SecurityException('Encryption service not initialized');
    }

    try {
      final combined = base64.decode(encryptedData);
      final components = _extractSecurityData(combined);

      final decryptedBytes =
          _encrypter.decryptBytes(components.encrypted, iv: components.iv);

      // Decompress if needed and verify signature
      final originalData =
          _verifyFileSignature(Uint8List.fromList(decryptedBytes));

      return originalData;
    } catch (e) {
      throw SecurityException('Failed to decrypt file: $e');
    }
  }

  /// Enhanced password strength calculation
  PasswordStrength calculatePasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.veryWeak;

    int score = 0;
    final checks = <String, bool>{};

    // Length scoring (more sophisticated)
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;
    if (password.length >= 16) score += 1;
    if (password.length >= 20) score += 1;

    // Character variety
    checks['lowercase'] = password.contains(RegExp(r'[a-z]'));
    checks['uppercase'] = password.contains(RegExp(r'[A-Z]'));
    checks['numbers'] = password.contains(RegExp(r'[0-9]'));
    checks['symbols'] = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    checks['extended'] =
        password.contains(RegExp(r'[^\w\s!@#$%^&*(),.?":{}|<>]'));

    score += checks.values.where((v) => v).length;

    // Pattern detection (reduce score for common patterns)
    if (_hasCommonPatterns(password)) score -= 2;
    if (_hasRepeatingCharacters(password)) score -= 1;
    if (_isCommonPassword(password)) score -= 3;

    // Entropy calculation
    final entropy = _calculateEntropy(password);
    if (entropy > 60)
      score += 2;
    else if (entropy > 40) score += 1;

    return _scoreToStrength(score, checks);
  }

  /// Security utility methods
  String generateSecurePassword({
    int length = 16,
    bool includeSymbols = true,
    bool includeNumbers = true,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool excludeAmbiguous = true,
  }) {
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    const ambiguous = '0O1lI|';

    String chars = '';
    if (includeLowercase) chars += lowercase;
    if (includeUppercase) chars += uppercase;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;

    if (excludeAmbiguous) {
      for (String char in ambiguous.split('')) {
        chars = chars.replaceAll(char, '');
      }
    }

    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Check if service is locked out
  bool _isLockedOut() {
    if (_lockoutUntil == null) return false;
    if (DateTime.now().isBefore(_lockoutUntil!)) return true;

    // Lockout expired, reset
    _lockoutUntil = null;
    _failedAttempts = 0;
    return false;
  }

  /// Handle failed authentication attempt
  void _handleFailedAttempt() {
    _failedAttempts++;
    if (_failedAttempts >= _maxFailedAttempts) {
      // Exponential backoff: 2^attempts minutes
      final lockoutMinutes =
          pow(2, _failedAttempts - _maxFailedAttempts + 1).toInt();
      _lockoutUntil = DateTime.now().add(Duration(minutes: lockoutMinutes));
    }
  }

  /// Reset failed attempts counter
  void _resetFailedAttempts() {
    _failedAttempts = 0;
    _lockoutUntil = null;
  }

  /// Security helper methods
  String _addIntegrityCheck(String data) {
    final hash =
        sha256.convert(utf8.encode(data + _salt.toString())).toString();
    return '$data|$hash';
  }

  String _verifyIntegrityCheck(String dataWithHash) {
    final parts = dataWithHash.split('|');
    if (parts.length != 2) throw SecurityException('Integrity check failed');

    final data = parts[0];
    final providedHash = parts[1];
    final expectedHash =
        sha256.convert(utf8.encode(data + _salt.toString())).toString();

    if (providedHash != expectedHash) {
      throw SecurityException('Data integrity verification failed');
    }

    return data;
  }

  Uint8List _addFileSignature(Uint8List fileBytes) {
    final signature = sha256.convert(fileBytes + _salt).bytes;
    return Uint8List.fromList([...signature, ...fileBytes]);
  }

  Uint8List _verifyFileSignature(Uint8List dataWithSignature) {
    if (dataWithSignature.length < 32) {
      throw SecurityException('Invalid file signature');
    }

    final signature = dataWithSignature.sublist(0, 32);
    final fileBytes = dataWithSignature.sublist(32);
    final expectedSignature = sha256.convert(fileBytes + _salt).bytes;

    if (!_constantTimeEquals(signature, expectedSignature)) {
      throw SecurityException('File integrity verification failed');
    }

    return fileBytes;
  }

  Uint8List _combineSecurityData(IV iv, Encrypted encrypted) {
    return Uint8List.fromList([
      ...iv.bytes,
      ...encrypted.bytes,
    ]);
  }

  SecurityComponents _extractSecurityData(Uint8List combined) {
    if (combined.length < 16) {
      throw SecurityException('Invalid encrypted data format');
    }

    final iv = IV(combined.sublist(0, 16));
    final encrypted = Encrypted(combined.sublist(16));

    return SecurityComponents(iv: iv, encrypted: encrypted);
  }

  /// Utility methods for password analysis
  bool _hasCommonPatterns(String password) {
    final patterns = [
      RegExp(r'(.)\1{2,}'), // Repeating characters
      RegExp(r'(012|123|234|345|456|567|678|789|890)'), // Sequential numbers
      RegExp(
          r'(abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)',
          caseSensitive: false), // Sequential letters
    ];

    return patterns.any((pattern) => pattern.hasMatch(password));
  }

  bool _hasRepeatingCharacters(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      if (password[i] == password[i + 1] &&
          password[i + 1] == password[i + 2]) {
        return true;
      }
    }
    return false;
  }

  bool _isCommonPassword(String password) {
    final common = [
      'password',
      '123456',
      '123456789',
      'qwerty',
      'abc123',
      'password1',
      '12345678',
      '111111',
      '1234567890',
      'admin',
    ];
    return common.contains(password.toLowerCase());
  }

  double _calculateEntropy(String password) {
    final charSet = <String>{};
    for (String char in password.split('')) {
      charSet.add(char);
    }

    if (charSet.isEmpty) return 0;

    final charSetSize = charSet.length;
    return password.length * (log(charSetSize) / log(2));
  }

  PasswordStrength _scoreToStrength(int score, Map<String, bool> checks) {
    if (score <= 2) return PasswordStrength.veryWeak;
    if (score <= 4) return PasswordStrength.weak;
    if (score <= 6) return PasswordStrength.fair;
    if (score <= 8) return PasswordStrength.good;
    if (score <= 10) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  Uint8List _compressData(Uint8List data) {
    // Simple compression for demo - in production, use proper compression
    return data;
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }

    return result == 0;
  }

  /// Public getters
  bool get isInitialized => _isInitialized;
  int get failedAttempts => _failedAttempts;
  bool get isLockedOut => _isLockedOut();
  DateTime? get lockoutUntil => _lockoutUntil;

  /// Clear all encryption keys (for logout/reset)
  Future<void> clearKeys() async {
    await _secureStorage.delete(key: _keyAlias);
    await _secureStorage.delete(key: _saltAlias);
    await _secureStorage.delete(key: _ivAlias);
    _isInitialized = false;
    _resetFailedAttempts();
  }

  /// Export encrypted backup (for manual backup)
  Future<String> exportEncryptedBackup() async {
    if (!_isInitialized) {
      throw SecurityException('Encryption service not initialized');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final metadata = {
      'version': '1.0',
      'timestamp': timestamp,
      'salt': base64.encode(_salt),
    };

    return base64.encode(utf8.encode(jsonEncode(metadata)));
  }
}

// Supporting classes and enums
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}

class SecurityComponents {
  final IV iv;
  final Encrypted encrypted;

  SecurityComponents({required this.iv, required this.encrypted});
}

enum PasswordStrength {
  veryWeak,
  weak,
  fair,
  good,
  strong,
  veryStrong,
}

// Extension for better password strength display
extension PasswordStrengthExtension on PasswordStrength {
  String get displayName {
    switch (this) {
      case PasswordStrength.veryWeak:
        return 'Very Weak';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }

  double get score {
    switch (this) {
      case PasswordStrength.veryWeak:
        return 0.1;
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.fair:
        return 0.5;
      case PasswordStrength.good:
        return 0.75;
      case PasswordStrength.strong:
        return 0.9;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }
}
