import 'dart:math';

import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JitsiService {
  final JitsiMeet jitsiMeet = JitsiMeet();
  final supabase = Supabase.instance.client;

  // Получение ссылки на встречу из базы
  Future<String?> getMeetingUrl(String channelId) async {
    final response = await supabase
        .from('channels')
        .select('meeting_url')
        .eq('id', channelId)
        .maybeSingle();

    return response?['meeting_url'];
  }

  //Создание новой видеовстречи (если её нет)
  Future<String> createMeeting(String channelId) async {
    final existingUrl = await getMeetingUrl(channelId);
    if (existingUrl != null) return existingUrl;

    String randomMeetingId = _generateRandomMeetingId();
    String meetingUrl = "https://jitsi-connectrm.ru:8443/$randomMeetingId";

    await supabase.from('channels').update({'meeting_url': meetingUrl}).eq('id', channelId);
    return meetingUrl;
  }

  // Генерация случайного ID встречи
  String _generateRandomMeetingId() {
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    return List.generate(8, (index) => chars[Random().nextInt(chars.length)]).join();
  }
  // Сохранение ссылки видеовстречи в базу данных
  Future<void> saveMeetingUrl(String channelId, String meetingUrl) async {
    await supabase.from('channels').update({'meeting_url': meetingUrl}).eq('id', channelId);
  }
}

final jitsiService = JitsiService();