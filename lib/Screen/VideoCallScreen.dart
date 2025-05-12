import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JoinMeetingScreen extends StatefulWidget {
  final String meetingUrl;
  const JoinMeetingScreen({super.key, required this.meetingUrl});

  @override
  _JoinMeetingScreenState createState() => _JoinMeetingScreenState();
}

class _JoinMeetingScreenState extends State<JoinMeetingScreen> {
  final JitsiMeet _jitsiMeet = JitsiMeet();

  @override
  void initState() {
    super.initState();
    _joinMeeting();
  }

  Future<void> _joinMeeting() async {
    try {
      var options = JitsiMeetConferenceOptions(
        room: _extractMeetingId(widget.meetingUrl),
        serverURL: "https://jitsi-connectrm.ru:8443",
        configOverrides: {
          "startWithAudioMuted": false,
          "startWithVideoMuted": false,
          "disableInviteFunctions": true,
        },
      );

      await _jitsiMeet.join(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка подключения: $e")),
      );
    }
  }

  String _extractMeetingId(String url) {
    Uri? uri = Uri.tryParse(url);
    return uri?.pathSegments.isNotEmpty == true ? uri!.pathSegments.last : "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
