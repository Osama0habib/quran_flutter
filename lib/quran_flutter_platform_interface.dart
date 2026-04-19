import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'quran_flutter_method_channel.dart';

abstract class QuranFlutterPlatform extends PlatformInterface {
  /// Constructs a QuranFlutterPlatform.
  QuranFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static QuranFlutterPlatform _instance = MethodChannelQuranFlutter();

  /// The default instance of [QuranFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelQuranFlutter].
  static QuranFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [QuranFlutterPlatform] when
  /// they register themselves.
  static set instance(QuranFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
