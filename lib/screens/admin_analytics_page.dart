import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  final AdminService _adminService = AdminService();
  
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;
  String? _error;
  String _selectedPeriod = '7d';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await _adminService.getAnalytics(period: _selectedPeriod);
      setState(() {
        _analyticsData = data['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAnalytics,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period selector
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time Period',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildPeriodChip('7d', '7 Days'),
                                  const SizedBox(width: 8),
                                  _buildPeriodChip('30d', '30 Days'),
                                  const SizedBox(width: 8),
                                  _buildPeriodChip('90d', '90 Days'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // User Registrations Chart
                      if (_analyticsData?['userRegistrations'] != null) ...[
                        Text(
                          'User Registrations',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        _buildSimpleChart(
                          'User Registrations',
                          _analyticsData!['userRegistrations'],
                          Colors.blue,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Words Added Chart
                      if (_analyticsData?['wordsOverTime'] != null) ...[
                        Text(
                          'Words Added Over Time',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        _buildSimpleChart(
                          'Words Added',
                          _analyticsData!['wordsOverTime'],
                          Colors.green,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Popular Words
                      if (_analyticsData?['popularWords'] != null) ...[
                        Text(
                          'Most Popular Words',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        _buildPopularWordsList(_analyticsData!['popularWords']),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildPeriodChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedPeriod == value,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPeriod = value;
          });
          _loadAnalytics();
        }
      },
    );
  }

  Widget _buildSimpleChart(String title, List<dynamic> data, Color color) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text('No data available for $title'),
          ),
        ),
      );
    }

    // Find max value for scaling
    final maxValue = data.map((item) => item['count'] as int).reduce((a, b) => a > b ? a : b);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.asMap().entries.map((entry) {
                  final item = entry.value;
                  final count = item['count'] as int;
                  final height = maxValue > 0 ? (count / maxValue) * 150 : 0.0;
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.7),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            child: Center(
                              child: count > 0
                                  ? Text(
                                      count.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item['_id']['day']}/${item['_id']['month']}',
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularWordsList(List<dynamic> words) {
    if (words.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No popular words data available'),
          ),
        ),
      );
    }

    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: words.length,
        itemBuilder: (context, index) {
          final word = words[index];
          final maxCount = words.first['count'] as int;
          final currentCount = word['count'] as int;
          final percentage = maxCount > 0 ? (currentCount / maxCount) : 0.0;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getPopularityColor(index),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(word['_id'] ?? 'Unknown'),
            subtitle: Text('Used ${word['count']} times'),
            trailing: SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(percentage * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(_getPopularityColor(index)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getPopularityColor(int index) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }
}
