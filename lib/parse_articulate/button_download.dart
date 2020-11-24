import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

import 'button_course/parse_unzipping_course/common.dart';
import 'button_course/parse_unzipping_course/parse_find_question_count.dart';

class ButtonDownloadArticulate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ButtonDownloadArticulateState();
}

class _ButtonDownloadArticulateState extends State<ButtonDownloadArticulate> {
  bool loading = false;

  ParseFindQuestionCount packageParse;

  InAppWebViewController _webViewController;

  String urlTest = "";

  List<Widget> widgets = [];

  @override
  void initState() {
    super.initState();
    packageParse = ParseFindQuestionCount(onFinishedParse: onFinishParse);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              SizedBox(
                width: 1,
                height: 1,
                child: InAppWebView(
                  initialUrl: "",
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                          mediaPlaybackRequiresUserGesture: true,
                          debuggingEnabled: true,
                          useShouldOverrideUrlLoading: true,
                          useShouldInterceptAjaxRequest: true,
                          useShouldInterceptFetchRequest: true,
                          clearCache: true,
                          cacheEnabled: false
                          ),
                      android: AndroidInAppWebViewOptions(
                          allowContentAccess: true,
                          allowFileAccess: true,
                          allowFileAccessFromFileURLs: true,
                          allowUniversalAccessFromFileURLs: true)),
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                    packageParse.addController(controller);
                    // loadUrl();
                  },
                  onConsoleMessage: (InAppWebViewController controller,
                      ConsoleMessage consoleMessage) {
                    print(consoleMessage);
                  },
                  onLoadStart: (InAppWebViewController controller, String url) {
                    print("load start " + url);
                  },
                  onLoadError: (InAppWebViewController controller, String url,
                      int code, String message) {
                    print("error message " + message);
                  },
                  onLoadStop: (InAppWebViewController controller, String url) {
                    print("onLoadStop " + url);
                    packageParse.pageLoadStop(url);
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    checkStatus(); // loading = !loading;
                  });
                },
                child: Container(
                  height: 60,
                  color: Colors.amber,
                  width: MediaQuery.of(context).size.width / 3 * 2,
                  child: Center(
                    child:
                        loading ? CircularProgressIndicator() : Text("Открыть"),
                  ),
                ),
              ),
            ],
          ),
        ),
        ...widgets
      ],
    );
  }

  void onFinishParse(List<CourseCountQuestion> quizList) {
    print("onFinish parse data");
    _webViewController.stopLoading();
    _webViewController.clearCache();
    String enableQuiz = "Наличие теста: ";
    if (quizList.isNotEmpty) {
      enableQuiz = enableQuiz + "Да";
    } else {
      enableQuiz = enableQuiz + "Нет";
    }
    widgets.add(Text(enableQuiz));
    int countQuestion = 0;
    quizList.forEach((element) {
      widgets.add(Text(element.link + " " + element.countQuestion.toString()));
      countQuestion = countQuestion + element.countQuestion;
    });
    widgets.add(Text("Всего вопросов " + countQuestion.toString()));
    setState(() {
      loading = false;
    });
  }

  Future<void> checkStatus() async {
    if (!loading) {
      packageParse.addUrl(await getUrl());
      setState(() {
        loading = true;
      });
    }
  }

  Future<String> getUrl() async {
    String sdPath = "";

    if (Platform.isAndroid) {
      sdPath = "file:///sdcard/Download/content_test_all/index.html";
    }

    if (Platform.isIOS) {
      sdPath = (await getApplicationDocumentsDirectory()).path + "/QuizAll";
      bool isExist = await Directory(sdPath).exists();
      print(isExist);
      if (!isExist) {
        bool isExistNew =
            await (await Directory(sdPath).create(recursive: true)).exists();

        print(isExistNew);
      }
      sdPath = "file://" + sdPath + "/index.html";
    }
    return sdPath;
    // return "file:///Users/lex/Library/Developer/CoreSimulator/Devices/5AF42257-85D1-4776-B3A0-EFE7DF074D38/data/Containers/Data/Application/C75DA170-4FEB-4AF1-B347-4B50D32DEB20/Documents/QuizAll/index.html#/lessons/SzlvuoeY009MZ-gwKL8Kvl7RwwFM7JgD";
  }
}
