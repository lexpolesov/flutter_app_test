import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutterapptest/parse_articulate/articulate_webview/articulate_webview.dart';
import 'package:flutterapptest/parse_articulate/common/file_assistant.dart';
import 'package:flutterapptest/parse_articulate/common/unzip_assistant.dart';

import 'button_course_body.dart';
import 'download/download_course_helper.dart';
import 'parse_unzipping_course/common.dart';
import 'parse_unzipping_course/parse_find_question_view.dart';

class CourseSettings {
  final String url;
  final int version;
  final bool isOffline;
  final int idCourse;
  StatusButtonCourse status;
  CourseAnalysis analysis;
  String taskId;

  CourseSettings(
      {this.url,
      this.isOffline = true,
      this.idCourse,
      this.version = 1,
      this.status = StatusButtonCourse.CHECK});

  void changeStatus(StatusButtonCourse newStatus) {
    status = newStatus;
    print("status " + status.toString());
  }
}

class CourseAnalysis {
  List<CourseCountQuestion> resultQuizList = [];

  CourseAnalysis(this.resultQuizList);

  int get countTest => resultQuizList.length;

  bool get isEnabledTesting => (resultQuizList.length > 0);

  int get countQuestion => _getCountAllQuestion();

  int _getCountAllQuestion() {
    int count = 0;
    resultQuizList.forEach((element) {
      count = count + element.countQuestion;
    });
    return count;
  }
}

class ButtonCourse extends StatefulWidget {
  final CourseSettings settings;

  const ButtonCourse(this.settings);

  @override
  State<StatefulWidget> createState() => _ButtonCourseState();
}

class _ButtonCourseState extends State<ButtonCourse> {
  CourseSettings get settings => widget.settings;

  int _percentDownload = 0;

  String _linkUnzipForOpen = "";

  @override
  void initState() {
    super.initState();
    startCheckCourse();
  }

