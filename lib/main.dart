import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

 // await Permission.camera.request();
 // await Permission.microphone.request();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: InAppWebViewPage()
    );
  }
}

class InAppWebViewPage extends StatefulWidget {
  @override
  _InAppWebViewPageState createState() => new _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
 // InAppWebViewController _webViewController;

  final Completer<InAppWebViewController> _webViewController =
  Completer<InAppWebViewController>();

  @override
  void initState() {
    super.initState();
    _webViewController.future.then((controller) {
      _loadHtmlFromSD(controller);
      // _loadHtmlOnline(controller);
      // _loadHtmlFromAssets(controller);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("InAppWebView")
        ),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                      initialUrl: "",
                     // initialUrl: "file:///sdcard/Download/content_test_all/index.html",
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          mediaPlaybackRequiresUserGesture: true,
                          debuggingEnabled: true,
                        ),
                        android: AndroidInAppWebViewOptions(
                          allowContentAccess: true,
                          allowFileAccess: true,
                          allowFileAccessFromFileURLs: true,
                          allowUniversalAccessFromFileURLs: true
                        )
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {
                        _webViewController.complete(controller);
                      },
                      androidOnPermissionRequest: (InAppWebViewController controller, String origin, List<String> resources) async {
                        return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
                      }
                  ),
                ),
              ),
            ]))
    );
  }

  Future<void> _loadHtmlFromSD(InAppWebViewController controller) async {
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
      controller.loadUrl(url: sdPath);
    });
  }


  Future<void> _loadHtmlFromAssets(InAppWebViewController controller) async {
    String fileText = await rootBundle.loadString('assets/page5/index.html');
    String theURI = Uri.dataFromString(fileText,
        mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString();

    setState(() {
      print(theURI);
      controller.loadUrl(url: theURI); //"file:///assets/page5/index.html");
    });
  }

  Future<void> _loadHtmlOnline(InAppWebViewController controller) async {
    setState(() {
      controller.loadUrl(url:
          "https://rise.articulate.com/share/CyeHT-yqQBLbKyz9cU8U-l-b2jMsx8PK");
    });
  }

}