class InputSanitizer {
  static String sanitize(String input) {
    if (input.isEmpty) return input;
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '')
        .replaceAll(RegExp(r'data:', caseSensitive: false), '')
        .trim();
  }

  static String sanitizeUrl(String url) {
    if (url.isEmpty) return url;
    final lower = url.toLowerCase().trim();
    if (lower.startsWith('javascript:') ||
        lower.startsWith('data:') ||
        lower.startsWith('vbscript:')) {
      return '';
    }
    return sanitize(url);
  }

  static bool isValidEmail(String email) {
    if (email.isEmpty) return true;
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  static String sanitizePhone(String phone) {
    if (phone.isEmpty) return phone;
    return phone.replaceAll(RegExp(r'[^\d\-+() ]'), '').trim();
  }
}