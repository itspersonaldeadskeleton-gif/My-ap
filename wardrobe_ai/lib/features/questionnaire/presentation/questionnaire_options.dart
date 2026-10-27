import 'package:flutter/material.dart';

/// One tappable choice: a label + icon.
class Opt {
  const Opt(this.label, this.icon);
  final String label;
  final IconData icon;
}

const moods = [
  Opt('Confident', Icons.bolt), Opt('Relaxed', Icons.spa),
  Opt('Playful', Icons.celebration), Opt('Polished', Icons.diamond),
  Opt('Romantic', Icons.favorite), Opt('Edgy', Icons.local_fire_department),
];
const times = [
  Opt('Morning', Icons.wb_twilight), Opt('Afternoon', Icons.wb_sunny),
  Opt('Evening', Icons.nights_stay), Opt('Night', Icons.bedtime),
];
const destinations = [
  Opt('Office', Icons.business_center), Opt('Date night', Icons.restaurant),
  Opt('Party', Icons.celebration), Opt('Wedding', Icons.church),
  Opt('Interview', Icons.badge), Opt('Travel', Icons.flight),
  Opt('Outdoors', Icons.park), Opt('Casual hangout', Icons.local_cafe),
  Opt('Gym', Icons.fitness_center),
];
const companions = [
  Opt('Alone', Icons.person), Opt('Partner', Icons.favorite),
  Opt('Friends', Icons.groups), Opt('Family', Icons.family_restroom),
  Opt('Colleagues', Icons.work), Opt('Clients', Icons.business),
];
const settings = [
  Opt('Indoors', Icons.home_outlined), Opt('Outdoors', Icons.landscape),
  Opt('Both', Icons.swap_horiz),
];
const dressCodes = [
  Opt('Casual', Icons.checkroom), Opt('Smart casual', Icons.style),
  Opt('Business', Icons.business_center), Opt('Cocktail', Icons.local_bar),
  Opt('Black tie', Icons.star),
];
const activities = [
  Opt('Mostly sitting', Icons.event_seat), Opt('Standing', Icons.accessibility_new),
  Opt('Walking a lot', Icons.directions_walk),
];
const culturalOpts = [
  Opt('Modest coverage', Icons.shield_outlined), Opt('Religious venue', Icons.church),
  Opt('Traditional attire', Icons.auto_awesome), Opt('Shoes come off', Icons.do_not_step),
  Opt('Conservative workplace', Icons.business), Opt('None', Icons.check),
];

/// Manual weather override: label -> (°C, condition).
const manualWeather = <String, (double, String)>{
  'Hot': (34, 'clear'), 'Warm': (26, 'clear'), 'Mild': (19, 'cloudy'),
  'Cool': (11, 'cloudy'), 'Cold': (2, 'cloudy'),
  'Rainy': (14, 'rain'), 'Snowy': (-1, 'snow'),
};

class ColorOpt {
  const ColorOpt(this.name, this.color);
  final String name;
  final Color color;
}

const paletteOpts = [
  ColorOpt('black', Color(0xFF151515)), ColorOpt('white', Color(0xFFF5F5F0)),
  ColorOpt('grey', Color(0xFF8E9196)), ColorOpt('beige', Color(0xFFD8C3A5)),
  ColorOpt('navy', Color(0xFF1F2A44)), ColorOpt('brown', Color(0xFF5A3A25)),
  ColorOpt('red', Color(0xFFB4442D)), ColorOpt('orange', Color(0xFFE08A3C)),
  ColorOpt('yellow', Color(0xFFE8C547)), ColorOpt('green', Color(0xFF5E6B3F)),
  ColorOpt('blue', Color(0xFF2E4A7A)), ColorOpt('purple', Color(0xFF7A4E9E)),
  ColorOpt('pink', Color(0xFFE58AA8)),
];

IconData weatherIcon(String cond) => switch (cond) {
      'clear' => Icons.wb_sunny,
      'rain' => Icons.water_drop,
      'snow' => Icons.ac_unit,
      'storm' => Icons.thunderstorm,
      'fog' => Icons.cloud,
      _ => Icons.wb_cloudy,
    };
