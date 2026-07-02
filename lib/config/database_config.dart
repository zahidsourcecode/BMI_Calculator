import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DatabaseConfig {
  static const fileName = 'bmi_calculator.db';
  static const folderName = 'database';

  /// Override with: --dart-define=DB_PATH=C:\path\to\bmi_calculator.db
  static const _envPath = String.fromEnvironment('DB_PATH');

  static Future<String> resolvePath() async {
    if (_envPath.isNotEmpty) {
      final file = File(_envPath);
      file.parent.createSync(recursive: true);
      return file.absolute.path;
    }

    final projectRoot = _findProjectRoot(Directory.current);
    if (projectRoot != null) {
      final dir = Directory(p.join(projectRoot.path, folderName));
      dir.createSync(recursive: true);
      return p.join(dir.path, fileName);
    }

    final docs = await getApplicationDocumentsDirectory();
    return p.join(docs.path, fileName);
  }

  static String projectDatabasePath(Directory startDir) {
    final projectRoot = _findProjectRoot(startDir);
    if (projectRoot == null) {
      throw StateError('Could not find project root from ${startDir.path}');
    }

    final dir = Directory(p.join(projectRoot.path, folderName));
    dir.createSync(recursive: true);
    return p.join(dir.path, fileName);
  }

  static Directory? _findProjectRoot(Directory start) {
    var current = start;

    for (var i = 0; i < 8; i++) {
      if (File(p.join(current.path, 'pubspec.yaml')).existsSync()) {
        return current;
      }

      final parent = current.parent;
      if (parent.path == current.path) break;
      current = parent;
    }

    return null;
  }
}
