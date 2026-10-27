import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies a picked/cutout image into the app documents directory so it
/// survives cache clears. Returns the permanent path.
Future<String> persistImage(File src, {String suffix = ''}) async {
  final dir = await getApplicationDocumentsDirectory();
  final name =
      '${DateTime.now().microsecondsSinceEpoch}$suffix${p.extension(src.path)}';
  return (await src.copy(p.join(dir.path, name))).path;
}
