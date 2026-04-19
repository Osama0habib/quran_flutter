import 'package:quran_bridge_platform_interface/quran_bridge_platform_interface.dart';

/// Registers the iOS implementation as the default platform instance.
class QuranBridgeIos extends MethodChannelQuranBridge {
  static void registerWith() {
    QuranBridgePlatform.instance = QuranBridgeIos();
  }
}
