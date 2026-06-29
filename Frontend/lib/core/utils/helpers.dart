// Utility helper functions

// Helpers Utility File
// Purpose: Common utility functions, extensions, and helper methods
// Author: CarWash Pro Development Team
// Date: March 3, 2026

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
// ==================== DATE & TIME HELPERS ====================

/// Date and time utility functions
class DateTimeHelper {
  /// Format date to readable string
  /// 
  /// Parameters:
  ///   - date: DateTime to format
  ///   - format: Format pattern (default: 'dd MMM yyyy')
  /// 
  /// Returns: Formatted date string
  static String formatDate(
    DateTime date, {
    String format = 'dd MMM yyyy',
  }) {
    try {
      return DateFormat(format).format(date);
    } catch (e) {
      return date.toString();
    }
  }

  /// Format date and time
  /// 
  /// Parameters:
  ///   - dateTime: DateTime to format
  ///   - format: Format pattern (default: 'dd MMM yyyy, hh:mm a')
  /// 
  /// Returns: Formatted date-time string
  static String formatDateTime(
    DateTime dateTime, {
    String format = 'dd MMM yyyy, hh:mm a',
  }) {
    try {
      return DateFormat(format).format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }

  /// Format time only
  /// 
  /// Parameters:
  ///   - time: DateTime to format
  ///   - format: Format pattern (default: 'hh:mm a')
  /// 
  /// Returns: Formatted time string
  static String formatTime(
    DateTime time, {
    String format = 'hh:mm a',
  }) {
    try {
      return DateFormat(format).format(time);
    } catch (e) {
      return time.toString();
    }
  }

  /// Get relative time string (e.g., "2 hours ago")
  /// 
  /// Parameters:
  ///   - dateTime: DateTime to compare
  /// 
  /// Returns: Relative time string
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Get days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  /// Add days to date
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Get start of day (00:00:00)
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59)
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
}

// ==================== NUMBER & CURRENCY HELPERS ====================

/// Number and currency utility functions
class NumberHelper {
  /// Format number as currency
  /// 
  /// Parameters:
  ///   - amount: Amount to format
  ///   - currency: Currency symbol (default: 'Rs ')
  ///   - decimalPlaces: Number of decimal places (default: 2)
  /// 
  /// Returns: Formatted currency string
  static String formatCurrency(
    double amount, {
    String currency = 'Rs ',
    int decimalPlaces = 2,
  }) {
    try {
      final formatter = NumberFormat.currency(
        symbol: currency,
        decimalDigits: decimalPlaces,
      );
      return formatter.format(amount);
    } catch (e) {
      return '$currency$amount';
    }
  }

  /// Format number with separators
  /// 
  /// Parameters:
  ///   - number: Number to format
  /// 
  /// Returns: Formatted number string
  static String formatNumber(double number) {
    try {
      final formatter = NumberFormat('#,##0.##');
      return formatter.format(number);
    } catch (e) {
      return number.toString();
    }
  }

  /// Format percentage
  /// 
  /// Parameters:
  ///   - value: Decimal value (0.0 - 1.0)
  ///   - decimalPlaces: Decimal places (default: 1)
  /// 
  /// Returns: Percentage string
  static String formatPercentage(
    double value, {
    int decimalPlaces = 1,
  }) {
    return '${(value * 100).toStringAsFixed(decimalPlaces)}%';
  }

