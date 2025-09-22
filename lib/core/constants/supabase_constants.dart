import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConstants {
  static String supabaseUrl = dotenv.env["SUPABASE_URL"] ?? "";
  static String supabaseKey = dotenv.env["SUPABASE_KEY"] ?? "";
  static String iosAuthClientId = dotenv.env["IOS_AUTH_CLIENT_ID"] ?? "";
  static String serverAuthclientId = dotenv.env["SERVICE_AUTH_CLIENT_ID"] ?? "";
}
