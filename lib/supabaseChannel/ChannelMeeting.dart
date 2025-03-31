import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiMeetPage extends StatefulWidget {
  final String roomName;
  final String? serverUrl;
  final String? userDisplayName;
  final String? userEmail;

  const JitsiMeetPage({
    Key? key,
    required this.roomName,
    this.serverUrl = "https://meet.jit.si",
    this.userDisplayName,
    this.userEmail,
  }) : super(key: key);

  @override
  _JitsiMeetPageState createState() => _JitsiMeetPageState();
}

class _JitsiMeetPageState extends State<JitsiMeetPage> {
  final JitsiMeet _jitsiMeet = JitsiMeet();
  bool _isMeetingJoined = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _joinMeeting();
    });
  }

  Future<void> _joinMeeting() async {
    if (_isMeetingJoined || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final user = JitsiMeetUserInfo(
        displayName: widget.userDisplayName,
        email: widget.userEmail,
      );

      final options = JitsiMeetConferenceOptions(
        room: widget.roomName,
        serverURL: widget.serverUrl,
        userInfo: user,
        configOverrides: {
          "startWithAudioMuted": false,
          "startWithVideoMuted": false,
          "subject": "Video Call",
        },
        featureFlags: {
          "unsafe-room-warning.enabled": false,
          "welcomepage.enabled": false,
          "toolbox.alwaysVisible": false,
        },
      );

      await Future.delayed(const Duration(seconds: 1)); // Задержка перед запуском

      await _jitsiMeet.join(options);

      setState(() {
        _isMeetingJoined = true;
        _isLoading = false;
      });
    } catch (error) {
      _onConferenceError(error.toString());
    }
  }

  void _endMeeting() {
    if (_isMeetingJoined) {
      setState(() {
        _isMeetingJoined = false;
      });
      Navigator.pop(context);
    }
  }

  void _onConferenceError(dynamic error) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: ${error.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Видеозвонок"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _endMeeting,
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isMeetingJoined)
              ElevatedButton(
                onPressed: _joinMeeting,
                child: const Text("Присоединиться к звонку"),
              ),
            if (_isMeetingJoined)
              Column(
                children: [
                  const Text(
                    "Идет видеозвонок...",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _endMeeting,
                    child: const Text("Завершить звонок"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}