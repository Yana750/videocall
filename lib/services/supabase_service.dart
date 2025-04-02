import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:uuid/uuid.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final JitsiMeet jitsiMeet = JitsiMeet();
  String? get currenUserId => _supabase.auth.currentUser?.id;

  // Аутентификация
  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Метод для получения каналов, созданных текущим пользователем
  Future<List<dynamic>> getChannels() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Запрос для получения данных
    final response = await _supabase
        .from('channels')
        .select()
        .eq('created_by', userId);

    // Возвращаем данные из response.data (без проверки ошибок)
    return response as List<dynamic>;
  }

  Stream<List<Map<String, dynamic>>> getChannelsStream() {
    return _supabase
        .from('channels')
        .stream(primaryKey: ['id']) // Подписка на изменения в таблице
        .order('created_at', ascending: false) // Новые каналы сверху
        .map((data) => data.map((channel) => {
      'id': channel['id'],
      'name': channel['name'],
      'member_count': channel['member_count'] ?? 0, // Безопасная обработка null
    }).toList());
  }

  Future<int> _getChannelMemberCount(String channelId) async {
    final response = await _supabase
        .from('channel_member')
        .select('id')
        .eq('channel_id', channelId);

    return response.length; // Количество записей
  }

  Future<void> joinChannel(String channelId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('channel_members').insert({
      'channel_id': channelId,
      'user_id': user.id,
    });
  }

  // Метод для создания канала
  Future<String?> createChannel(String name) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    
    final response = await _supabase.from('channels').insert({'name': name}).select('id').maybeSingle();
    final channelid = response?['id'];  // Теперь метод возвращает ID нового канала
    
    if (channelid != null) {
      await _supabase.from('channel_member').insert({'channel_id': channelid, 'user_id': userId});
    }
    return null;
  }


  //Новый метод для получения email текущего пользователя
  Future<String?> getUserEmail() async {
    final user = _supabase.auth.currentUser;
    return user?.email;
  }

  // Работа с сообщениями
  Future<void> sendMessage(String channelId, String text) async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      print("Ошибка: Пользователь не авторизован.");
      return;
    }

    print("Отправка сообщения от пользователя: $userId в канал: $channelId");

    final response = await _supabase.from('messages').insert({
      'channel_id': channelId,
      'text': text,
      'sender_id': userId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });

    if (response.error != null) {
      print("Ошибка при записи сообщения: ${response.error!.message}");
    } else {
      print("Сообщение успешно записано!");
    }
  }

  // Подписка на обновления в таблице messages
  Stream<List<dynamic>> getMessages(String channelId) {
    final controller = StreamController<List<dynamic>>();

    void fetchMessages() async {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('channel_id', channelId)
          .order('created_at', ascending: true);
      controller.add(response);
    }

    fetchMessages(); // Загружаем текущие сообщения

    // Подключение канал к Supabase Realtime
    final channel = _supabase.realtime.channel('messages_channel');

    channel
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) {
        fetchMessages(); // Загрузка новых сообщений при обновлении
      },
    )
        .subscribe();

    return controller.stream;
  }
}

final supabaseService = SupabaseService();