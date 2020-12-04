import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'parse_unzipping_course/common.dart';

class ButtonCourseBody extends StatelessWidget {
  final StatusButtonCourse _status;
  final int percent;

  ButtonCourseBody(this._status, this.percent);

  @override
  Widget build(BuildContext context) {
    return Center(child: _buildWidget());
  }

  Widget _buildWidget() {
    switch (_status) {
      case StatusButtonCourse.LINK:
        return Text("Скачать");
        break;
      case StatusButtonCourse.DOWNLOAD:
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text("Скачивание..."),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(percent.toString() ?? ""),
          )
        ]);
        break;
      case StatusButtonCourse.DOWNLOAD_ERROR:
        return Text("Ошибка загрузки");
        break;
      case StatusButtonCourse.UNZIP:
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text("Распаковка..."),
          )
        ]);
        break;
      case StatusButtonCourse.UNZIP_ERROR:
        return Text("Ошибка распаковки");
        break;
      case StatusButtonCourse.PARSE_COURSE:
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text("Анализ..."),
          )
        ]);
        break;
      case StatusButtonCourse.READY:
        return Text("Открыть");
        break;
      case StatusButtonCourse.CHECK:
        return CircularProgressIndicator();
        break;
    }
    return Container();
  }
}