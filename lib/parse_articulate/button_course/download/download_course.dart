import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutterapptest/parse_articulate/common/file_helpers.dart';

class DownloadCourse {
  final String urlDownload;
  final Function(String, DownloadTaskStatus, int) onChangeDownload;

  final int idCourse;

  DownloadCourse(this.urlDownload, this.onChangeDownload, {this.idCourse});

  String _localPath;
  String taskId;
  ReceivePort _port = ReceivePort();

  Future<void> startDownload() async {
    await _prepare();
    _bindBackgroundIsolate();
    print("_localPath " + _localPath);

    FlutterDownloader.registerCallback(downloadCallback);

    taskId = await FlutterDownloader.enqueue(
      url: urlDownload,
      savedDir: _localPath,
      fileName: FileHelpers.filenameArchive,
      showNotification: false,
      // show download progress in status bar (for Android)
      openFileFromNotification:
          false, // click on notification to open downloaded file (for Android)
    );
  }

  Future<Null> _prepare() async {
    _localPath = await FileHelpers.checkCourseFolderOrCreate(idCourse);
  }

  void _bindBackgroundIsolate() {
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
      if (onChangeDownload != null) onChangeDownload(id, status, progress);
      print("progress 2 " + progress.toString());
    });
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

  void retryDownLoad() {
    FlutterDownloader.retry(taskId: taskId);
  }

  String getFileName() {
    return _localPath + Platform.pathSeparator + FileHelpers.filenameArchive;
  }

  String getPath() {
    return _localPath + Platform.pathSeparator;
  }
}
