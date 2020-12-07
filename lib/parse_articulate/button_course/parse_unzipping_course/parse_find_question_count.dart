import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import 'common.dart';

class ParseFindQuestionCount {
  List<CourseCountQuestion> _quizUrls;
  InAppWebViewController _controller;
  Function(List<CourseCountQuestion>) onFinishedParse;
  String _baseUrl = "";
  StatusParseUnzippingStatus statusLoad =
      StatusParseUnzippingStatus.searchIndex;
  int currentQuiz = -1;

  final String _prefixUrl = "#/";
  final String _classListItem = "overview-list-item";
  final String _tagTitle = "title";
  final String _textQuestionBox = "Question box";
  final String _classLink = "overview-list-item__link";
  final String _classButton = "quiz-header__start-quiz brand--color";
  final String _classCounterLabel = "quiz-card__counter brand--color brand--ui";
  final String _href = "href";

  ParseFindQuestionCount({this.onFinishedParse}) {
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
    }
  }

  Future<void> pageLoadStop(String loadStopUrl) async {
    print("loadStopUrl " + loadStopUrl);
    if (statusLoad == StatusParseUnzippingStatus.searchIndex) {
      if (loadStopUrl == (_baseUrl + _prefixUrl)) {
        print("onLoadStop index page");
        _controller.getHtml().then((value) {
          parseStartPage(value);
        });
      }
    }

    if (statusLoad == StatusParseUnzippingStatus.loadQuiz) {
      if (currentQuiz < _quizUrls.length) {
        String urlQuiz = _quizUrls[currentQuiz].link;
        if (loadStopUrl == (_baseUrl + urlQuiz)) {
          print("onLoadStop quiz page");
          _controller.getHtml().then((value) {
            parseQuizPage(value);
          });
        }
      }
    }
  }

  void parseStartPage(String htmlText) {
    dom.Document documentHtml = parse(htmlText);
    var searchListItem = documentHtml.getElementsByClassName(_classListItem);
    print("count list " + searchListItem.length.toString());
    if (searchListItem.length != 0) {
      statusLoad = StatusParseUnzippingStatus.foundIndex;
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
      currentQuiz = -1;
      if (quizMenuElement.isNotEmpty) {
        quizMenuElement.forEach((quizElement) {
          String link = getLink(quizElement);
          if ((link != null) && (link != "")) {
            _quizUrls.add(CourseCountQuestion(link: link));
            print("Course link " + link);
          }
        });
      }

      loadNextQuiz();
    } else {
      statusLoad = StatusParseUnzippingStatus.finishParseQuiz;
      onFinishedParse(_quizUrls);
      _controller.stopLoading();
      _controller.clearCache();
    }
  }

  void parseQuizPage(String htmlText) {
    print("parseQuizPage");
    dom.Document documentHtml = parse(htmlText);

    var searchStartButton = documentHtml.getElementsByClassName(_classButton);
    if (searchStartButton.isNotEmpty) {
      var searchQuestionCounter =
          documentHtml.getElementsByClassName(_classCounterLabel);
      if (searchQuestionCounter.isNotEmpty) {
        String textQuestionCounter = searchQuestionCounter.first.text;
        int findIndexOf = textQuestionCounter.indexOf("/");
        if (findIndexOf != -1) {
          String countQuestionAll =
              textQuestionCounter.substring(findIndexOf + 1);
          print("countQuestionAll " + countQuestionAll);

          int count = int.tryParse(countQuestionAll);
          if (count != null) _quizUrls[currentQuiz].setCountQuestion(count);
        }
      }
    }
    loadNextQuiz();
  }

  void loadNextQuiz() {
    currentQuiz++;
    print("loadNextQuiz");
    if ((_quizUrls.isNotEmpty) && (currentQuiz < _quizUrls.length)) {
      statusLoad = StatusParseUnzippingStatus.loadQuiz;
      String urlQuiz = _quizUrls[currentQuiz].link;
      print("loadNextQuiz  " + _baseUrl + urlQuiz);
      _controller.loadUrl(url: _baseUrl + urlQuiz);
      if (Platform.isIOS) {
        _controller.reload();
      }
    } else {
      statusLoad = StatusParseUnzippingStatus.finishParseQuiz;
      onFinishedParse(_quizUrls);
      _controller.stopLoading();
      _controller.clearCache();
    }
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
