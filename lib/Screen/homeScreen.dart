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
          // Проверка состояния ожидания
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Ошибка загрузки
          if (snapshot.hasError) {
            return Center(child: Text("Ошибка загрузки: ${snapshot.error}"));
          }

          // Нет доступных каналов
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Нет доступных каналов!"));
          }

          final channels = snapshot.data!;

          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];

              // Если member_count почему-то 0, но канал существует, ставим хотя бы 1 (создателя)
              final memberCount = (channel['member_count'] as int? ?? 0) > 0
                  ? channel['member_count']
                  : 1;

              final isMember = channel['is_member'] ?? false;

              return ListTile(
                title: Text(channel['name']),
                subtitle: Text("Участников: $memberCount"),
                trailing: isMember
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