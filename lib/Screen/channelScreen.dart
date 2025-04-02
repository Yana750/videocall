import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'channelChatScreen.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key});

  @override
  _ChannelsScreenState createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  final TextEditingController _channelNameController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _channelsFuture;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  void _loadChannels() {
    setState(() {
      _channelsFuture = supabaseService.getChannels().then((data) => data.cast<Map<String, dynamic>>());
    });
  }


  void _showCreateChannelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Создание нового канала"),
          content: TextField(
            controller: _channelNameController,
            decoration: const InputDecoration(hintText: "Введите название канала"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Закрываем диалог
              },
              child: const Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_channelNameController.text.isNotEmpty) {
                  await supabaseService.createChannel(_channelNameController.text);
                  _channelNameController.clear();
                  Navigator.pop(context); // Закрываем диалог
                  _loadChannels(); // Перезагружаем список каналов
                }
              },
              child: const Text("Создать"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Каналы")),
      body: FutureBuilder(
        future: _channelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Ошибка загрузки: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Нет доступных каналов"));
          }

          final channels = snapshot.data!;

          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(channels[index]['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChannelChatScreen(channelId: channels[index]['id']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateChannelDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
