import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileHelpers {
  static const String _filename = "archive.zip";
  static const String _pathCourse = "Courses";
  static const String _folderUnzipCourse = "content";
  static const String _indexCoursePage = "index.html";

  static Future<String> getDirectoryApplication() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> getDirectoryPathCourses() async {
    String _localPath = (await getDirectoryApplication()) +
        Platform.pathSeparator +
        _pathCourse;
    return _localPath;
  }

  static Future<String> getDirectoryPathIdCourse(int idCourse) async {
    String idPath = idCourse.toString();
    String _localPathId =
        (await getDirectoryPathCourses()) + Platform.pathSeparator + idPath;
    return _localPathId;
  }

  static Future<bool> checkUnzipCourseIndexPage(int idCourse) async {
    String _localPathIndexPage = (await getDirectoryPathIdCourse(idCourse)) +
        Platform.pathSeparator +
        _folderUnzipCourse +
        Platform.pathSeparator +
        _indexCoursePage;
    final indexFile = File(_localPathIndexPage);
    bool hasExisted = await indexFile.exists();
    return hasExisted;
  }

  static Future<bool> checkArchive(int idCourse) async {
    String _localArchive = (await getDirectoryPathIdCourse(idCourse)) +
        Platform.pathSeparator +
        _filename;
    final archiveFile = File(_localArchive);
    bool hasExisted = await archiveFile.exists();
    return hasExisted;
  }

  static Future<String> checkFolderOrCreate(int idCourse) async {
    String _localFolder = (await getDirectoryPathIdCourse(idCourse));
    final savedDir = Directory(_localFolder);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    return _localFolder;
  }
}
