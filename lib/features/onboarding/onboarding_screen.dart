import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding data
  final Set<String> _selectedStyles = {};
  final Set<String> _selectedColors = {};
  String? _fitPreference;
  final Set<String> _selectedActivities = {};
  String? _budgetRange;
  String? _climatePreference;

  final List<String> _styles = [
    'Minimal',
    'Casual',
    'Streetwear',
    'Classic',
    'Bohemian',
    'Athleisure',
    'Formal',
    'Vintage'
  ];

  final List<String> _colors = [
    'Black',
    'White',
    'Navy',
    'Beige',
    'Gray',
    'Brown',
    'Red',
    'Blue',
    'Green',
    'Pink'
  ];

  final List<String> _fits = ['Slim', 'Regular', 'Relaxed', 'Oversized'];

  final List<String> _activities = [
    'Work',
    'Gym',
    'Social',
    'Travel',
    'Date Night',
    'Outdoor',
    'Study',
    'Weekend'
  ];

  final List<String> _budgets = [
    'Under \$50',
    '\$50 - \$100',
    '\$100 - \$250',
    '\$250 - \$500',
    '\$500+'
  ];

  final List<String> _climates = [
    'Tropical',
    'Temperate',
    'Cold',
    'Dry',
    'Humid',
    'Four Seasons'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    await prefs.setStringList('onboarding_styles', _selectedStyles.toList());
    await prefs.setStringList('onboarding_colors', _selectedColors.toList());
    if (_fitPreference != null) {
      await prefs.setString('onboarding_fit', _fitPreference!);
    }
    await prefs.setStringList('onboarding_activities', _selectedActivities.toList());
    if (_budgetRange != null) {
      await prefs.setString('onboarding_budget', _budgetRange!);
    }
    if (_climatePreference != null) {
      await prefs.setString('onboarding_climate', _climatePreference!);
    }
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    await _saveOnboardingData();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with skip button and progress
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Animated progress indicator
                  Expanded(
                    child: Row(
                      children: List.generate(6, (index) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: index <= _currentPage
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                              .animate(target: index <= _currentPage ? 1 : 0)
                              .scaleX(
                                begin: 0.0,
                                end: 1.0,
                                duration: 300.ms,
                                curve: Curves.easeInOut,
                              ),
                        );
                      }),
                    ),
                  ),
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildStylePreferencesPage(theme),
                  _buildColorsPage(theme),
                  _buildFitPage(theme),
                  _buildActivitiesPage(theme),
                  _buildBudgetPage(theme),
                  _buildClimatePage(theme),
                ],
              ),
            ),
            // Next button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _nextPage,
                  child: Text(_currentPage < 5 ? 'Next' : 'Get Started'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylePreferencesPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Style Preferences',
            style: theme.textTheme.headlineMedium,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            'What styles resonate with you?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _styles.map((style) {
              final isSelected = _selectedStyles.contains(style);
              return FilterChip(
                label: Text(style),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedStyles.add(style);
                    } else {
                      _selectedStyles.remove(style);
                    }
                  });
                },
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 50 * _styles.indexOf(style)),
                    duration: 300.ms,
                  );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorsPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Colors',
            style: theme.textTheme.headlineMedium,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            'Which colors do you love wearing?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colors.map((color) {
              final isSelected = _selectedColors.contains(color);
              return FilterChip(
                label: Text(color),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedColors.add(color);
                    } else {
                      _selectedColors.remove(color);
                    }
                  });
                },
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 50 * _colors.indexOf(color)),
                    duration: 300.ms,
                  );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFitPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fit Preference',
            style: theme.textTheme.headlineMedium,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            'How do you like your clothes to fit?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 32),
          Column(
            children: _fits.map((fit) {
              final isSelected = _fitPreference == fit;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  elevation: isSelected ? 2 : 0,
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  child: ListTile(
                    title: Text(fit),
                    trailing: isSelected ? const Icon(Icons.check_circle) : null,
                    onTap: () {
                      setState(() {
                        _fitPreference = fit;
                      });
                    },
                  ),
                ).animate().fadeIn(
                      delay: Duration(milliseconds: 100 * _fits.indexOf(fit)),
                      duration: 300.ms,
                    ).slideX(begin: 0.1, end: 0),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activities',
            style: theme.textTheme.headlineMedium,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            'What do you need outfits for?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _activities.map((activity) {
              final isSelected = _selectedActivities.contains(activity);
              return FilterChip(
                label: Text(activity),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedActivities.add(activity);
                    } else {
                      _selectedActivities.remove(activity);
                    }
                  });
                },
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 50 * _activities.indexOf(activity)),
                    duration: 300.ms,
                  );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget',
            style: theme.textTheme.headlineMedium,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            'What\'s your typical clothing budget?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 32),
          Column(
            children: _budgets.map((budget) {
              final isSelected = _budgetRange == budget;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  elevation: isSelected ? 2 : 0,
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  child: ListTile(
                    title: Text(budget),
                    trailing: isSelected ? const Icon(Icons.check_circle) : null,
                    onTap: () {
                      setState(() {
                        _budgetRange = budget;
                      });
                    },
                  ),
                ).animate().fadeIn(
                      delay: Duration(milliseconds: 100 * _budgets.indexOf(budget)),
                      duration: 300.ms,
                    ).slideX(begin: 0.1, end: 0),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClimatePage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Climate',
            style: theme.textTheme.headlineMedium,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            'What climate do you dress for?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 32),
          Column(
            children: _climates.map((climate) {
              final isSelected = _climatePreference == climate;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  elevation: isSelected ? 2 : 0,
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  child: ListTile(
                    title: Text(climate),
                    trailing: isSelected ? const Icon(Icons.check_circle) : null,
                    onTap: () {
                      setState(() {
                        _climatePreference = climate;
                      });
                    },
                  ),
                ).animate().fadeIn(
                      delay: Duration(milliseconds: 100 * _climates.indexOf(climate)),
                      duration: 300.ms,
                    ).slideX(begin: 0.1, end: 0),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
