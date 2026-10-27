import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/occasion_answers.dart';
import 'questionnaire_options.dart';
import 'questionnaire_providers.dart';
import 'widgets/color_step.dart';
import 'widgets/icon_chip.dart';
import 'widgets/step_progress.dart';
import 'widgets/weather_step.dart';

/// One question per screen. Swiping is disabled so required answers are
/// enforced; the Next button unlocks once a step is answered.
class QuestionnaireScreen extends ConsumerStatefulWidget {
  const QuestionnaireScreen({super.key});
  @override
  ConsumerState<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _Step {
  const _Step(this.title, this.subtitle, this.ok, this.child);
  final String title, subtitle;
  final bool ok;
  final Widget child;
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  final _pc = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Widget _single(List<Opt> o, String? cur, OccasionAnswers Function(OccasionAnswers, String) set) =>
      ChoiceWrap(
        options: o,
        isSelected: (l) => l == cur,
        onTap: (l) => ref.read(questionnaireProvider.notifier).update((s) => set(s, l)),
      );

  List<_Step> _steps(OccasionAnswers a) {
    final c = ref.read(questionnaireProvider.notifier);
    return [
      _Step('How are you feeling?', 'Pick the vibe you want to give off.', a.mood != null,
          _single(moods, a.mood, (s, v) => s.copyWith(mood: v))),
      _Step('What time of day?', 'Light and mood change what works.', a.timeOfDay != null,
          _single(times, a.timeOfDay, (s, v) => s.copyWith(timeOfDay: v))),
      _Step('Where are you headed?', 'The venue sets the baseline.', a.destination != null,
          _single(destinations, a.destination, (s, v) => s.copyWith(destination: v))),
      _Step('Who are you with?', 'Company changes the dress sense.', a.companions != null,
          _single(companions, a.companions, (s, v) => s.copyWith(companions: v))),
      _Step('How many people?', 'Including you.', true, _GroupSize(
        value: a.groupSize,
        onChanged: (n) => c.update((s) => s.copyWith(groupSize: n)),
      )),
      _Step('Indoors or outdoors?', 'Think about where you will spend most of the time.', a.setting != null,
          _single(settings, a.setting, (s, v) => s.copyWith(setting: v))),
      _Step('How is the weather?', 'We detect it, you can override.', a.weather != null,
          const WeatherStep()),
      _Step('Is there a dress code?', 'Choose the closest match.', a.dressCode != null,
          _single(dressCodes, a.dressCode, (s, v) => s.copyWith(dressCode: v))),
      _Step('Comfort or style?', 'Slide toward what matters more today.', true, _Comfort(
        value: a.comfortStyle,
        onChanged: (v) => c.update((s) => s.copyWith(comfortStyle: v)),
      )),
      _Step('Any cultural considerations?', 'Optional. Select all that apply.', true, Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChoiceWrap(
            options: culturalOpts,
            isSelected: a.cultural.contains,
            onTap: (l) => c.update((s) {
              var list = [...s.cultural];
              if (l == 'None') {
                list = list.contains('None') ? [] : ['None'];
              } else {
                list.remove('None');
                list.contains(l) ? list.remove(l) : list.add(l);
              }
              return s.copyWith(cultural: list);
            }),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: a.culturalNote,
            onChanged: (v) => c.update((s) => s.copyWith(culturalNote: v)),
            decoration: const InputDecoration(
                labelText: 'Anything else? (optional)', border: OutlineInputBorder()),
          ),
        ],
      )),
      _Step('Colours to wear or avoid?', 'Optional. Switch between Wear and Avoid.', true,
          const ColorStep()),
      _Step('How will you move?', 'This decides shoes and fabrics.', a.activity != null,
          _single(activities, a.activity, (s, v) => s.copyWith(activity: v))),
    ];
  }

  void _go(int delta, int total) {
    final next = _index + delta;
    if (next >= total) {
      context.pushReplacement('/recommendation');
      return;
    }
    _pc.animateToPage(next,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps(ref.watch(questionnaireProvider));
    final last = _index == steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close questionnaire',
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Plan an outfit'),
      ),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: StepProgress(index: _index, total: steps.length),
          ),
          Expanded(
            child: PageView(
              controller: _pc,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _index = i),
              children: [
                for (final s in steps)
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.title, style: Theme.of(context).textTheme.headlineMedium)
                          .animate().fadeIn(duration: 350.ms).slideX(begin: 0.05),
                      const SizedBox(height: 6),
                      Text(s.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      s.child,
                    ]),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(children: [
              OutlinedButton(
                onPressed: _index == 0 ? null : () => _go(-1, steps.length),
                style: OutlinedButton.styleFrom(minimumSize: const Size(96, 48)),
                child: const Text('Back'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: steps[_index].ok ? () => _go(1, steps.length) : null,
                  child: Text(last ? 'See my outfits' : 'Next'),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _GroupSize extends StatelessWidget {
  const _GroupSize({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Number of people: $value',
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton.filledTonal(
            tooltip: 'Fewer people',
            iconSize: 32,
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 120,
            child: Column(children: [
              Text('$value', style: Theme.of(context).textTheme.displaySmall),
              Text(value == 1 ? 'Just me' : 'people'),
            ]),
          ),
          IconButton.filledTonal(
            tooltip: 'More people',
            iconSize: 32,
            onPressed: value < 20 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add),
          ),
        ]),
      );
}

class _Comfort extends StatelessWidget {
  const _Comfort({required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = value < .34 ? 'Comfort first' : value > .66 ? 'Style first' : 'A balanced mix';
    return Column(children: [
      Text(text, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      Slider(
        value: value,
        divisions: 10,
        label: text,
        semanticFormatterCallback: (_) => text,
        onChanged: onChanged,
      ),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [Icon(Icons.weekend_outlined), SizedBox(width: 6), Text('Comfort')]),
        Row(children: [Text('Style'), SizedBox(width: 6), Icon(Icons.auto_awesome)]),
      ]),
    ]);
  }
}