  /// Parse string to double
  static double? parseDouble(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      return null;
    }
  }

  /// Parse string to integer
  static int? parseInt(String value) {
    try {
      return int.parse(value);
    } catch (e) {
      return null;
    }
  }

  /// Check if number is valid
  static bool isValidNumber(String value) {
    try {
      double.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Calculate percentage
  static double calculatePercentage(double value, double percentage) {
    return (value * percentage) / 100;
  }

  /// Round to decimal places
  static double roundToDecimal(double value, int places) {
    final mod = (10.0 * places).toInt();
    return (value * mod).round() / mod;
  }
}

// ==================== STRING & TEXT HELPERS ====================

/// String utility functions
class StringHelper {
  /// Check if string is empty or null
  static bool isEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// Check if string is not empty
  static bool isNotEmpty(String? text) {
    return !isEmpty(text);
  }

  /// Validate email format
  /// 
  /// Parameters:
  ///   - email: Email to validate
  /// 
  /// Returns: true if valid email format
  static bool isValidEmail(String? email) {
    if (isEmpty(email)) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email!);
  }

  /// Validate phone number format
  /// 
  /// Parameters:
  ///   - phone: Phone number to validate
  /// 
  /// Returns: true if valid phone format
  static bool isValidPhone(String? phone) {
    if (isEmpty(phone)) return false;
    final phoneRegex = RegExp(r'^[0-9]{10,13}$');
    final cleanPhone = phone!.replaceAll(RegExp(r'[^\d]'), '');
    return phoneRegex.hasMatch(cleanPhone);
  }

  /// Validate password strength
  /// 
  /// Parameters:
  ///   - password: Password to validate
  /// 
  /// Returns: true if password meets requirements
  /// Requirements: min 8 chars, 1 uppercase, 1 number, 1 special char
  static bool isStrongPassword(String? password) {
    if (isEmpty(password) || password!.length < 8) return false;
    
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUppercase && hasNumber && hasSpecialChar;
  }

  /// Truncate string with ellipsis
  /// 
  /// Parameters:
  ///   - text: Text to truncate
  ///   - maxLength: Maximum length (default: 50)
  ///   - ellipsis: Ellipsis string (default: '...')
  /// 
  /// Returns: Truncated string
  static String truncate(
    String text, {
    int maxLength = 50,
    String ellipsis = '...',
  }) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$ellipsis';
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (isEmpty(text)) return '';
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  /// Capitalize all words
  static String capitalizeWords(String text) {
    if (isEmpty(text)) return '';
    return text
        .split(' ')
        .map((word) => capitalize(word))
        .join(' ');
  }

  /// Remove special characters
  static String removeSpecialChars(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '');
  }

  /// Extract numbers only
  static String extractNumbers(String text) {
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Mask sensitive data (e.g., credit card)
  /// 
  /// Parameters:
  ///   - text: Text to mask
  ///   - visibleChars: Number of visible characters from end
  /// 
  /// Returns: Masked string
  static String maskSensitiveData(
    String text, {
    int visibleChars = 4,
  }) {
    if (text.length <= visibleChars) return text;
    final masked = '*' * (text.length - visibleChars);
    return '$masked${text.substring(text.length - visibleChars)}';
  }

  /// Mask email
  static String maskEmail(String email) {
    if (!isValidEmail(email)) return email;
    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];
    
    final visibleChars = username.length > 2 ? 2 : 1;
    final maskedUsername = maskSensitiveData(username, visibleChars: visibleChars);
    
    return '$maskedUsername@$domain';
  }

  /// Mask phone number
  static String maskPhoneNumber(String phone) {
    if (!isValidPhone(phone)) return phone;
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return maskSensitiveData(cleanPhone, visibleChars: 4);
  }
}

// ==================== VALIDATION HELPERS ====================

/// Validation utility functions
class ValidationHelper {
  /// Validate username
  static bool isValidUsername(String? username) {
    if (StringHelper.isEmpty(username)) return false;
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    return usernameRegex.hasMatch(username!);
  }

  /// Validate URL
  static bool isValidURL(String? url) {
    if (StringHelper.isEmpty(url)) return false;
    try {
      Uri.parse(url!);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  /// Validate PIN (4-6 digits)
  static bool isValidPIN(String? pin) {
    if (StringHelper.isEmpty(pin)) return false;
    final pinRegex = RegExp(r'^[0-9]{4,6}$');
    return pinRegex.hasMatch(pin!);
  }

  /// Validate Aadhar number (12 digits)
  static bool isValidAadhar(String? aadhar) {
    if (StringHelper.isEmpty(aadhar)) return false;
    final cleanAadhar = aadhar!.replaceAll(RegExp(r'[^\d]'), '');
    return cleanAadhar.length == 12;
  }

  /// Validate PAN (10 characters)
  static bool isValidPAN(String? pan) {
    if (StringHelper.isEmpty(pan)) return false;
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    return panRegex.hasMatch(pan!);
  }

  /// Validate credit card number (Luhn algorithm)
  static bool isValidCreditCard(String? cardNumber) {
    if (StringHelper.isEmpty(cardNumber)) return false;
    
    final cleanCard = cardNumber!.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCard.length < 13 || cleanCard.length > 19) return false;
    
    return _luhnCheck(cleanCard);
  }

  /// Luhn algorithm check
  static bool _luhnCheck(String cardNumber) {
    int sum = 0;
    int isEven = 0;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (isEven == 1) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      isEven ^= 1;
    }

    return (sum % 10) == 0;
  }
}

