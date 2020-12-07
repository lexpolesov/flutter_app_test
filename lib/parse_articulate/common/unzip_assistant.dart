import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/cupertino.dart';

class UnzipAssistant {
  final String pathArchive;
  final String path;
  final VoidCallback onComplete;
  final VoidCallback onError;

  UnzipAssistant({this.pathArchive, this.path, this.onComplete, this.onError}) {
    _startUnzip();
  }

  void _startUnzip() {
    try {
      // Read the Zip file from disk.
      final bytes = File(pathArchive).readAsBytesSync();

      // Decode the Zip file
      final archive = ZipDecoder().decodeBytes(bytes);

      // Extract the contents of the Zip archive to disk.
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File(path + filename)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory(path + filename)..create(recursive: true);
        }
      }

      if (onComplete != null) onComplete();
    } catch (e) {
      if (onError != null) onError();
    }
  }
}
