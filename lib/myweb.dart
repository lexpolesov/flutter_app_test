import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PfizerWebView extends StatefulWidget {
  final String contentHtml;
  final String titleAppBar;

  PfizerWebView({this.contentHtml, this.titleAppBar});

  @override
  _PfizerWebViewState createState() => _PfizerWebViewState();
}

class _PfizerWebViewState extends State<PfizerWebView> {
  WebViewController webViewController;
  bool isLoading = true;
  double _height = 1;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        SizedBox(
          height: _height,
          child: WebView(
            initialUrl: 'about:blank',
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (String value) async {
              double height = double.parse(
                  await webViewController.evaluateJavascript(
                      "document.documentElement.scrollHeight;"));
              setState(() {
                isLoading = false;
                _height = height;
              });
            },
            onWebViewCreated: (WebViewController webViewController) {
              this.webViewController = webViewController;
              _loadHtml(widget.contentHtml);
            },
          ),
        ),
      ],
    );
  }

  void _loadHtml(String html) async {
    webViewController.loadUrl(Uri.dataFromString(html,
        mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