// ==================== COLLECTION HELPERS ====================

/// Collection utility functions
class CollectionHelper {
  /// Check if list is empty
  static bool isEmpty<T>(List<T>? list) {
    return list == null || list.isEmpty;
  }

  /// Check if list is not empty
  static bool isNotEmpty<T>(List<T>? list) {
    return !isEmpty(list);
  }

  /// Check if map is empty
  static bool isMapEmpty<K, V>(Map<K, V>? map) {
    return map == null || map.isEmpty;
  }

  /// Check if map is not empty
  static bool isMapNotEmpty<K, V>(Map<K, V>? map) {
    return !isMapEmpty(map);
  }

  /// Get first item or null
  static T? getFirstOrNull<T>(List<T>? list) {
    return isEmpty(list) ? null : list!.first;
  }

  /// Get last item or null
  static T? getLastOrNull<T>(List<T>? list) {
    return isEmpty(list) ? null : list!.last;
  }

  /// Check if list contains item
  static bool contains<T>(List<T>? list, T item) {
    return isNotEmpty(list) && list!.contains(item);
  }

  /// Remove duplicates from list
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  /// Chunk list into smaller lists
  /// 
  /// Parameters:
  ///   - list: List to chunk
  ///   - chunkSize: Size of each chunk
  /// 
  /// Returns: List of chunks
  static List<List<T>> chunk<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
  }

  /// Filter list by condition
  static List<T> filterByCondition<T>(
    List<T> list,
    bool Function(T) condition,
  ) {
    return list.where(condition).toList();
  }

  /// Map list to another type
  static List<R> mapList<T, R>(
    List<T> list,
    R Function(T) mapper,
  ) {
    return list.map(mapper).toList();
  }
}

// ==================== COLOR & THEME HELPERS ====================

/// Color and theme utility functions
class ColorHelper {
  /// Convert hex color string to Color
  /// 
  /// Parameters:
  ///   - hexColor: Hex color string (e.g., '#FF5733' or 'FF5733')
  /// 
  /// Returns: Color object
  static Color hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  /// Convert Color to hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).toUpperCase()}';
  }

  /// Get contrasting text color (black or white)
  /// 
  /// Parameters:
  ///   - backgroundColor: Background color
  /// 
  /// Returns: Black or white color for good contrast
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Lighten color
  /// 
  /// Parameters:
  ///   - color: Color to lighten
  ///   - amount: Lightening amount (0.0 - 1.0)
  /// 
  /// Returns: Lightened color
  static Color lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Darken color
  /// 
  /// Parameters:
  ///   - color: Color to darken
  ///   - amount: Darkening amount (0.0 - 1.0)
  /// 
  /// Returns: Darkened color
  static Color darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Get opacity color
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}

// ==================== FILE & STORAGE HELPERS ====================

/// File and storage utility functions
class FileHelper {
  /// Format file size
  /// 
  /// Parameters:
  ///   - bytes: File size in bytes
  /// 
  /// Returns: Formatted file size string
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    if (bytes == 0) return '0 B';

    final index = (math.log(bytes) / math.log(1024)).floor();
    final size = bytes / math.pow(1024, index);

    return '${size.toStringAsFixed(2)} ${suffixes[index]}';
  }

  /// Get file extension
  /// 
  /// Parameters:
  ///   - filename: File name with extension
  /// 
  /// Returns: File extension
  static String getFileExtension(String filename) {
    if (!filename.contains('.')) return '';
    return filename.substring(filename.lastIndexOf('.') + 1).toLowerCase();
  }

  /// Check if file is image
  static bool isImageFile(String filename) {
    final ext = getFileExtension(filename);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  /// Check if file is document
  static bool isDocumentFile(String filename) {
    final ext = getFileExtension(filename);
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(ext);
  }

  /// Check if file is video
  static bool isVideoFile(String filename) {
    final ext = getFileExtension(filename);
    return ['mp4', 'avi', 'mov', 'mkv', 'webm', 'flv'].contains(ext);
  }
}

// ==================== RANDOM & GENERATION HELPERS ====================

