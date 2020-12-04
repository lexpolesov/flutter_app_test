import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutterapptest/parse_articulate/common/file_helpers.dart';

class DownloadCourseCallback {
  final String idTasks;
  final Function(String, DownloadTaskStatus, int) onChangeDownload;

  DownloadCourseCallback(this.idTasks, this.onChangeDownload);
}

class DownloadCourseHelper {

  List<DownloadCourseCallback> callbacks = [];

  static final DownloadCourseHelper _singleton =
      DownloadCourseHelper._internal();

  factory DownloadCourseHelper() {
    return _singleton;
  }

  DownloadCourseHelper._internal() {
    _bindBackgroundIsolate();
  }

  Future<String> startDownload(String urlDownload, int idCourse, int idVersion,
      Function(String, DownloadTaskStatus, int) onChangeDownload) async {
    String _localPath =
        await FileHelpers.checkCourseFolderOrCreate(idCourse, idVersion);
    //_bindBackgroundIsolate();
    print("_localPath " + _localPath);

   // FlutterDownloader.registerCallback(downloadCallback);

    String taskId = await FlutterDownloader.enqueue(
      url: urlDownload,
      savedDir: _localPath,
      fileName: FileHelpers.filenameArchive,
      showNotification: false,
      openFileFromNotification: false,
    );
    callbacks.add(DownloadCourseCallback(taskId, onChangeDownload));
    return taskId;
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

      if (callbacks != null) {
        var searchTask = callbacks
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
    print("progress " + progress.toString());
  }

  void unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  void retryDownLoad(String taskId) {
    FlutterDownloader.retry(taskId: taskId);
  }
}
