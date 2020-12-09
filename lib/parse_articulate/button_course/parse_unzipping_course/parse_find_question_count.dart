import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutterapptest/parse_articulate/common/parse_webview.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import 'common.dart';

class AnalysisParseWebView extends ParseWebView {

  final Function(List<CourseCountQuestion>) onFinishedParse;
  final bool isOffline;

  List<CourseCountQuestion> _quizUrls;
  String _baseUrl = "";
  StatusBackgroundAnalysis statusLoad =
      StatusBackgroundAnalysis.searchIndex;
  int currentQuiz = -1;

  final String _prefixUrl = "#/";
  final String _classListItem = "overview-list-item";
  final String _tagTitle = "title";
  final String _textQuestionBox = "Question box";
  final String _classLink = "overview-list-item__link";
  final String _classButton = "quiz-header__start-quiz brand--color";
  final String _classCounterLabel = "quiz-card__counter brand--color brand--ui";
  final String _href = "href";

  static const String _consoleTagDomModelChanged = "DOM model changed";

  AnalysisParseWebView({this.isOffline = true, this.onFinishedParse}) {
    print("UnZipPackageParse create");
    _quizUrls = [];
  }

  void addController(InAppWebViewController addController) {
    controller = addController;
    controller.getUrl().then((value) => _baseUrl = value);
    print("add controller");
  }

  /* void addUrl(String url) {
    _baseUrl = url;
    _loadStartPage();
  }*/
/*
  void _loadStartPage() {
    if (controller != null) {
      print("_baseUrl " + _baseUrl);
      controller.loadUrl(url: _baseUrl);
    }
  }*/

  Future<void> onLoadStop(String loadStopUrl) async {
    print("loadStopUrl " + loadStopUrl);
    if(!isOffline) {
      final String _mutationObserver =
      """var observer = new MutationObserver(function(mutations) { 
        console.log('$_consoleTagDomModelChanged');
        });
          observer.observe(document.documentElement, {
              attributes: true,
              characterData: true,
              childList: true,
              subtree: true,
              attributeOldValue: true,
              characterDataOldValue: true
              }); 
              """;
      controller.evaluateJavascript(source: _mutationObserver);
    }
    if (statusLoad == StatusBackgroundAnalysis.searchIndex) {
      if (loadStopUrl == (_baseUrl + _prefixUrl)) {
        print("onLoadStop index page");

        if(isOffline){
           controller.getHtml().then((value) {
             _parseStartPage(value);
           });
        }else {
          statusLoad = StatusBackgroundAnalysis.loadIndex;
        }
       // statusLoad = StatusBackgroundAnalysis.loadIndex;
       // controller.getHtml().then((value) {
       //   _parseStartPage(value);
       // });
      }
    }

    if (statusLoad == StatusBackgroundAnalysis.searchQuiz) {
      if (currentQuiz < _quizUrls.length) {
        String urlQuiz = _quizUrls[currentQuiz].link;
        if (loadStopUrl == (_baseUrl + urlQuiz)) {
          print("onLoadStop quiz page");
          if(isOffline){
             controller.getHtml().then((value) {
              _parseQuizPage(value);
             });
          }else {
            statusLoad = StatusBackgroundAnalysis.loadQuiz;
          }
         // statusLoad = StatusBackgroundAnalysis.loadQuiz;
         // controller.getHtml().then((value) {
          //  _parseQuizPage(value);
         // });
        }
      }
    }
  }

  void onConsoleMessage(ConsoleMessage message) {
    print(message);
    switch (message.message) {
      case _consoleTagDomModelChanged:
        if (statusLoad == StatusBackgroundAnalysis.loadIndex) {
          statusLoad = StatusBackgroundAnalysis.parseIndex;
          controller.getHtml().then((value) => _parseStartPage(value));
        }
        if (statusLoad == StatusBackgroundAnalysis.loadQuiz) {
          statusLoad = StatusBackgroundAnalysis.parseQuiz;
          controller.getHtml().then((value) => _parseQuizPage(value));
        }
       // statusLoad = StatusBackgroundAnalysis.loadQuiz;
        break;
    }
  }

  // разбираем стартовую страницу
  void _parseStartPage(String htmlText) {
    dom.Document documentHtml = parse(htmlText);
    var searchListItem = documentHtml.getElementsByClassName(_classListItem);
    print("count list " + searchListItem.length.toString());
    if (searchListItem.length != 0) {
      statusLoad = StatusBackgroundAnalysis.foundIndex;
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
          String link = _getLink(quizElement);
          if ((link != null) && (link != "")) {
            _quizUrls.add(CourseCountQuestion(link: link));
            print("Course link " + link);
          }
        });
      }

      _loadNextQuiz();
    } else {
      _finishedAnalysis();
    }
  }

  // разбираем страницу с вопросом
  void _parseQuizPage(String htmlText) {
    print("parseQuizPage");
    dom.Document documentHtml = parse(htmlText);

    var searchStartButton = documentHtml.getElementsByClassName(_classButton);
    if (searchStartButton.isNotEmpty) {
      print("searchStartButton");
      var searchQuestionCounter =
          documentHtml.getElementsByClassName(_classCounterLabel);
      if (searchQuestionCounter.isNotEmpty) {
        print("searchQuestionCounter");
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
    _loadNextQuiz();
  }

  //загрузить следующий урок
  void _loadNextQuiz() {
    currentQuiz++;
    print("loadNextQuiz");
    if ((_quizUrls.isNotEmpty) && (currentQuiz < _quizUrls.length)) {
      statusLoad = StatusBackgroundAnalysis.searchQuiz;
      String urlQuiz = _quizUrls[currentQuiz].link;
      print("loadNextQuiz  " + _baseUrl + urlQuiz);
      controller.loadUrl(url: _baseUrl + urlQuiz);
      if (Platform.isIOS) {
        controller.reload();
      }
    } else {
      _finishedAnalysis();
    }
  }

  // Результат анализа курса
  void _finishedAnalysis() {
    statusLoad = StatusBackgroundAnalysis.finishParseQuiz;
    if (onFinishedParse != null) onFinishedParse(_quizUrls);
    controller.stopLoading();
    controller.clearCache();
  }

  // получить ссылку из элемента
  String _getLink(dom.Element element) {
    var searchLink = element.getElementsByClassName(_classLink);
    if ((searchLink != null) && (searchLink.isNotEmpty)) {
      String link = searchLink.first.attributes[_href];
      return link;
    }
    return null;
  }
}
