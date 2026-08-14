class ErrorHandler {
  /// Converts raw technical exceptions into clean, user-friendly messages.
  static String toUserFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'An unexpected error occurred. Please try again.';
    }

    final rawString = error.toString().trim();
    final lower = rawString.toLowerCase();

    // 1. Invalid Login & Credentials
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials') ||
        lower.contains('grant_type_invalid') ||
        lower.contains('invalid email or password')) {
      return 'Email or Password is wrong. Please check your credentials and try again.';
    }

    // 2. User & Account Status
    if (lower.contains('deactivated')) {
      return 'This account has been deactivated. Please contact support.';
    }

    if (lower.contains('user already registered') ||
        lower.contains('already exists') ||
        lower.contains('duplicate key')) {
      return 'An account or record with this information already exists.';
    }

    if (lower.contains('password must be at least') ||
        lower.contains('password should be at least')) {
      return 'Password must be at least 6 characters long.';
    }

    // 3. Network & Connectivity Errors
    if (lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection refused') ||
        lower.contains('clientexception') ||
        lower.contains('network') ||
        lower.contains('connection timed out')) {
      return 'Network connection failed. Please check your internet connection and try again.';
    }

    // 4. Session & Permission Errors
    if (lower.contains('jwt expired') ||
        lower.contains('token expired') ||
        lower.contains('unauthorized')) {
      return 'Your session has expired. Please log in again.';
    }

    if (lower.contains('permission denied') ||
        lower.contains('row-level security') ||
        lower.contains('rls policy')) {
      return 'You do not have permission to perform this action.';
    }

    // 5. Clean up custom business error messages
    String cleanMessage = rawString;

    // Strip standard "Exception: " prefix
    if (cleanMessage.startsWith('Exception: ')) {
      cleanMessage = cleanMessage.substring(11).trim();
    }

    // Extract message property if raw Supabase exception string (e.g. AuthApiException, PostgrestException)
    if (cleanMessage.contains('AuthApiException') ||
        cleanMessage.contains('AuthException') ||
        cleanMessage.contains('PostgrestException') ||
        cleanMessage.contains('FunctionException')) {
      final match = RegExp(r'message:\s*([^,}]+)').firstMatch(cleanMessage);
      if (match != null && match.group(1) != null) {
        cleanMessage = match.group(1)!.trim();
      }
    }

    // If message is empty or still contains raw code identifiers, fallback gracefully
    if (cleanMessage.isEmpty ||
        cleanMessage.contains('AuthApiException') ||
        cleanMessage.contains('PostgrestException') ||
        cleanMessage.contains('SocketException')) {
      return 'An unexpected error occurred. Please try again.';
    }

    return cleanMessage;
  }
}
