import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorService {
  static Future<void> logError({
    required String errorMessage,
    required String operationType,
    String? eventId,
    Map<String, dynamic>? eventData,
  }) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.rpc('log_error_func', params: {
        'p_error_message': errorMessage,
        'p_operation_type': operationType,
        'p_event_id': eventId,
        'p_event_data_snapshot': eventData,
      });
    } catch (e) {
      // If logging itself fails, print to console to avoid infinite loops.
      print('Failed to log error to database: $e');
    }
  }
}
