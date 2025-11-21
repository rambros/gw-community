import 'package:just_audio_background/just_audio_background.dart';

/// Initializes background audio notifications for the application.
Future<void> initAudioService() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
}
