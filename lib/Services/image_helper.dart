import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  static const int maxDimension = 600;
  static const int jpegQuality = 82;
  static const int minJpegQuality = 55;
  static const int maxFileBytes = 400 * 1024;

  /// Bakes EXIF orientation, resizes large photos, and compresses when needed.
  static Future<File> normalizeForDisplay(File source) async {
    final bytes = await source.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      return source;
    }

    var image = img.bakeOrientation(decoded);
    image = _resizeIfNeeded(image);

    var quality = jpegQuality;
    var encoded = img.encodeJpg(image, quality: quality);

    while (encoded.length > maxFileBytes && quality > minJpegQuality) {
      quality -= 10;
      encoded = img.encodeJpg(image, quality: quality);
    }

    while (encoded.length > maxFileBytes && image.width > 240 && image.height > 240) {
      image = img.copyResize(
        image,
        width: (image.width * 0.85).round(),
        height: (image.height * 0.85).round(),
        interpolation: img.Interpolation.linear,
      );
      encoded = img.encodeJpg(image, quality: quality);
    }

    final tempDir = await getTemporaryDirectory();
    final outputPath =
        '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(encoded);
    return outputFile;
  }

  static img.Image _resizeIfNeeded(img.Image image) {
    final longestSide = math.max(image.width, image.height);
    if (longestSide <= maxDimension) {
      return image;
    }

    if (image.width >= image.height) {
      return img.copyResize(
        image,
        width: maxDimension,
        interpolation: img.Interpolation.linear,
      );
    }

    return img.copyResize(
      image,
      height: maxDimension,
      interpolation: img.Interpolation.linear,
    );
  }
}
