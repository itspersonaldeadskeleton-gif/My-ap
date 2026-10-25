import 'package:flutter/material.dart';

class WardrobeInsightsScreen extends StatefulWidget {
  const WardrobeInsightsScreen({super.key});

  @override
  State<WardrobeInsightsScreen> createState() => _WardrobeInsightsScreenState();
}

class _InsightMetric {
  final String label;
  final String value;
  final double fraction;
  final Color color;
  _InsightMetric({required this.label, required this.value, required this.fraction, required this.color});
}

class _WardrobeInsightsScreenState extends State<WardrobeInsightsScreen> {
  final List<_InsightMetric> _metrics = [
    _InsightMetric(label: 'Total Items', value: '42', fraction: 1.0, color: Colors.blue),
    _InsightMetric(label: 'Wear Frequency', value: '68%', fraction: 0.68, color: Colors.green),
    _InsightMetric(label: 'Favorites', value: '9', fraction: 0.21, color: Colors.purple),
    _InsightMetric(label: 'Unused', value: '14', fraction: 0.33, color: Colors.orange),
  ];

  final List<_CategoryInsight> _categories = [
    _CategoryInsight(name: 'Tops', count: 18, color: Colors.blue),
    _CategoryInsight(name: 'Bottoms', count: 12, color: Colors.teal),
    _CategoryInsight(name: 'Dresses', count: 6, color: Colors.pink),
    _CategoryInsight(name: 'Shoes', count: 8, color: Colors.amber),
    _CategoryInsight(name: 'Outerwear', count: 5, color: Colors.deepPurple),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wardrobe Insights')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _metrics.map((m) => _MetricCard(metric: m)).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'By Category',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._categories.map((c) => _CategoryBar(category: c)),
          const SizedBox(height: 24),
          const Text(
            'Style Tips',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const _TipCard(
            title: 'Rotate Your Favorites',
            description: 'Try wearing your 9 favorite items on different days to maximize variety.',
          ),
          const SizedBox(height: 12),
          const _TipCard(
            title: 'Revisit Unused Items',
            description: 'You have 14 items you have not worn in a while. Consider styling them into new outfits.',
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final _InsightMetric metric;
  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: metric.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: metric.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.label,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _CategoryInsight {
  final String name;
  final int count;
  final Color color;
  _CategoryInsight({required this.name, required this.count, required this.color});
}

class _CategoryBar extends StatelessWidget {
  final _CategoryInsight category;
  const _CategoryBar({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: category.count,
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(category.name),
          const SizedBox(width: 6),
          Text(
            '(${category.count})',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String title;
  final String description;
  const _TipCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.lightbulb, color: Colors.amber),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
      ),
    );
  }
}