import 'package:flutter/material.dart';
import 'package:videocall/auth/login.dart';
import 'package:videocall/mainscreen.dart';
import '../supabase_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signUp() async {
    try {
      final authResponse = await SupabaseConfig.client.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      final user = authResponse.user;

      if (user != null) {
        print("✅ Пользователь зарегистрирован: ${user.id}");

        // Добавляем пользователя в таблицу profiles
        await SupabaseConfig.client.from('profiles').insert({
          'id': user.id, // UUID пользователя
          'username': emailController.text,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Переход на главный экран после успешной регистрации
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ScreenMain()),
        );
      } else {
        print("❌ Ошибка регистрации: authResponse.user == null");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка регистрации: пользователь не создан')),
        );
      }
    } catch (error) {
      print("❌ Ошибка регистрации: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка регистрации: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUp,
              child: const Text('Зарегистрироваться'),
            ),
            const SizedBox(height: 20,),
            TextButton(onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginScreen())
              );
            },
                child: const Text("Авторизация"))
          ],
        ),
      ),
    );
  }
}