import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutterapptest/old/button_download.dart';
import 'package:flutterapptest/old/parse_articulate_widget.dart';
import 'package:html/parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/parser.dart' show parse;

import 'parse_articulate/button_course/button_course.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );

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
    return MaterialApp(home: InAppWebViewPage());
  }
}

class InAppWebViewPage extends StatefulWidget {
  @override
  _InAppWebViewPageState createState() => new _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  // InAppWebViewController _webViewController;

  InAppWebViewController _webViewController;
  bool loadnext = true;

  bool urlLoaded = false;
  String url = "";
  String urlDownload = "https://pfizer-revmo-backend.madbrains.ru/storage/files/i5Jw6CdWY4fRIflknegRv6hYWLso0ftBiGpwcWRR.zip";//"https://www.7-zip.org/a/7za920.zip";//"https://static.tildacdn.com/tild3537-6439-4438-a566-333966303539/logo.svg";

  @override
  void initState() {
    super.initState();
    //  _webViewController.future.then((controller) {
    //  _loadHtmlFromSD(_webViewController);
    // _loadHtmlOnline(controller);
    // _loadHtmlFromAssets(controller);
    //  });
    getUrl().then((value) {
      setState(() {
        urlLoaded = true;
        url = value;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("InAppWebView")),
      body: Container(
          height: 60,
          width: MediaQuery.of(context).size.width * 0.7,
          child: urlLoaded
              ? ButtonCourse(url, urlDownload, 55, isOffline: true, )
              : CircularProgressIndicator()),
      /*Container(
            child: Column(children: <Widget>[

              Expanded(
                child: Container(
                  child: InAppWebView(

                      onLoadStart: (InAppWebViewController controller,
                          String url) {
                        print("test onLoadStart");
                      },
                      onAjaxProgress: (InAppWebViewController controller,
                          AjaxRequest ajaxRequest) {
                        print("test onAjaxProgress");
                      },

                      onCreateWindow: (InAppWebViewController controller,
                          CreateWindowRequest createWindowRequest) {
                        print("test onCreateWindow");
                        return;
                      },
                      onPageCommitVisible: (InAppWebViewController controller,
                          String url) {
                        print("test onPageCommitVisible");
                      },
                      onTitleChanged: (InAppWebViewController controller,
                          String title) {
                        print("test onTitleChanged");
                      },
                      onLoadResource: (InAppWebViewController controller,
                          LoadedResource resource) {
                        print("test onLoadResource");
                      },
                      onProgressChanged: (InAppWebViewController controller,
                          int progress) {
                        print("test onProgressChanged");
                        if((progress == 100) && loadnext){
                          controller.getHtml().then((value) {
                            var doc = parse(value);
                            var searchTest = doc
                                .getElementsByClassName("overview-list-item__link");
                            if ((searchTest != null) && (searchTest.isNotEmpty)) {
                              print("searchTest.first.text");
                              var sfsd = searchTest.first.attributes["href"];
                              print(sfsd);

                              controller.getUrl().then((value) {
                                print(value  + sfsd.substring(2));
                                controller.loadUrl(url: (value  + sfsd.substring(2)));
                                loadnext = false;
                              });

                            }
                          });
                        }

                      },
                      onPrint: (InAppWebViewController controller, String url) {
                        print("test onPrint");
                      },

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
                       // _webViewController.complete(controller);
                        _webViewController = controller;
                        _loadHtmlFromSD(_webViewController);

                      },
                      onLoadStop: (InAppWebViewController controller,
                          String url) {
                        print("test onLoadStop");/*
                        controller.getHtml().then((value) {
                          print("test getHtml");
                          var document = parse(value);
                         // var lsitQuery = document.querySelectorAll("progress-bar__percentage-bottom");
                          var frView = document.getElementsByClassName("fr-view");
                          print("frView");
                          print(document.getElementsByClassName("fr-view").length);


                          if (frView.isNotEmpty){
                            frView.forEach((element) {
                              print(element.text);
                            });
                          }

                          var progressBar = document.getElementsByClassName("progress-bar__percentage-bottom");
                          print("progressBar");
                          print(progressBar.length);


                          if (progressBar.isNotEmpty){
                            progressBar.forEach((element) {
                              print(element.text);
                            });
                          }
                         // print(document.getElementsByClassName("fr-view").first);

                        });*/
                     //   controller.evaluateJavascript(
                     //       source: "(function(){Flutter.postMessage(window.document.body.outerHTML)})();");
                    //    controller.addJavaScriptHandler(handlerName: "Flutter", callback: printJava());
                      },
                      androidOnPermissionRequest: (
                          InAppWebViewController controller, String origin,
                          List<String> resources) async {
                        return PermissionRequestResponse(resources: resources,
                            action: PermissionRequestResponseAction.GRANT);
                      }
                  ),
                ),
              ),
              ParseArticulateWidget(controller: _webViewController,)
            ]))*/
    );
  }

  void printJava() {
    print("print Java");
  }

  JavascriptChannel _extractDataJSChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Flutter',
      onMessageReceived: (JavascriptMessage message) {
        String pageBody = message.message;
        print('page body: $pageBody');
      },
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
      // controller.getHtml().then((value) => print(value));
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
      controller.loadUrl(
          url:
              "https://rise.articulate.com/share/CyeHT-yqQBLbKyz9cU8U-l-b2jMsx8PK");
    });
  }

  Future<String> getUrl() async {
    String sdPath = "";

    if (Platform.isAndroid) {
      //sdPath = "file:///sdcard/Download/course_tincat/index.html";
    //  sdPath = "file:///sdcard/Download/content_test_all/index.html";

      sdPath = "file:///sdcard/Download/content_etalon/index.html";
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
