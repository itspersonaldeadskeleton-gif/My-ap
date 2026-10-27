import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/llm_client.dart';
import '../data/background_removal_service.dart';
import '../data/tagging_repository.dart';

final dioProvider = Provider<Dio>((_) => Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
    )));

final llmClientProvider =
    Provider<LlmClient>((ref) => LlmClient(ref.watch(dioProvider)));

final taggingRepoProvider = Provider<TaggingRepository>(
    (ref) => TaggingRepository(ref.watch(llmClientProvider)));

final bgRemovalProvider = Provider<BackgroundRemovalService>(
    (ref) => BackgroundRemovalService(ref.watch(dioProvider)));
