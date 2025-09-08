import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teammates/screens/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:teammates/supabase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pl_PL', null);

  await Supabase.initialize(
    url: SupabaseOptions.url,
    anonKey: SupabaseOptions.anonKey,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamMates',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFD91B24),
          onPrimary: Colors.white,
          secondary: Color(0xFF761F21),
          onSecondary: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
          background: Color(0xFF1C1C1C),
          onBackground: Colors.white,
          surface: Color(0xFF050505),
          onSurface: Colors.white,
        ),
        fontFamily: 'Georgia',
        textTheme: Theme.of(
          context,
        ).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      home: const SplashScreen(),
    );
  }
}
