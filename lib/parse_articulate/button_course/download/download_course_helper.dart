import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutterapptest/parse_articulate/common/file_assistant.dart';
import 'package:flutterapptest/parse_articulate/common/permissions.dart';

class DownloadCourseCallback {
  final String idTasks;
  final Function(String, DownloadTaskStatus, int) onChangeDownload;

  DownloadCourseCallback(this.idTasks, this.onChangeDownload);
}

class DownloadCourseManager {
  List<DownloadCourseCallback> _callbacks = [];

  static final DownloadCourseManager _singleton =
      DownloadCourseManager._internal();

  factory DownloadCourseManager() {
    return _singleton;
  }

  DownloadCourseManager._internal() {
    _bindBackgroundIsolate();
  }

  Future<String> startDownload(String urlDownload, int idCourse, int idVersion,
      Function(String, DownloadTaskStatus, int) onChangeDownload) async {
    String _localPath =
        await FileAssistant.checkCourseFolderOrCreate(idCourse, idVersion);
     bool isGrantedPermissions = await Permissions.requestPermissionStorage();

     if(isGrantedPermissions) {
       String taskId = await FlutterDownloader.enqueue(
         url: urlDownload,
         savedDir: _localPath,
         fileName: FileAssistant.filenameArchive,
         showNotification: false,
         openFileFromNotification: false,
       );
       _callbacks.add(DownloadCourseCallback(taskId, onChangeDownload));
       return taskId;
     }
     return null;
  }

  void addCallbackTaskId(String taskId,
      Function(String, DownloadTaskStatus, int) onChangeDownload) {
    _callbacks.add(DownloadCourseCallback(taskId, onChangeDownload));
  }

  void _bindBackgroundIsolate() {
    ReceivePort _port = ReceivePort();
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      //setState((){ });

      if (_callbacks != null) {
        var searchTask = _callbacks
            .firstWhere((element) => element.idTasks == id, orElse: () => null);
        if ((searchTask != null) && (searchTask.onChangeDownload != null))
          searchTask.onChangeDownload(id, status, progress);
      }
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  void unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  void retryDownLoad(String taskId) {
    FlutterDownloader.retry(taskId: taskId);
  }

  Future<List<DownloadTask>> getStatusDownload(String taskId) async {
    String query = "SELECT * FROM task WHERE task_id='$taskId'";
    List<DownloadTask> tasks =
        await FlutterDownloader.loadTasksWithRawQuery(query: query);
    return tasks;
  }
}
