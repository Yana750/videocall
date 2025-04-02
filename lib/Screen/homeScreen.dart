import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Главная")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabaseService.getChannelsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Ошибка загрузки: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Нет доступных каналов."));
          }

          final channels = snapshot.data!;

          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];

              return ListTile(
                title: Text(channel['name']),
                subtitle: Text("Участников: ${channel['member_count']}"),
                trailing: channel['is_member']
                    ? const Text("Вы уже в канале")
                    : ElevatedButton(
                  onPressed: () async {
                    await supabaseService.joinChannel(channel['id']);
                  },
                  child: const Text("Присоединиться"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}