import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileHelpers {
  static const String filenameArchive = "archive.zip";
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

  static Future<String> getDirectoryPathIdCourseVersion(
      int idCourse, int version) async {
    String idPath = idCourse.toString();
    String idVersion = version.toString();
    String _localPathId = (await getDirectoryPathCourses()) +
        Platform.pathSeparator +
        idPath +
        Platform.pathSeparator +
        idVersion;
    return _localPathId;
  }

  static Future<String> getDirectoryPathIdCourseVersionArchive(
      int idCourse, int version) async {
    String _localArchive =
        (await getDirectoryPathIdCourseVersion(idCourse, version)) +
            Platform.pathSeparator +
            filenameArchive;
    return _localArchive;
  }

  static Future<bool> checkUnzipCourseIndexPage(
      int idCourse, int version) async {
    String _localPathIndexPage =
        (await getDirectoryPathIdCourseVersion(idCourse, version)) +
            Platform.pathSeparator +
            _folderUnzipCourse +
            Platform.pathSeparator +
            _indexCoursePage;
    final indexFile = File(_localPathIndexPage);
    bool hasExisted = await indexFile.exists();
    return hasExisted;
  }

  static Future<bool> checkArchive(int idCourse, int version) async {
    String _localArchive =
        (await getDirectoryPathIdCourseVersion(idCourse, version)) +
            Platform.pathSeparator +
            filenameArchive;
    final archiveFile = File(_localArchive);
    bool hasExisted = await archiveFile.exists();
    return hasExisted;
  }

  static Future<String> checkCourseFolderOrCreate(
      int idCourse, int version) async {
    String _localFolder =
        (await getDirectoryPathIdCourseVersion(idCourse, version));
    final savedDir = Directory(_localFolder);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      print("no file");
      await savedDir.create(recursive: true);
    }
    return _localFolder;
  }

  static Future<bool> deletePathCourse(int idCourse) async {
    String _localFolder = (await getDirectoryPathIdCourse(idCourse));
    final deleteDir = Directory(_localFolder);
    bool hasExisted = await deleteDir.exists();
    if (!hasExisted) {
      print("no file delete");
      await deleteDir.delete(recursive: true);
      return true;
    }
    return false;
  }
}
