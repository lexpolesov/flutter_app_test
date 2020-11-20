import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'common.dart';
import 'parse_find_question_count.dart';

class ParseFindQuestionView extends StatefulWidget {
  final String url;
  final bool isOffline;
  final Function(List<CourseCountQuestion>) onFinishedParse;

  const ParseFindQuestionView({this.url = "", this.isOffline = true, this.onFinishedParse});

  @override
  State<StatefulWidget> createState() => _ParseFindQuestionViewState();
}

class _ParseFindQuestionViewState extends State<ParseFindQuestionView> {

  ParseFindQuestionCount packageParse;

  InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    packageParse = ParseFindQuestionCount(onFinishedParse: widget.onFinishedParse);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                cacheEnabled: false),
            android: AndroidInAppWebViewOptions(
                allowContentAccess: true,
                allowFileAccess: true,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true)),
        onWebViewCreated: (InAppWebViewController controller) {
          _webViewController = controller;
          packageParse.addController(controller);
          packageParse.addUrl(widget.url);
        },
        onConsoleMessage:
            (InAppWebViewController controller, ConsoleMessage consoleMessage) {
          print(consoleMessage);
        },
        onLoadStart: (InAppWebViewController controller, String url) {
          print("load start " + url);
        },
        onLoadError: (InAppWebViewController controller, String url, int code,
            String message) {
          print("error message " + message);
        },
        onLoadStop: (InAppWebViewController controller, String url) {
          print("onLoadStop " + url);
          packageParse.pageLoadStop(url);
        },
      ),
    );
  }
}
