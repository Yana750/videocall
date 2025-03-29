import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:videocall/supabaseChannel/ChannelScreen.dart';
import 'package:videocall/supabaseChannel/ChatProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Загружаем конфигурации из .env
  await dotenv.load();

  // Инициализация Supabase с данными из .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Теперь Scaffold будет иметь Directionality в иерархии
      home: ChangeNotifierProvider(
        create: (context) => ChatProvider(),
        child: ChatScreen(), // Убедитесь, что ChatScreen не const
      ),
    );
  }
}

