import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapptest/permission.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'myweb.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BrowserPage(),
    );
  }
}

class BrowserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    Permissions.requestAllPermissions();
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text("Asna quiz")),
        child: SafeArea(
          child: WebView(
            initialUrl: "",
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            javascriptChannels: <JavascriptChannel>[
              _toasterJavascriptChannel(context),
            ].toSet(),
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            navigationDelegate: (NavigationRequest request) {
              String url = request.url.toString();
              print('Page started loading: $url');
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              print('Page started loading: $url');
            },
            onPageFinished: (String url) {
              print('Page finished loading: $url');
            },
            gestureNavigationEnabled: true,
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ));
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Print',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          print("message.message " + message.message);
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _controller.future.then((controller) {
      _loadHtmlFromSD(controller);
      // _loadHtmlOnline(controller);
      // _loadHtmlFromAssets(controller);
    });
  }

  Future<void> _loadHtmlFromAssets(WebViewController controller) async {
    String fileText = await rootBundle.loadString('assets/page5/index.html');
    String theURI = Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString();

    setState(() {
      print(theURI);
      controller.loadUrl(theURI); //"file:///assets/page5/index.html");
    });
  }

  Future<void> _loadHtmlOnline(WebViewController controller) async {
    setState(() {
      controller.loadUrl(
          "https://rise.articulate.com/share/CyeHT-yqQBLbKyz9cU8U-l-b2jMsx8PK");
    });
  }

  Future<void> _loadHtmlFromSD(WebViewController controller) async {
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

    setState(() {
      print(sdPath);
      controller.loadUrl(sdPath);
    });
  }
}
