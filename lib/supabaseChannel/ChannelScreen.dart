import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ChatProvider.dart';
import 'ChatDetailScreen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Каналы")),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return ListView.builder(
            itemCount: chatProvider.channels.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: () async {
                  // Показываем контекстное меню при долгом нажатии
                  await _showChannelMenu(context, chatProvider.channels[index]);
                },
                child: ListTile(
                  title: Text(chatProvider.channels[index].name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          channel: chatProvider.channels[index],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showCreateChannelDialog(context);
        },
      ),
    );
  }

  void _showCreateChannelDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Создать канал"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () async {
                if (controller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Имя канала не может быть пустым")),
                  );
                  return;
                }

                await Provider.of<ChatProvider>(context, listen: false)
                    .createChannel(controller.text);

                Navigator.pop(context);
              },
              child: const Text("Создать"),
            ),
          ],
        );
      },
    );
  }

  // Функция для отображения контекстного меню
  Future<void> _showChannelMenu(BuildContext context, ChatChannel channel) async {
    final result = await showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(90, 90, 90, 90), // Можно изменить позицию меню
      items: [
        PopupMenuItem<int>(
          value: 1,
          child: Text('Переименовать'),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: Text('Удалить'),
        ),
        PopupMenuItem<int>(
          value: 3,
          child: Text('Настройки'),
        ),
      ],
    );

    if (result != null) {
      switch (result) {
        case 1:
        // Переименовать канал
          _renameChannel(context, channel);
          break;
        case 2:
        // Удалить канал
          _deleteChannel(context, channel);
          break;
        case 3:
        // Настройки канала
          _openChannelSettings(context, channel);
          break;
        default:
          break;
      }
    }
  }

  // Переименование канала
  void _renameChannel(BuildContext context, ChatChannel channel) {
    // Создаем StatefulBuilder для правильного управления состоянием
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Контроллер создается внутри StatefulBuilder
        final TextEditingController controller = TextEditingController(text: channel.name);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Переименовать канал'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Новое имя канала',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () async {
                    final newName = controller.text.trim();

                    if (newName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Имя канала не может быть пустым")),
                      );
                      return;
                    }

                    try {
                      await context.read<ChatProvider>().renameChannel(channel.id, newName);
                      Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Ошибка: ${e.toString()}")),
                        );
                      }
                    }
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Удаление канала
  void _deleteChannel(BuildContext context, ChatChannel channel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить канал'),
          content: Text('Вы уверены, что хотите удалить канал "${channel.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await context.read<ChatProvider>().deleteChannel(channel.id);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Ошибка апри удалении: ${e.toString()}")),
                  );
                }
              },
              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Настройки канала (пока пустое окно)
  void _openChannelSettings(BuildContext context, ChatChannel channel) {
    // Здесь можно открыть экран с настройками канала
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Настройки канала'),
          content: Text('Настройки канала: ${channel.name}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }
}