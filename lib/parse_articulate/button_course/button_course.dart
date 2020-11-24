import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapptest/parse_articulate/articulate_webview/articulate_webview.dart';

import 'button_course_body.dart';
import 'parse_unzipping_course/common.dart';
import 'parse_unzipping_course/parse_find_question_view.dart';

class ButtonCourse extends StatefulWidget {
  final String url;
  final bool isOffline;

  const ButtonCourse(this.url, {this.isOffline = true});

  @override
  State<StatefulWidget> createState() => _ButtonCourseState();
}

class _ButtonCourseState extends State<ButtonCourse> {
  StatusButtonCourse status;

  @override
  void initState() {
    super.initState();
    if (widget.isOffline) {
      //todo debug
      //status = StatusButtonCourse.LINK;
      status = StatusButtonCourse.READY;
    } else {
      status = StatusButtonCourse.PARSE_COURSE;
      startParseQuestionCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.green,
      child: Stack(
        children: [
          if (status == StatusButtonCourse.PARSE_COURSE)
            ParseFindQuestionView(
                url: widget.url, onFinishedParse: resultParseCourse),
          GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                changeStatusClick();
              },
              child: ButtonCourseBody(status)),
        ],
      ),
    );
  }

  void changeStatusClick() {
    print("changeStatusClick ");
    StatusButtonCourse newStatus;

    switch (status) {
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
    }
    changeState(newStatus);
  }

  void changeState(StatusButtonCourse newStatus) {
    if ((newStatus != null) && (newStatus != status)) {
      setState(() {
        status = newStatus;
        if (status == StatusButtonCourse.DOWNLOAD) {
          startDownLoad();
        }
        if (status == StatusButtonCourse.UNZIP) {
          startUnzip();
        }
        print("changeState " + status.toString());
      });
    }
  }

  Future<void> startDownLoad() async {
    print("startDownLoad");
    Future.delayed(Duration(seconds: 1)).then((value) {
      changeState(StatusButtonCourse.UNZIP);
    });
  }

  Future<void> startUnzip() async {
    print("startUnzip");
    Future.delayed(Duration(seconds: 1)).then((value) {
      changeState(StatusButtonCourse.PARSE_COURSE);
    });
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
      MaterialPageRoute(builder: (context) => ArticulateWebView(widget.url)),
    );
  }
}
