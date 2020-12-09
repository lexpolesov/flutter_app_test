import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutterapptest/parse_articulate/common/parse_webview.dart';

import 'common.dart';
import 'parse_find_question_count.dart';

class ParseFindQuestionView extends StatefulWidget {
  final String url;
  final bool isOffline;
  final Function(List<CourseCountQuestion>) onFinishedParse;

  const ParseFindQuestionView({this.url = "", this.onFinishedParse, this.isOffline});

  @override
  State<StatefulWidget> createState() => _ParseFindQuestionViewState();
}

class _ParseFindQuestionViewState extends State<ParseFindQuestionView> {
  ParseWebView packageParse;

  InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    packageParse =
        AnalysisParseWebView(onFinishedParse: widget.onFinishedParse, isOffline: widget.isOffline);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      height: 1,
      child: InAppWebView(
        initialUrl: widget.url,
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
        },
        onConsoleMessage:
            (InAppWebViewController controller, ConsoleMessage consoleMessage) {
          packageParse.onConsoleMessage(consoleMessage);
        },
        onLoadError: (InAppWebViewController controller, String url, int code,
            String message) {
          print("error message " + message);
          packageParse.onLoadError(url, code, message);
        },
        onLoadStop: (InAppWebViewController controller, String url) {
          print("onLoadStop " + url);
          packageParse.onLoadStop(url);
          //packageParse.pageLoadStop(url);
        },
      ),
    );
  }
}
