

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

enum StatusParseUnzippingStatus {
  searchIndex,
  foundIndex,
  loadQuiz,
  clickStartQuiz,
  finishParseQuiz
}

enum StatusButtonCourse {
  LINK, // получили ссылку
  DOWNLOAD, //начали скачивание
  DOWNLOAD_ERROR, //ошибка скачивания
  UNZIP, //распаковка
  UNZIP_ERROR, //ошибка распаковки
  PARSE_COURSE, //разбор курса
  READY //курс готов
}