/// Random and generation utility functions
class GenerationHelper {
  /// Generate random string
  /// 
  /// Parameters:
  ///   - length: Length of random string (default: 10)
  /// 
  /// Returns: Random alphanumeric string
  static String generateRandomString(int length) {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
    final random = <String>[];
    for (int i = 0; i < length; i++) {
      random.add(chars[(DateTime.now().millisecond + i) % chars.length]);
    }
    return random.join();
  }

  /// Generate unique ID
  static String generateUniqueId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${generateRandomString(8)}';
  }

  /// Generate UUID-like string
  static String generateUUID() {
    const chars = 'abcdef0123456789';
    final random = <String>[];
    for (int i = 0; i < 36; i++) {
      if (i == 8 || i == 13 || i == 18 || i == 23) {
        random.add('-');
      } else if (i == 14) {
        random.add('4');
      } else {
        random.add(chars[DateTime.now().millisecond % chars.length]);
      }
    }
    return random.join();
  }
}

// ==================== LOG HELPERS ====================

/// Logging utility functions
class LogHelper {
  static const String _logPrefix = '[CarWash]';
  static bool _debugMode = true;

  /// Enable/disable debug logging
  static void setDebugMode(bool enabled) {
    _debugMode = enabled;
  }

  /// Log debug message
  static void logDebug(String message) {
    if (_debugMode) {
      debugPrint('$_logPrefix [DEBUG] $message');
    }
  }

  /// Log info message
  static void logInfo(String message) {
    if (_debugMode) {
      debugPrint('$_logPrefix [INFO] $message');
    }
  }

  /// Log warning message
  static void logWarning(String message) {
    if (_debugMode) {
      debugPrint('$_logPrefix [WARNING] $message');
    }
  }

  /// Log error message
  static void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_debugMode) {
      debugPrint('$_logPrefix [ERROR] $message');
      if (error != null) {
        debugPrint('$_logPrefix [ERROR] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('$_logPrefix [ERROR] StackTrace: $stackTrace');
      }
    }
  }
}

// ==================== EXTENSION HELPERS ====================

/// String extensions
extension StringExtension on String {
  /// Check if string is empty
  bool get isEmpty => this.isEmpty;

  /// Check if string is not empty
  bool get isNotEmpty => this.isNotEmpty;

  /// Capitalize first letter
  String get capitalize => StringHelper.capitalize(this);

  /// Truncate with ellipsis
  String truncate({int maxLength = 50}) {
    return StringHelper.truncate(this, maxLength: maxLength);
  }

  /// Check if valid email
  bool get isValidEmail => StringHelper.isValidEmail(this);

  /// Check if valid phone
  bool get isValidPhone => StringHelper.isValidPhone(this);

  /// Mask sensitive data
  String maskSensitive({int visibleChars = 4}) {
    return StringHelper.maskSensitiveData(this, visibleChars: visibleChars);
  }
}

/// DateTime extensions
extension DateTimeExtension on DateTime {
  /// Format to readable string
  String get formatted => DateTimeHelper.formatDate(this);

  /// Format with time
  String get formattedWithTime => DateTimeHelper.formatDateTime(this);

  /// Get relative time
  String get relative => DateTimeHelper.getRelativeTime(this);

  /// Check if is today
  bool get isToday => DateTimeHelper.isToday(this);

  /// Check if is tomorrow
  bool get isTomorrow => DateTimeHelper.isTomorrow(this);

  /// Check if is yesterday
  bool get isYesterday => DateTimeHelper.isYesterday(this);
}

/// List extensions
extension ListExtension<T> on List<T> {
  /// Get first item or null
  T? get firstOrNull => CollectionHelper.getFirstOrNull(this);

  /// Get last item or null
  T? get lastOrNull => CollectionHelper.getLastOrNull(this);

  /// Remove duplicates
  List<T> get unique => CollectionHelper.removeDuplicates(this);

  /// Check if contains item
  bool contains(T item) => CollectionHelper.contains(this, item);
}

/// Color extensions
extension ColorExtension on Color {
  /// Convert to hex string
  String get toHex => ColorHelper.colorToHex(this);

  /// Get contrasting text color
  Color get contrastingTextColor =>
      ColorHelper.getContrastingTextColor(this);

  /// Lighten color
  Color lighten(double amount) => ColorHelper.lighten(this, amount);

  /// Darken color
  Color darken(double amount) => ColorHelper.darken(this, amount);
}

// ==================== MATH IMPORTS ====================


