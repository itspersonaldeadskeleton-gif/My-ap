import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../wardrobe/presentation/wardrobe_services.dart';
import '../data/weather_service.dart';
import '../domain/occasion_answers.dart';
import '../domain/weather_info.dart';

/// Holds the answers while the user moves through the questionnaire.
class QuestionnaireController extends Notifier<OccasionAnswers> {
  @override
  OccasionAnswers build() => const OccasionAnswers();

  void update(OccasionAnswers Function(OccasionAnswers) f) => state = f(state);
  void reset() => state = const OccasionAnswers();
}

final questionnaireProvider =
    NotifierProvider<QuestionnaireController, OccasionAnswers>(
        QuestionnaireController.new);

final weatherServiceProvider =
    Provider<WeatherService>((ref) => WeatherService(ref.watch(dioProvider)));

/// Auto-detected weather. `ref.invalidate` to retry.
final detectedWeatherProvider = FutureProvider.autoDispose<WeatherInfo>(
    (ref) => ref.watch(weatherServiceProvider).fetchCurrent());
