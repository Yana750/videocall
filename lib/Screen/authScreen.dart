import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'mainScreen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signIn() async {
    await supabaseService.signIn(emailController.text, passwordController.text);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
  }

  Future<void> signUp() async {
    await supabaseService.signUp(emailController.text, passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Вход")),
      body: Column(
        children: [
          TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
          TextField(controller: passwordController, decoration: InputDecoration(labelText: "Пароль"), obscureText: true),
          ElevatedButton(onPressed: signIn, child: Text("Войти")),
          TextButton(onPressed: signUp, child: Text("Создать аккаунт")),
        ],
      ),
    );
  }
}