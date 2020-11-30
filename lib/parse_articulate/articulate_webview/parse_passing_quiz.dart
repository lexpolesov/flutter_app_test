import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutterapptest/parse_articulate/common/parse_webview.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:uuid/uuid.dart';

class ParsePassingQuiz extends ParseWebView {
  final String _classButtonStartQuiz = "quiz-header__start-quiz brand--color";
  final String _classCounterLabel = "quiz-card__counter brand--color brand--ui";
  final String _classQuizCardActive = "quiz-card quiz-card--active";
  final String _classQuizCardFeedback = "quiz-card__feedback";
  final String _classQuizEnd = "quiz-end";
  final String _classArticulateExit = "articulate-exit";
  final String _classOverviewList = "overview-list";
  final String _classLessonListsList = "lesson-lists__list";
  final String _classInCorrectResult = "icon icon-Master-06";
  final String _classCorrectResult = "icon icon-Master-05";

  //тэги для консоли
  static const String _consoleButtonClick = "Quiz Button Start Quiz";
  static const String _consoleTagDomModelChanged = "DOM model changed";
  static const String _consoleTagDomExitButtonClick = "Quiz Button Exit";

  static const String _splitterLessons = "lessons/";

  PassingQuiz passing;
  bool createNewQuiz = false;
  String currentUrl;

  final Function(PassingQuiz) onChangePassing;
  final Function(PassingQuiz) onFinishPassing;
  final Function() onExit;

  ParsePassingQuiz({this.onChangePassing, this.onFinishPassing, this.onExit});

  //когда создалась вэб вью добавляем контроллер для получения данных
  void addController(InAppWebViewController webController) {
    super.addController(webController);

    var isNull = (controller == null);
    print(isNull.toString());
  }

