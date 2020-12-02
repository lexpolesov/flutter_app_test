import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> requestPermissionStorage() async {
    Permission storage = Permission.storage;
    bool _statusStorage = await storage.status.isGranted;
    if (!_statusStorage) {
      _statusStorage = await storage.request().isGranted;
    }
    return _statusStorage;
  }
}
