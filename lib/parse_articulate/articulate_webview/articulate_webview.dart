import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ArticulateWebView extends StatefulWidget {
  final String url;

  ArticulateWebView(this.url);

  @override
  State<StatefulWidget> createState() => _ArticulateWebViewState();
}

class _ArticulateWebViewState extends State<ArticulateWebView> {
  InAppWebViewController _webViewController;

  bool isLoading = true;

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
                          mediaPlaybackRequiresUserGesture: true,
                          debuggingEnabled: true,),
                      android: AndroidInAppWebViewOptions(
                          allowContentAccess: true,
                          allowFileAccess: true,
                          allowFileAccessFromFileURLs: true,
                          allowUniversalAccessFromFileURLs: true)),
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                    setState(() {
                      isLoading = false;
                    });
                    // packageParse.addController(controller);
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
                    //    packageParse.pageLoadStop(url);
                  },
                ),
              if(isLoading) Center(child: CircularProgressIndicator()),
              ],
          )

    );
  }
}
