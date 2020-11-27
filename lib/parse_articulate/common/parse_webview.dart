import 'package:flutter_inappwebview/flutter_inappwebview.dart';

abstract class ParseWebView {
  InAppWebViewController controller;

  void addController(InAppWebViewController webViewController) {
    controller = webViewController;
    print("ParseWebView addController");
  }

  void onLoadStop(String url) {
    print("onLoadStop $url");
  }

  void onConsoleMessage(ConsoleMessage consoleMessage) {
    print("onConsoleMessage ${consoleMessage.message}");
  }

  void onLoadError(String url, int code, String message) {
    print("onLoadError $url code $code message $message ");
  }
}
