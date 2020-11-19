import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

class ParseArticulateWidget extends StatefulWidget {
  final InAppWebViewController controller;

  const ParseArticulateWidget({this.controller});

  @override
  State<StatefulWidget> createState() => _ParseArticulateWidgetState();
}


class _ParseArticulateWidgetState extends State<ParseArticulateWidget> {
  final Duration durationUpdate = Duration(milliseconds: 300);
  Timer _timer;

  bool isAttachTest = false;
  int percentCourse = 0;

  InAppWebViewController get getController => widget.controller;

  final String tagTitle = "title";
  final String iconQuestionText = "Question box";

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Наличие теста " + (isAttachTest ? "Есть" : "Нет")),
        Text("Процент прохождения $percentCourse"),
        Text("ParseArticulateWidget"),
      ],
    );
  }

  @override
  void dispose() {
    if (_timer != null) _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = new Timer.periodic(durationUpdate, (Timer timer) {
      parseHtml();
    });
  }

  void parseHtml() {
    if (getController != null) {
      getController.getHtml().then((value) {
        print("test getHtml");

        dom.Document documentHtml = parse(value);

        bool isFindTest = findTest(documentHtml);
        int percent = findPercent(documentHtml);
       // goToLink(documentHtml);
        /*
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
*/
        checkRepaintChangeData(isFindTest: isFindTest, percent: percent);
      });
    }
  }

  bool findTest(dom.Document doc) {
    var searchTest = doc
        .getElementsByTagName(tagTitle)
        .where((element) => element.text == iconQuestionText);
    if ((searchTest != null) && (searchTest.isNotEmpty)) {
      //print("list count" + searchTest.length.toString());
      return true;
    }
    // print("count searchTest " + searchTest.length.toString());
    return false;
  }

  int findPercent(dom.Document doc) {
    String nameTag = "progress-bar__percentage-bottom";
    String percentChar = "%";
    var searchPercent = doc.getElementsByClassName(nameTag).firstWhere(
        (element) => element.text.contains(percentChar),
        orElse: () => null);
    if (searchPercent != null) {
      //print("list count" + searchTest.length.toString());

      int indexId = searchPercent.text.indexOf(percentChar);
      if (indexId != -1) {
        String percentProgressBarStr = searchPercent.text.substring(0, indexId);
        int percentProgressBar = int.tryParse(percentProgressBarStr);
        if (percentProgressBar != null) {
          return percentProgressBar;
        }
      }
    }
    // print("count searchTest " + searchTest.length.toString());
    return 0;
  }

  void goToLink(dom.Document doc) {
    var searchTest = doc
        .getElementsByClassName("overview-list-item__link");
    if ((searchTest != null) && (searchTest.isNotEmpty)) {
      print("searchTest.first.text");
      var sfsd = searchTest.first.attributes["href"];
      print(sfsd);

      getController.getUrl().then((value) {
        print(value  + sfsd);
        getController.loadUrl(url: (value  + sfsd.substring(2)));
        _timer.cancel();
      });

      //print("list count" + searchTest.length.toString());
     // return true;
    }
    // print("count searchTest " + searchTest.length.toString());
   // return false;
  }

  void checkRepaintChangeData({bool isFindTest, int percent}) {
    bool isRepaint = false;
    if (isFindTest != isAttachTest) {
      isRepaint = true;
      isAttachTest = isFindTest;
      //todo callback
    }
    if (percent != percentCourse) {
      isRepaint = true;
      percentCourse = percent;
      //todo callback
    }
    if (isRepaint) {
      setState(() {});
    }
  }
}
