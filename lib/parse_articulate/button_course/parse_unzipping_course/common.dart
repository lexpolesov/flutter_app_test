

class CourseCountQuestion {
  String link;
  int countQuestion;

  CourseCountQuestion({this.link}) {
    countQuestion = 0;
  }

  void setCountQuestion(int count) {
    countQuestion = count;
  }
}

enum StatusBackgroundAnalysis {
  searchIndex,
  loadIndex,
parseIndex,
  foundIndex,
  searchQuiz,
  loadQuiz,
  parseQuiz,

  //loadQuiz,
  finishParseQuiz
}

enum StatusButtonCourse {
  CHECK, // проверяем статус
  LINK, // получили ссылку
  DOWNLOAD, //начали скачивание
  DOWNLOADING,
  DOWNLOAD_ERROR, //ошибка скачивания
  UNZIP, //распаковка
  UNZIP_ERROR, //ошибка распаковки
  PARSE_COURSE, //разбор курса
  READY //курс готов
}

