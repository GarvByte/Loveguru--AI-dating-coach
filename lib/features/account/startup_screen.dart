import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StartupScreen extends ConsumerStatefulWidget {
  const StartupScreen({super.key});

  @override
  ConsumerState<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends ConsumerState<StartupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = Supabase.instance.client.auth.currentSession;
      print("session = $session");
      if (session == null) {
        Navigator.pushNamed(context, "/auth");
        Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
      } else {
        Navigator.pushNamed(context, "/chat");
        Navigator.pushNamedAndRemoveUntil(context, '/chat', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
