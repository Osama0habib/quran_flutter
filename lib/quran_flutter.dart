
import 'quran_flutter_platform_interface.dart';

class QuranFlutter {
  Future<String?> getPlatformVersion() {
    return QuranFlutterPlatform.instance.getPlatformVersion();
  }
}
