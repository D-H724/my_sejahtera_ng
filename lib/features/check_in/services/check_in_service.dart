import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_sejahtera_ng/core/services/supabase_service.dart';

class CheckInService {
  final SupabaseClient _supabase = SupabaseService().client;

  Future<void> checkIn(String locationName, String? address) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw "User not logged in";

      await _supabase.from('check_ins').insert({
        'user_id': user.id,
        'location_name': locationName,
        'address': address,
        'check_in_time': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Re-throw to let UI handle error display
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
       final user = _supabase.auth.currentUser;
       if (user == null) return [];
       
       final response = await _supabase
           .from('check_ins')
           .select()
           .eq('user_id', user.id)
           .order('check_in_time', ascending: false)
           .limit(50);
           
       return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
