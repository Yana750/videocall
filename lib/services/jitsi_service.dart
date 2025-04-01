import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiService {
  final JitsiMeet jitsiMeet = JitsiMeet();

  Future<void> joinMeeting() async {
    try {
      // Настройки для видеозвонка
      var options = JitsiMeetConferenceOptions(
              serverURL: "http://jitsi-connectrm.ru:8443/",
              room: "testroom",
              configOverrides: {
                "startWithAudioMuted": false,
                "starWithVideoMuted": false,
                "subject": "JitsiMeet",
              },
              featureFlags: {
                "unsaferoomwarning.enabled": false,
              },
            );

      // Подключаемся к видеозвонку
      await jitsiMeet.join(options);
        } catch (error) {
          print("Ошибка подключения: $error");
        }
  }

  // Future<void> joinMeeting(String roomName, {String? userName, String? userEmail}) async {
  //   try {
  //     var options = JitsiMeetConferenceOptions(
  //       serverURL: "http://jitsi-connectrm.ru:8443/",
  //       room: roomName,
  //       userInfo: JitsiMeetUserInfo(
  //         displayName: userName ?? "Guest",
  //         email: userEmail,
  //       ),
  //       configOverrides: {
  //         "startWithAudioMuted": false,
  //         "starWithVideoMuted": false,
  //         "subject": "JitsiMeet",
  //       },
  //       featureFlags: {
  //         "unsaferoomwarning.enabled": false,
  //       },
  //     );
  //
  //     await jitsiMeet.join(options);
  //   } catch (error) {
  //     print("Ошибка подключения: $error");
  //   }
  // }


}

final jitsiService = JitsiService();