import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static void requestAllPermissions() async {

    await requestPermissionStorage();
    await requestPermissionAlways();
    await requestPermissionMediaLibrary();
    await requestPermissionAccessMediaLocation();
    await requestPermissionSpech();
    await requestPermissionCamera();

  }

  static Future<bool> requestPermissionStorage() async {
    Permission storage = Permission.storage;
    bool _statusStorage = await storage.status.isGranted;
    if(!_statusStorage){
      _statusStorage = await storage.request().isGranted;
    }
    return _statusStorage;
  }


  static Future<bool> requestPermissionAlways() async {
    Permission notification = Permission.locationAlways;
    bool _statusNotification = await notification.status.isGranted;
    if(!_statusNotification){
      _statusNotification = await notification.request().isGranted;
    }
    return _statusNotification;
  }

  static Future<bool> requestPermissionMediaLibrary() async {
    Permission notification = Permission.mediaLibrary;
    bool _statusNotification = await notification.status.isGranted;
    if(!_statusNotification){
      _statusNotification = await notification.request().isGranted;
    }
    return _statusNotification;
  }

  static Future<bool> requestPermissionAccessMediaLocation() async {
    Permission notification = Permission.accessMediaLocation;
    bool _statusNotification = await notification.status.isGranted;
    if(!_statusNotification){
      _statusNotification = await notification.request().isGranted;
    }
    return _statusNotification;
  }

  static Future<bool> requestPermissionSpech() async {
    Permission notification = Permission.speech;
    bool _statusNotification = await notification.status.isGranted;
    if(!_statusNotification){
      _statusNotification = await notification.request().isGranted;
    }
    return _statusNotification;
  }

  static Future<bool> requestPermissionCamera() async {
    Permission notification = Permission.camera;
    bool _statusNotification = await notification.status.isGranted;
    if(!_statusNotification){
      _statusNotification = await notification.request().isGranted;
    }
    return _statusNotification;
  }
}