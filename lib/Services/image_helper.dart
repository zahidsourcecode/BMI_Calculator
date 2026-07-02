import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  /// Bakes EXIF orientation into pixels so photos display upright and natural.
  static Future<File> normalizeForDisplay(File source, ImageSource imageSource) async {
    final bytes = await source.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      return source;
    }

    var normalized = img.bakeOrientation(decoded);

    if (normalized.width > 800 || normalized.height > 800) {
      normalized = img.copyResize(
        normalized,
        width: normalized.width >= normalized.height ? 800 : null,
        height: normalized.height > normalized.width ? 800 : null,
      );
    }

    // Some Android front-camera photos are saved mirrored in the pixels.
    if (imageSource == ImageSource.camera && Platform.isAndroid) {
      normalized = img.flipHorizontal(normalized);
    }

    final encoded = img.encodeJpg(normalized, quality: 85);
    final tempDir = await getTemporaryDirectory();
    final outputPath =
        '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(encoded);
    return outputFile;
  }
}
