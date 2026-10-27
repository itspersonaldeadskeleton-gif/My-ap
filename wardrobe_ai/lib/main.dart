import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keys live in .env (git-ignored). In production, proxy via a backend.
  await dotenv.load(fileName: '.env', isOptional: true);

  // Create the container first so we can seed the DB before the first frame.
  final container = ProviderContainer();
  await container.read(seedServiceProvider).seedIfNeeded();

  runApp(UncontrolledProviderScope(container: container, child: const WardrobeApp()));
}
