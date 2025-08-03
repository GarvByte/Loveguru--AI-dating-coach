import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loveguru/features/account/authentication_page.dart';
import 'package:loveguru/features/account/startup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loveguru/features/chat/chat_ui.dart';
import 'config/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxxbXl1ZHNkaHp6ZGNucWp0aXZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwMDYyNzIsImV4cCI6MjA2ODU4MjI3Mn0.KqtWnCnkYEdTAp7M4XiRWtDU8uovs0ICeHANdT6qrxs",
    url: "https://lqmyudsdhzzdcnqjtivv.supabase.co",
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: myCustomScrollBehaviour(),
      theme: AppTheme.lightTheme,
      home: StartupScreen(),
      routes: {
        "/chat": (context) => ChatUi(),
        "/auth": (context) => AuthenticationPage(),
        "/startup": (context) => StartupScreen(),
      },
    );
  }
}

class myCustomScrollBehaviour extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
