import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutterapptest/parse_articulate/articulate_webview/articulate_webview.dart';
import 'package:flutterapptest/parse_articulate/common/file_helpers.dart';

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

  CourseSettings(
      {this.url, this.isOffline = true, this.idCourse, this.version = 1, this.status = StatusButtonCourse.CHECK});

  void changeStatus(StatusButtonCourse newStatus){
    status = newStatus;
  }
}

class ButtonCourse extends StatefulWidget {
  final CourseSettings settings;

  const ButtonCourse(this.settings);

  @override
  State<StatefulWidget> createState() => _ButtonCourseState();
}

class _ButtonCourseState extends State<ButtonCourse> {
 // StatusButtonCourse status;

  CourseSettings get settings => widget.settings;

 // DownloadCourse assistantDownloadCourse;

  String zipUrl;

  int percent = 0;

  @override
  void initState() {
    super.initState();
    if (widget.settings.isOffline) {
      //todo debug
     // settings.changeStatus(newStatus) = StatusButtonCourse.LINK;
      // status = StatusButtonCourse.READY;
   //   assistantDownloadCourse = DownloadCourse(
   //       widget.urlArchive, onChangeDownload,
    //      idCourse: widget.idCourse);
    } else {
      widget.settings.changeStatus(StatusButtonCourse.PARSE_COURSE);
      startParseQuestionCount();
    }
  }

 /* void checkCourseStatus(){
    if(widget.settings.)
  }*/



  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.green,
      child: Stack(
        children: [
          if (settings.status == StatusButtonCourse.PARSE_COURSE)
            ParseFindQuestionView(
                url: zipUrl, onFinishedParse: resultParseCourse),
          GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                changeStatusClick();
              },
              child: ButtonCourseBody(settings.status, percent)),
        ],
      ),
    );
  }

  void changeStatusClick() {
    print("changeStatusClick ");
    StatusButtonCourse newStatus;

    switch (settings.status) {
      case StatusButtonCourse.LINK:
        newStatus = StatusButtonCourse.DOWNLOAD;
        break;
      case StatusButtonCourse.DOWNLOAD:
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
        newStatus = StatusButtonCourse.DOWNLOAD;
        break;
    }
    changeState(newStatus);
  }

  void changeState(StatusButtonCourse newStatus) {
    if ((newStatus != null) && (newStatus != settings.status)) {
      setState(() {
        settings.changeStatus(newStatus);
        if (settings.status == StatusButtonCourse.DOWNLOAD) {
          startDownLoad();
        }
        if (settings.status == StatusButtonCourse.UNZIP) {
          startUnzip();
        }
        print("changeState " + settings.status.toString());
      });
    }
  }

  Future<void> startDownLoad() async {
    print("startDownLoad");
    await DownloadCourseHelper().startDownload(widget.settings.url, widget.settings.idCourse, widget.settings.version, onChangeDownload);
    // Future.delayed(Duration(seconds: 1)).then((value) {
    //    changeState(StatusButtonCourse.UNZIP);
    // });
  }

  Future<void> startUnzip() async {
    print("startUnzip");
    String urlArchive = await FileHelpers.getDirectoryPathIdCourseVersionArchive(widget.settings.idCourse, widget.settings.version);
    String urlPath = await FileHelpers.getDirectoryPathIdCourseVersion(widget.settings.idCourse, widget.settings.version);
    unZip(urlArchive, urlPath);
   // Future.delayed(Duration(seconds: 1)).then((value) {
      //  changeState(StatusButtonCourse.PARSE_COURSE);
  //  });
  }

  Future<void> startParseQuestionCount() async {
    print("startParseQuestionCount");
    Future.delayed(Duration(seconds: 1)).then((value) {
      changeState(StatusButtonCourse.READY);
    });
  }

  void resultParseCourse(List<CourseCountQuestion> resultQuizList) {
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

  void openWebView() {
    print("openWebView");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ArticulateWebView(zipUrl)),
    );
  }

  void onChangeDownload(String id, DownloadTaskStatus status, int progress) {
    switch (status.value) {
      case 2:
        setState(() {
          percent = progress;
        });
        break;
      case 3:
        changeState(StatusButtonCourse.UNZIP);
        break;
      case 4:
        changeState(StatusButtonCourse.DOWNLOAD_ERROR);

        break;
    }
  }

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
    _buildPathName(path);
    changeState(StatusButtonCourse.PARSE_COURSE);
  }

  void _buildPathName(String path) {
    zipUrl = "file://" + path + "content/index.html";
  }
}
