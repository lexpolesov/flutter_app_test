import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutterapptest/parse_articulate/unzip_package.dart';

class ButtonDownloadArticulate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ButtonDownloadArticulateState();
}



class _ButtonDownloadArticulateState extends State<ButtonDownloadArticulate> {
  bool loading = false;

  UnZipPackageParse packageParse;

  InAppWebViewController _webViewController;

  String baseUrlTest = "file:///sdcard/Download/content_test_all/index.html";
  String urlTest = "";

  @override
  void initState() {
    super.initState();
    packageParse = UnZipPackageParse(onFinishedParse: onFinishParse);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          SizedBox(
            width: 1,
            height: 1,
            child: InAppWebView(
              initialUrl: "",
              //  initialUrl: "file:///sdcard/Download/content_test_all/index.html",
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
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
                packageParse.addController(controller);
                // loadUrl();
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
                child: loading ? CircularProgressIndicator() : Text("Открыть"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void loadUrl() {
    if (_webViewController != null) {
      //  _webViewController.loadUrl(url: urlTest);

      // _webViewController.is

    }
  }

  void onFinishParse() {
    print("onFinish parse data");
    setState(() {
      loading = false;
    });
  }

  void checkStatus() {
    if (!loading) {
      packageParse.addUrl(baseUrlTest);
      setState(() {
        loading = true;
      });
    }
  }
}
