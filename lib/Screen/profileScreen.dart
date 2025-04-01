import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login.dart';

class ProfileScreen extends StatelessWidget {
  final supabase = Supabase.instance.client;

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text("Вы")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user?.userMetadata?['avatar_url'] ??
                  "https://www.gravatar.com/avatar"),
            ),
            SizedBox(height: 10),
            Text(user?.email ?? "Неизвестный"),
            SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            await signOut();  // Выполняем выход (если нужно)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),  // Переход на LoginScreen
            );
          },
          child: Text("Выйти"),
        )
          ],
        ),
      ),
    );
  }
}