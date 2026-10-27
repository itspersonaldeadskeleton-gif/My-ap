import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/weather_service.dart';
import '../../domain/weather_info.dart';
import '../questionnaire_options.dart';
import '../questionnaire_providers.dart';
import '../../../wardrobe/presentation/widgets/skeleton.dart';
import 'icon_chip.dart';

/// Weather: auto-detected from location + manual override.
class WeatherStep extends ConsumerStatefulWidget {
  const WeatherStep({super.key});
  @override
  ConsumerState<WeatherStep> createState() => _WeatherStepState();
}

class _WeatherStepState extends ConsumerState<WeatherStep> {
  @override
  void initState() {
    super.initState();
    // Pre-select the detected weather the first time it arrives.
    ref.listenManual(detectedWeatherProvider, (_, next) {
      next.whenData((w) {
        if (ref.read(questionnaireProvider).weather == null) _set(w);
      });
    }, fireImmediately: true);
  }

  void _set(WeatherInfo w) =>
      ref.read(questionnaireProvider.notifier).update((s) => s.copyWith(weather: w));

  @override
  Widget build(BuildContext context) {
    final detected = ref.watch(detectedWeatherProvider);
    final chosen = ref.watch(questionnaireProvider).weather;
    final cs = Theme.of(context).colorScheme;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      detected.when(
        loading: () => const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: Skeleton(height: 44)),
            ]),
          ),
        ),
        error: (e, _) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.location_off_outlined),
                const SizedBox(width: 10),
                Expanded(child: Text(
                    '${e is WeatherException ? e.message : 'Could not detect weather.'} Pick it below instead, or retry.')),
              ]),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => ref.invalidate(detectedWeatherProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ]),
          ),
        ),
        data: (w) {
          final on = chosen != null && !chosen.manual;
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: on ? cs.primary : Colors.transparent, width: 2),
            ),
            child: ListTile(
              minVerticalPadding: 16,
              leading: Icon(weatherIcon(w.condition), size: 32, color: cs.primary),
              title: Text(w.label),
              subtitle: const Text('Detected from your location'),
              trailing: on ? Icon(Icons.check_circle, color: cs.primary) : const Text('Use'),
              onTap: () => _set(w),
            ),
          );
        },
      ),
      const SizedBox(height: 18),
      Text('Or set it yourself', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 10),
      ChoiceWrap(
        options: [
          for (final k in manualWeather.keys)
            Opt(k, weatherIcon(manualWeather[k]!.$2)),
        ],
        isSelected: (l) => chosen?.manual == true && chosen?.label == l,
        onTap: (l) {
          final m = manualWeather[l]!;
          _set(WeatherInfo(tempC: m.$1, condition: m.$2, manual: true, label: l));
        },
      ),
    ]);
  }
}
