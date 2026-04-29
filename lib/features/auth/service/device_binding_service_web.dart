class DeviceBindingService {
  bool get isSupported => false;

  Future<String> getDeviceId() async {
    throw UnsupportedError('Device binding is not supported on web.');
  }

  Future<String> getDeviceName() async {
    return 'Web Browser';
  }
}
