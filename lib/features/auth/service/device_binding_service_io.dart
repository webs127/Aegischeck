import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceBindingService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  bool get isSupported => Platform.isAndroid || Platform.isIOS;

  Future<String> getDeviceId() async {
    if (!isSupported) {
      throw UnsupportedError('Device binding is not supported on this platform.');
    }

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      final androidId = androidInfo.id;
      if (androidId.isEmpty) {
        throw Exception('Unable to resolve Android device identifier.');
      }
      return androidId;
    }

    final iosInfo = await _deviceInfo.iosInfo;
    final identifier = iosInfo.identifierForVendor;
    if (identifier == null || identifier.isEmpty) {
      throw Exception('Unable to resolve iOS device identifier.');
    }
    return identifier;
  }

  Future<String> getDeviceName() async {
    if (!isSupported) {
      return 'Unsupported Device';
    }

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return '${androidInfo.manufacturer} ${androidInfo.model}'.trim();
    }

    final iosInfo = await _deviceInfo.iosInfo;
    return '${iosInfo.name} ${iosInfo.model}'.trim();
  }
}
