import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:videocall/auth/register.dart';
import 'package:videocall/supabaseChannel/ChatProvider.dart';
import 'package:videocall/supabase_config.dart';

import 'mainscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Регистрация/авторизация',
      // home: RegisterScreen(),
      home: ScreenMain(),
    );
  }
}