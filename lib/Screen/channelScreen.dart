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

  void _createChannel() async {
    if (_channelNameController.text.isNotEmpty) {
      await supabaseService.createChannel(_channelNameController.text);
      _channelNameController.clear();
      setState(() {}); // Перезагрузка экрана, чтобы отобразить новые каналы
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Каналы")),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: supabaseService.getChannels(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final channels = snapshot.data as List;
                if (channels.isEmpty) {
                  return Center(child: Text('У вас нет созданных каналов.'));
                }
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
          ),
          // Кнопка создания нового канала
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _channelNameController,
                    decoration: InputDecoration(labelText: "Название канала"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _createChannel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}