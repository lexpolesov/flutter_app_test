import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutterapptest/parse_articulate/articulate_webview/parse_passing_quiz.dart';
import 'package:flutterapptest/parse_articulate/common/parse_webview.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

class ArticulateWebView extends StatefulWidget {
  final String url;

  ArticulateWebView(this.url);

  @override
  State<StatefulWidget> createState() => _ArticulateWebViewState();
}

class _ArticulateWebViewState extends State<ArticulateWebView> {
  InAppWebViewController _webViewController;
  ParseWebView parsing;
  List<PassingQuiz> passingQuizList;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    passingQuizList = [];
    parsing = ParsePassingQuiz(
        onChangePassing: onChange,
        onFinishPassing: onFinish,
        onExit: exitClick);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Course")),
        body: Stack(
          children: [
            InAppWebView(
              initialUrl: widget.url,
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useShouldOverrideUrlLoading: true,
                    mediaPlaybackRequiresUserGesture: true,
                    debuggingEnabled: true,
                  ),
                  android: AndroidInAppWebViewOptions(
                      allowContentAccess: true,
                      allowFileAccess: true,
                      allowFileAccessFromFileURLs: true,
                      allowUniversalAccessFromFileURLs: true)),
              onWebViewCreated: (InAppWebViewController controller) {
                _webViewController = controller;
                parsing.addController(controller);
                setState(() {
                  isLoading = false;
                });
              },
              onConsoleMessage: (InAppWebViewController controller,
                  ConsoleMessage consoleMessage) {
                print(consoleMessage);
                parsing.onConsoleMessage(consoleMessage);
              },
              onLoadStart: (InAppWebViewController controller, String url) {
                print("load start " + url);
                parsing.onLoadStop(url);
              },
              onLoadError: (InAppWebViewController controller, String url,
                  int code, String message) {
                print("error message " + message);
                parsing.onLoadError(url, code, message);
              },
              onLoadStop: (InAppWebViewController controller, String url) {
                print("onLoadStop " + url);
                parsing.onLoadStop(url);
              },
              shouldOverrideUrlLoading: (controller, request) async {
                var url = request.url;
                print("shouldOverrideUrlLoading url " + url);
                return ShouldOverrideUrlLoadingAction.ALLOW;
              },
            ),
            if (isLoading) Center(child: CircularProgressIndicator()),
          ],
        ));
  }

  void onChange(PassingQuiz passingChange) {
    print("Passing onChange");

    addPassingToList(passingChange);
  }

  void onFinish(PassingQuiz passingFinish) {
    print("Passing onFinish");

    addPassingToList(passingFinish);
  }

  void addPassingToList(PassingQuiz passingChange) {
    var searchItem = passingQuizList.firstWhere(
        (element) => element.uuid == passingChange.uuid,
        orElse: () => null);

    if (searchItem != null) {
      searchItem = passingChange;
    } else {
      passingQuizList.add(passingChange);
    }

    passingQuizList.forEach((element) {
      element.printPassing();
    });
  }

  void exitClick() {
    Navigator.pop(context);
  }
}
