import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExternalAuthScreen extends StatefulWidget {
  const ExternalAuthScreen({super.key});

  @override
  State<ExternalAuthScreen> createState() => _ExternalAuthScreenState();
}

class _ExternalAuthScreenState extends State<ExternalAuthScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://joinrm-svz.ru/join/54abgjaba2l5otejrejrgh3v/'))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          print('Загрузка завершена: $url');
        },
      ));
  }


  Future<void> _saveToSupabase(String email, String userId) async {
    final supabase = Supabase.instance.client;

    final existing = await supabase
        .from('external_users')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('external_users').insert({
        'email': email,
        'external_user_id': int.parse(userId),
      });
    } else {
      await supabase.from('external_users').update({
        'external_user_id': int.parse(userId),
      }).eq('email', email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход в систему')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          // if (_isLoading)
          //   Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}