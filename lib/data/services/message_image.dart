import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Longest side kept for a group-message photo.
const int messageImageMaxSide = 1600;

/// Original files larger than this are refused before decoding.
const int messageImageMaxBytes = 12 * 1024 * 1024;

/// Resizes a photo so the longest side is at most 1600 px and stores it as JPEG.
Uint8List encodeMessageImage(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('Unsupported image');
  }
  final longest = decoded.width > decoded.height ? decoded.width : decoded.height;
  final prepared = longest > messageImageMaxSide
      ? img.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? messageImageMaxSide : null,
          height: decoded.height > decoded.width ? messageImageMaxSide : null,
        )
      : decoded;
  return Uint8List.fromList(img.encodeJpg(prepared, quality: 80));
}
