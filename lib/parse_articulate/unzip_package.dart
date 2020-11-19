import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

enum StatusLoad {searchIndex, foundIndex, findQuiz}

class UnZipPackageParse {
  List<CourseParseUnZip> _quizUrls;
  InAppWebViewController _controller;
  VoidCallback onFinishedParse;
  String _baseUrl = "";
  StatusLoad statusLoad = StatusLoad.searchIndex;
  int currentQuiz = 0;

  final String _prefixUrl = "#/";
  final String _classListItem = "overview-list-item";
  final String _tagTitle = "title";
  final String _textQuestionBox = "Question box";
  final String _classLink = "overview-list-item__link";
  final String _href = "href";

  UnZipPackageParse({this.onFinishedParse}) {
    print("UnZipPackageParse create");
    _quizUrls = [];
  }

  void addController(InAppWebViewController controller) {
    _controller = controller;
  }

  void addUrl(String url) {
    _baseUrl = url;
    _loadStartPage();
  }

  void _loadStartPage() {
    if (_controller != null) {
      print("_baseUrl " + _baseUrl);
      _controller.loadUrl(url: _baseUrl);
      // _controller.
    }

    //Future.delayed(const Duration(milliseconds: 3000), () {
    //   onFinishedParse();
    // });
  }

  Future<void> pageLoadStop(String loadStopUrl) async {
    print("loadStopUrl " + loadStopUrl);
    if (statusLoad == StatusLoad.searchIndex) {
      if (loadStopUrl == (_baseUrl + _prefixUrl)) {
        print("load contains");
        _controller.getHtml().then((value) {
          print("_controller.getHtml().then((value)");
          print(value);
          parseStartPage(value);
        });
      }
    }

    // bool isLoading = await _controller.isLoading();
    //  print("isLoading " + isLoading.toString());
  }

  void parseStartPage(String htmlController) {
    dom.Document documentHtml = parse(htmlController);

    var searchListItem = documentHtml.getElementsByClassName(_classListItem);
    print("count list " + searchListItem.length.toString());
    if (searchListItem.length != 0) {
      statusLoad = StatusLoad.foundIndex;
      List<dom.Element> quizMenuElement = [];
      searchListItem.forEach((element) {
        var quizSearch = element
            .getElementsByTagName(_tagTitle)
            .where((searchElement) => searchElement.text == _textQuestionBox);
        if ((quizSearch != null) && (quizSearch.isNotEmpty)) {
          quizMenuElement.add(element);
        }
      });

      print("quizMenuElement count " + quizMenuElement.length.toString());

      _quizUrls.clear();
      currentQuiz = 0;
      if (quizMenuElement.isNotEmpty) {
        quizMenuElement.forEach((quizElement) {
          String link = getLink(quizElement);
          if ((link != null) && (link != "")) {
            _quizUrls.add(CourseParseUnZip(link: link));
            print("Course link " + link);
          }
        });
      }



    }
  }

  void goToLink(){

  }

  String getLink(dom.Element element) {
    var searchLink = element.getElementsByClassName(_classLink);
    if ((searchLink != null) && (searchLink.isNotEmpty)) {
      String link = searchLink.first.attributes[_href];
      return link;
    }
    return null;
  }

}

class CourseParseUnZip {
  String link;
  int countQuestion;

  CourseParseUnZip({this.link}) {
    countQuestion = 0;
  }

  void setCountQuestion(int count) {
    countQuestion = count;
  }
}
