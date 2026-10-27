import 'package:flutter/material.dart';

/// Converts "#RRGGBB" (or "RRGGBB") to a [Color]. Falls back to grey.
Color hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  final v = int.tryParse(h.length == 6 ? 'FF$h' : h, radix: 16);
  return v == null ? Colors.grey : Color(v);
}

/// Buckets a hex colour into a human colour family (used by filters/stats).
String colorFamily(String hex) {
  final c = HSLColor.fromColor(hexToColor(hex));
  final h = c.hue, s = c.saturation, l = c.lightness;
  if (l < .15) return 'black';
  if (l > .9) return 'white';
  if (s < .15) return 'grey';
  if (s < .5 && l > .45 && h >= 20 && h <= 50) return 'beige';
  if (h < 15 || h >= 345) return 'red';
  if (h < 40) return l < .4 ? 'brown' : 'orange';
  if (h < 70) return l < .4 ? 'brown' : 'yellow';
  if (h < 170) return 'green';
  if (h < 260) return 'blue';
  if (h < 300) return 'purple';
  return 'pink';
}

const colorFamilies = <String>[
  'black', 'white', 'grey', 'beige', 'brown', 'red', 'orange', 'yellow',
  'green', 'blue', 'purple', 'pink',
];