  @override
  Widget build(BuildContext context) {
    print("build " + settings.status.toString());
    return Container(
      height: 60,
      color: Colors.green,
      child: Stack(
        children: [
          if (settings.status == StatusButtonCourse.PARSE_COURSE)
            ParseFindQuestionView(
                url: _buildPathName(), onFinishedParse: resultParseCourse),
          GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                changeStatusClick();
              },
              child: ButtonCourseBody(settings.status, _percentDownload)),
        ],
      ),
    );
  }

  //клик по кнопке и изменения действия в зваисимости от статуса
  void changeStatusClick() {
    StatusButtonCourse newStatus;

    switch (settings.status) {
      case StatusButtonCourse.LINK:
        newStatus = StatusButtonCourse.DOWNLOAD;
        break;
      case StatusButtonCourse.DOWNLOAD:
      case StatusButtonCourse.DOWNLOADING:
        break;
      case StatusButtonCourse.DOWNLOAD_ERROR:
        newStatus = StatusButtonCourse.DOWNLOAD;
        break;
      case StatusButtonCourse.UNZIP:
        break;
      case StatusButtonCourse.UNZIP_ERROR:
        newStatus = StatusButtonCourse.UNZIP;
        break;
      case StatusButtonCourse.PARSE_COURSE:
        break;
      case StatusButtonCourse.READY:
        openWebView();
        break;
      case StatusButtonCourse.CHECK:
        break;
    }
    changeState(newStatus);
  }

  //меняем статус и перерисовываем экран
  void changeState(StatusButtonCourse newStatus) {
    if ((newStatus != null) && (newStatus != settings.status)) {
      setState(() {
        settings.changeStatus(newStatus);
        if (settings.status == StatusButtonCourse.DOWNLOAD) {
          startDownLoad();
        }
        if (settings.status == StatusButtonCourse.DOWNLOADING) {
          addCallbackDownloading();
        }
        if (settings.status == StatusButtonCourse.UNZIP) {
          startUnzip();
        }
        print("changeState " + settings.status.toString());
      });
    }
  }

  //StatusButtonCourse.CHECK
  //определние статуса курса
  Future<void> startCheckCourse() async {
    StatusButtonCourse checkStatus;
    if (settings.isOffline) {
      checkStatus = await analysisOfflineStateCourse();
    } else {
      checkStatus = analysisOnlineStateCourse();
    }
    changeState(checkStatus);
  }

  //анализ статуса курса онлайн
  StatusButtonCourse analysisOnlineStateCourse() {
    if (settings.analysis == null) {
      return StatusButtonCourse.PARSE_COURSE;
    }
    return StatusButtonCourse.READY;
  }

  //анализ курса оффлайн
  Future<StatusButtonCourse> analysisOfflineStateCourse() async {
    StatusButtonCourse checkStatus = StatusButtonCourse.LINK;
    print("analysisOfflineStateCourse");
    //проверяем есть ли распакованный файл
    bool checkCourseIndexPage = await FileAssistant.checkUnzipCourseIndexPage(
        settings.idCourse, settings.version);
    if (checkCourseIndexPage) {
      //если распакованный архив есть, проверяем анализ курса
      if (settings.analysis != null) {
        //если анализ есть = статус готов к прохождению
        return StatusButtonCourse.READY;
      } else {
        //если анализа нет = статус провести анализ
        if (_linkUnzipForOpen == "")
          _linkUnzipForOpen =
              (await FileAssistant.getDirectoryPathIdCourseVersion(
                      widget.settings.idCourse, widget.settings.version)) +
                  Platform.pathSeparator;
        return StatusButtonCourse.PARSE_COURSE;
      }
    }
    //если распакованного курса не нашли, проверяем была ли задача на скачивание
    if (settings.taskId != null) {
      List<DownloadTask> searchStatusDownloads =
          await DownloadCourseManager().getStatusDownload(settings.taskId);
      //если нашлась задача смотрим статус
      if (searchStatusDownloads != null) {
        var goodResult = searchStatusDownloads
            .where((element) => element.status == DownloadTaskStatus.complete);
        if ((goodResult != null) && (goodResult.length > 0)) {
          //если нашли задачу с успешной загрузкой то проверяем наличие архива
          bool checkArchiveDownload = await FileAssistant.checkArchive(
              settings.idCourse, settings.version);
          if (checkArchiveDownload) {
            return StatusButtonCourse.UNZIP;
          }
        }
        //если задача в процессе скачивания то подписываются на изменения
        var loadingResult = searchStatusDownloads
            .where((element) => element.status == DownloadTaskStatus.running);
        if ((loadingResult != null) && (loadingResult.length > 0)) {
          return StatusButtonCourse.DOWNLOADING;
        }
      }
    }
    print("analysisOfflineStateCourse exit " + checkStatus.toString());
    return checkStatus;
  }

  //StatusButtonCourse.DOWNLOAD
  //загрузка файла
  Future<void> startDownLoad() async {
    String taskId = await DownloadCourseManager().startDownload(
        widget.settings.url,
        widget.settings.idCourse,
        widget.settings.version,
        onChangeDownload);
    if (taskId == null) {
      changeState(StatusButtonCourse.DOWNLOAD_ERROR);
    } else {
      settings.taskId = taskId;
    }
  }

  //Callback скачивания файла
  void onChangeDownload(String id, DownloadTaskStatus status, int progress) {
    switch (status.value) {
      case 2: //процесс скачивания, получаем процент и передаем в кнопку
        setState(() {
          _percentDownload = progress;
        });
        break;
      case 3: //успешное скачивание
        _percentDownload = 0;
        changeState(StatusButtonCourse.UNZIP);
        break;
      case 4: //ошибка загрузки
        _percentDownload = 0;
        changeState(StatusButtonCourse.DOWNLOAD_ERROR);
        break;
    }
  }

  //StatusButtonCourse.DOWNLOADING
  //привязать callback на изменения по скачиванию
  void addCallbackDownloading() {
    if (settings.taskId != null) {
      DownloadCourseManager()
          .addCallbackTaskId(settings.taskId, onChangeDownload);
    }
  }

  //StatusButtonCourse.UNZIP
  //распаковка курса
  Future<void> startUnzip() async {
    String urlArchive =
        await FileAssistant.getDirectoryPathIdCourseVersionArchive(
            widget.settings.idCourse, widget.settings.version);
    String urlPath = (await FileAssistant.getDirectoryPathIdCourseVersion(
            widget.settings.idCourse, widget.settings.version)) +
        Platform.pathSeparator;
    // unZip(urlArchive, urlPath);

    UnzipAssistant(
        pathArchive: urlArchive,
        path: urlPath,
        onComplete: () {
          _linkUnzipForOpen = urlPath;
          changeState(StatusButtonCourse.PARSE_COURSE);
        },
        onError: () {
          changeState(StatusButtonCourse.UNZIP_ERROR);
        });
  }

/*
  //todo
  void unZip(String pathArchive, String path) {
    // Read the Zip file from disk.
    final bytes = File(pathArchive).readAsBytesSync();

    // Decode the Zip file
    final archive = ZipDecoder().decodeBytes(bytes);

    // Extract the contents of the Zip archive to disk.
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(path + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(path + filename)..create(recursive: true);
      }
    }
    _linkUnzipForOpen = path;
    changeState(StatusButtonCourse.PARSE_COURSE);
  }*/

  //StatusButtonCourse.PARSE_COURSE
  //старт анализа курса перед открытием
  //результат анализа
  void resultParseCourse(List<CourseCountQuestion> resultQuizList) {
    settings.analysis = (resultQuizList != null)
        ? CourseAnalysis(resultQuizList)
        : CourseAnalysis([]);
    changeState(StatusButtonCourse.READY);

    print("onFinish parse data");

    String enableQuiz = "Наличие теста: ";
    if (resultQuizList.isNotEmpty) {
      enableQuiz = enableQuiz + "Да";
    } else {
      enableQuiz = enableQuiz + "Нет";
    }
    print(enableQuiz);
    int countQuestion = 0;
    resultQuizList.forEach((element) {
      print(element.link + " " + element.countQuestion.toString());
      countQuestion = countQuestion + element.countQuestion;
    });
    print("Всего вопросов " + countQuestion.toString());
  }

  //StatusButtonCourse.READY
  //открытие крса
  void openWebView() {
    print("openWebView");
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ArticulateWebView(_buildPathName())),
    );
  }

  String _buildPathName() {
    if (settings.isOffline) {
      return FileAssistant.prefixLocalCourse +
          _linkUnzipForOpen +
          FileAssistant.postfixLocalArchive();
    } else {
      return settings.url;
    }
  }
}