  //после загрузки новой страницы добавляем скрипты для ослеживания событий
  @override
  void onLoadStop(String url) {
    final String _mutationObserver =
        """var observer = new MutationObserver(function(mutations) { 
        console.log('$_consoleTagDomModelChanged');
        var articulateExit = document.getElementsByClassName('$_classArticulateExit');
        var menuList = document.getElementsByClassName('$_classOverviewList');
        if (menuList.length < 1) {
          menuList = document.getElementsByClassName('$_classLessonListsList');
        }
        if (menuList.length > 0) {
          if (articulateExit.length == 0) {
            var textItem = document.createElement("div");
            textItem.setAttribute('class', "overview-list-item");
            textItem.appendChild(document.createTextNode("Выход"));

            var articulateExit = document.createElement("button");
            articulateExit.setAttribute('class', '$_classArticulateExit');
            articulateExit.appendChild(textItem);

            articulateExit.onclick = function() {
              console.log('$_consoleTagDomExitButtonClick');
            }
            menuList[0].appendChild(articulateExit);
          }
        }
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
    controller.injectCSSCode(source: """
    .articulate-exit {   
      border: 1px;
      border-style: solid;
      color: black;
      padding: 5px 54px;
      text-align: center;
      text-decoration: none;
      display: inline-block;
      font-size: 12px;}""");
    currentUrl = url;

    parsePage();
  }

  //ловим принты из страницы которые мы внедрили
  void onConsoleMessage(ConsoleMessage message) {
    switch (message.message) {
      case _consoleTagDomModelChanged:
        parsePage();
        break;
      case _consoleButtonClick:
        createNewQuiz = true;
        break;
      case _consoleTagDomExitButtonClick:
        if (onExit != null) onExit();
        break;
    }
  }

  //новая попытка прохождения
  void createAttempt(dom.Document html) {
    int countQuestions = findCountQuestions(html);
    if (countQuestions != null) {
      String urlId = getUrlIdQuiz();
      if (urlId != null) {
        if (passing != null) {
          if (passing.idUrl != urlId) {
            passing = PassingQuiz(urlId, countQuestions,
                onChangePassing: onChangePassing);
          }
        } else {
          passing = PassingQuiz(urlId, countQuestions,
              onChangePassing: onChangePassing);
        }
        createNewQuiz = false;
      }
    }
  }

  //разбор страницы
  void parsePage() {
    controller.getHtml().then((stringHtml) {
      dom.Document documentHtml = parse(stringHtml);

      //ищем кнопку старт курса, если находим вешаем слушатель
      var findStartButton = findButtonStartQuiz(documentHtml);
      if (findStartButton) {
        final String _scriptButtonOnClick = """  
           var isEnableStartCourseButton = document.getElementsByClassName('$_classButtonStartQuiz');
            if (isEnableStartCourseButton.length > 0) {
                 isEnableStartCourseButton[0].onclick = function() {
                     console.log('$_consoleButtonClick');
                    
                 };
              }
              """;
        controller.evaluateJavascript(source: _scriptButtonOnClick);
      }

      //если пользователь нажал на старт, создает объект для записи результатов прохождения
      if (createNewQuiz) createAttempt(documentHtml);

      ////разбираем карточку вопроса
      var searchQuizCards =
          documentHtml.getElementsByClassName(_classQuizCardActive);
      if (searchQuizCards.isNotEmpty) {
        searchQuizCards.forEach((element) {
          var item = parseCard(element);
          if (item != null) {
            if (passing != null) passing.addPassing(item);
          }
        });
      }

      //ищем страницу с результатами
      var searchPage = documentHtml.getElementsByClassName(_classQuizEnd);
      if (searchPage.isNotEmpty) {
        searchPage.forEach((element) {
          if (element.attributes['aria-hidden'] == 'false') {
            finishQuiz();
          }
        });
      }
    });
  }

  PassingQuizItem parseCard(Element item) {
    int number;
    StatusPassingQuizItem status = StatusPassingQuizItem.none;

    // ищем номер вопроса
    var searchNumberQuestion = item.getElementsByClassName(_classCounterLabel);
    if (searchNumberQuestion.isNotEmpty) {
      var textCounter = searchNumberQuestion.first.text;
      List<String> counters = textCounter.split("/");
      if (counters.isNotEmpty) number = int.tryParse(counters.first);
    }

    var searchBlockFeedBack =
        item.getElementsByClassName(_classQuizCardFeedback);
    if (searchBlockFeedBack.isNotEmpty) {
      searchBlockFeedBack.forEach((element) {
        if (element.attributes['aria-hidden'] == 'false') {
          var searchInCorrectResult =
              element.getElementsByClassName(_classInCorrectResult);
          if (searchInCorrectResult.isNotEmpty) {
            status = StatusPassingQuizItem.incorrect;
          }

          var searchCorrectResult =
              item.getElementsByClassName(_classCorrectResult);
          if (searchCorrectResult.isNotEmpty) {
            status = StatusPassingQuizItem.correct;
          }
        }
      });
    }
    if (number != null) {
      return PassingQuizItem(number, status: status);
    }
    return null;
  }

  //поиск кнопки старт курса
  bool findButtonStartQuiz(dom.Document html) {
    var findButtonElements = html.getElementsByClassName(_classButtonStartQuiz);
    if (findButtonElements.isNotEmpty) {
      return true;
    }
    return false;
  }

  //ищем количество вопрос в тестировании
  int findCountQuestions(dom.Document html) {
    var searchQuestionCounter = html.getElementsByClassName(_classCounterLabel);
    if (searchQuestionCounter.isNotEmpty) {
      String textQuestionCounter = searchQuestionCounter.first.text;
      int findIndexOf = textQuestionCounter.indexOf("/");
      if (findIndexOf != -1) {
        String countQuestionAll =
            textQuestionCounter.substring(findIndexOf + 1);
        int count = int.tryParse(countQuestionAll);
        return count;
      }
    }
    return null;
  }

  //вытаскиваем id из url
  String getUrlIdQuiz() {
    if (currentUrl != null) {
      List<String> splitUrl = currentUrl.split(_splitterLessons);
      if (splitUrl.isNotEmpty) {
        return splitUrl.last;
      }
    }
    return null;
  }

  //курс закончился
  void finishQuiz() {
    if (passing != null) {
      if (onFinishPassing != null) onFinishPassing(passing);
      passing = null;
    }
  }
}

//статус прохождения вопроса
enum StatusPassingQuizItem { none, correct, incorrect }

//объект статуса вопроса
class PassingQuizItem {
  int id;
  StatusPassingQuizItem status;

  PassingQuizItem(this.id, {this.status = StatusPassingQuizItem.none});

  void changeStatus(StatusPassingQuizItem changeStatus) {
    status = changeStatus;
  }
}

//статус прохождения теста
class PassingQuiz {
  String idUrl;
  int count;
  Function(PassingQuiz) onChangePassing;
  List<PassingQuizItem> items = [];
  String uuid;

  PassingQuiz(this.idUrl, this.count, {this.items, this.onChangePassing}) {
    uuid = Uuid().v4();
    if (onChangePassing != null) onChangePassing(this);
  }

  void addPassing(PassingQuizItem item) {
    bool isChanged = false;
    if (items != null) {
      var searchItem = items.firstWhere((element) => element.id == item.id,
          orElse: () => null);
      if (searchItem != null) {
        if (searchItem.status != item.status) {
          searchItem.changeStatus(item.status);
          isChanged = true;
        }
      } else {
        items.add(item);
        isChanged = true;
      }
    } else {
      items = [item];
      isChanged = true;
    }
    if ((onChangePassing != null) && isChanged) onChangePassing(this);
  }

  void printPassing() {
    print("id URL $idUrl");
    print("Count all $count");
    print("uuid $uuid");
    if (items != null) {
      items.forEach((element) {
        var _id = element.id;
        var _status = element.status;
        print("id $_id status $_status");
      });
    }
  }
}
