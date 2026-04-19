import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'package:quran_flutter/quran_flutter_platform_interface.dart';
import 'package:quran_flutter/quran_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockQuranFlutterPlatform
    with MockPlatformInterfaceMixin
    implements QuranFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final QuranFlutterPlatform initialPlatform = QuranFlutterPlatform.instance;

  test('$MethodChannelQuranFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelQuranFlutter>());
  });

  test('getPlatformVersion', () async {
    QuranFlutter quranFlutterPlugin = QuranFlutter();
    MockQuranFlutterPlatform fakePlatform = MockQuranFlutterPlatform();
    QuranFlutterPlatform.instance = fakePlatform;

    expect(await quranFlutterPlugin.getPlatformVersion(), '42');
  });
}
