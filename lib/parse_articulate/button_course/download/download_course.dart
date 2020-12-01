import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class DownloadCourse {
  final String urlDownload;
  final Function(String, DownloadTaskStatus, int) onChangeDownload;

  DownloadCourse(this.urlDownload, this.onChangeDownload);

  bool _isLoading;
  bool _permissionReady;
  String _localPath;
  String taskId;
  ReceivePort _port = ReceivePort();

  Future<void> startDownload() async {

    await _prepare();
    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);

     taskId = await FlutterDownloader.enqueue(
      url: urlDownload,
      savedDir: _localPath,
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );

  }

  Future<Null> _prepare() async {

    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);

    bool hasExisted = await savedDir.exists();

    if (!hasExisted) {
      savedDir.create();
    }
  }



  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }


  void _bindBackgroundIsolate() {

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
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

   // if(onChangeDownload != null)

    print("progress " + progress.toString());
  }

  void unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  void retryDownLoad(){

    FlutterDownloader.retry(taskId: taskId);

  }


}


