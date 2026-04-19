import 'package:quran_bridge_platform_interface/quran_bridge_platform_interface.dart';

/// Registers the Android implementation as the default platform instance.
class QuranBridgeAndroid extends MethodChannelQuranBridge {
  static void registerWith() {
    QuranBridgePlatform.instance = QuranBridgeAndroid();
  }
}
