import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';

/// Removes the photo background. Order: ML Kit (Android, on-device) ->
/// remove.bg (needs REMOVE_BG_API_KEY) -> null (caller keeps the original).
/// Never throws: a missing cutout must not block adding an item.
class BackgroundRemovalService {
  BackgroundRemovalService(this._dio);
  final Dio _dio;

  Future<File?> remove(File input) async {
    final bytes = await _mlKit(input) ?? await _removeBg(input);
    if (bytes == null) return null;
    final out = File('${input.path}_cutout.png');
    await out.writeAsBytes(bytes);
    return out;
  }

  Future<Uint8List?> _mlKit(File f) async {
    if (!Platform.isAndroid) return null; // ML Kit subject segmentation is Android-only
    final seg = SubjectSegmenter(
      options: SubjectSegmenterOptions(
        enableForegroundBitmap: true,
        enableForegroundConfidenceMask: false,
        enableMultipleSubjects: SubjectResultOptions(
            enableConfidenceMask: false, enableSubjectBitmap: false),
      ),
    );
    try {
      final r = await seg.processImage(InputImage.fromFile(f));
      final b = r.foregroundBitmap;
      if (b == null) return null;
      // If the plugin hands back raw pixels we can't decode, fall through.
      final codec = await ui.instantiateImageCodec(b);
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    } finally {
      seg.close();
    }
  }

  Future<Uint8List?> _removeBg(File f) async {
    final key = dotenv.maybeGet('REMOVE_BG_API_KEY');
    if (key == null || key.isEmpty) return null;
    try {
      final res = await _dio.post<List<int>>(
        'https://api.remove.bg/v1.0/removebg',
        data: FormData.fromMap({
          'image_file': await MultipartFile.fromFile(f.path),
          'size': 'auto',
        }),
        options: Options(
            headers: {'X-Api-Key': key}, responseType: ResponseType.bytes),
      );
      return res.data == null ? null : Uint8List.fromList(res.data!);
    } catch (_) {
      return null;
    }
  }
}
