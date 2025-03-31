import 'package:flutter/material.dart';
import 'package:videocall/auth/register.dart';
import 'package:videocall/mainscreen.dart';
import '../supabase_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signIn() async {
    try {
      final authResponse = await SupabaseConfig.client.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (authResponse.session != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ScreenMain()),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Авторизация')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signIn,
              child: Text('Войти'),
            ),
            SizedBox(height: 20),
            TextButton(onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterScreen())
              );
            },
                child: const Text("Регистрация"))
          ],
        ),
      ),
    );
  }
}