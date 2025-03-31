import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'ChannelMeeting.dart';

class ChatProvider with ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  static const Uuid uuid = Uuid(); // Генератор уникальных ID
  List<ChatChannel> channels = [];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  ChatProvider() {
    _loadChannels();
  }
  /// Автоматическая перезагрузка каналов
  Future<void> refreshChannels() async {
    await _loadChannels(); // Загружаем каналы заново
    notifyListeners(); // Уведомляем UI об изменениях
  }

  /// Загружаем каналы из Supabase
  Future<void> _loadChannels() async {
    try {
      final List<dynamic> response = await supabase.from('channel').select();
      channels = response.map((channel) => ChatChannel.fromJson(channel)).toList();
      notifyListeners();
    } catch (e) {
      print("Ошибка загрузки каналов: $e");
    }
  }

  /// Создаем новый канал и обновляем список
  Future<String> createChannel(String name) async {
    try {
      final meetingId = uuid.v4();
      final jitsiUrl = "https://jitsi-connectrm.ru:8443/$meetingId";

      // Добавляем канал в базу данных
      await supabase.from('channel').insert({
        'name': name,
        'meeting_url': jitsiUrl,
      });

      // Обновляем список каналов
      await refreshChannels();

      return jitsiUrl;
    } catch (e) {
      print("Ошибка при создании канала: $e");
      rethrow;
    }
  }

  /// Удаляем канал и обновляем список
  Future<void> deleteChannel(int channelId) async {
    try {
      await supabase.from('channel').delete().eq('id', channelId);
      await refreshChannels(); // Обновляем список после удаления
    } catch (e) {
      print("Ошибка при удалении канала: $e");
      rethrow;
    }
  }

  /// Переименовываем канал и обновляем список
  Future<void> renameChannel(int channelId, String newName) async {
    try {
      await supabase.from('channel').update({'name': newName}).eq('id', channelId);
      await refreshChannels(); // Обновляем список после переименования
    } catch (e) {
      print("Ошибка при переименовании канала: $e");
      rethrow;
    }
  }


  Future<void> addMessageToChannel(int channelId, String message) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception("Пользователь не авторизован");
      }

      // Make sure channelId is an integer
      int validChannelId = int.tryParse(channelId.toString()) ?? 0;
      if (validChannelId == 0) {
        throw Exception("Invalid Channel ID");
      }

      await supabase.from('messages').insert([
        {
          'channel_id': validChannelId, // use validChannelId
          'message': message,
          'user_id': user.id,
          'created_at': DateTime.now().toIso8601String(),
        }
      ]);

      // Update the local list of messages
      final channel = channels.firstWhere((c) => c.id == validChannelId);
      channel.messages.add(message);

      notifyListeners();
    } catch (e) {
      print("Ошибка при отправке сообщения: $e");
    }
  }
}

class ChatChannel {
  final int id;
  String name;
  final String meetingUrl;
  List<String> messages = [];

  ChatChannel({
    required this.id,
    required this.name,
    required this.meetingUrl,
  });

  factory ChatChannel.fromJson(Map<String, dynamic> json) {
    return ChatChannel(
      id: json['id'] as int,
      name: json['name'] as String,
      meetingUrl: json['meeting_url'] as String,
    );
  }
}
