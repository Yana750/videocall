import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:uuid/uuid.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final JitsiMeet jitsiMeet = JitsiMeet();
  String? get currenUserId => _supabase.auth.currentUser?.id;

  // ✅ Аутентификация
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
        .eq('created_by', userId); // Фильтруем каналы по ID текущего пользователя

    // Возвращаем данные из response.data (без проверки ошибок)
    return response as List<dynamic>;
  }

  // Метод для создания канала
  Future<void> createChannel(String channelName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase.from('channels').insert([
      {
        'name': channelName,
        'created_by': userId,
      }
    ]).select(); // select() вернет данные, если нужно.

    // Проверяем, есть ли ошибка в ответе
    if (response == null || response.isEmpty) {
      throw Exception('Error creating channel: No response or invalid response');
    }

    print('Channel created successfully: $response');
  }

  // ✅ Новый метод для получения email текущего пользователя
  Future<String?> getUserEmail() async {
    final user = _supabase.auth.currentUser;
    return user?.email;
  }

  // ✅ Работа с сообщениями
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

  // ✅ Подписываемся на обновления в таблице messages
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

    // ✅ Подключаем канал к Supabase Realtime
    final channel = _supabase.realtime.channel('messages_channel');

    channel
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) {
        fetchMessages(); // Загружаем новые сообщения при обновлении
      },
    )
        .subscribe();

    return controller.stream;
  }
}

final supabaseService = SupabaseService();