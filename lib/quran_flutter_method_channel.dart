import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'quran_flutter_platform_interface.dart';

/// An implementation of [QuranFlutterPlatform] that uses method channels.
class MethodChannelQuranFlutter extends QuranFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('quran_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
