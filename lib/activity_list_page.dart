import 'package:flutter/material.dart';

class ActivityListPage extends StatelessWidget {
  final String categoryTitle;
  final int count;

  const ActivityListPage({
    super.key,
    required this.categoryTitle,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1B5E20);
    const lime = Color(0xFFE9F7C6);

    // Generate sample activities based on category
    final List<Map<String, String>> sampleActivities = List.generate(
      count > 0 ? count : 3, // show sample items if count is 0 for demo interactivity
      (index) => {
        'title': '$categoryTitle Activity #${index + 1}',
        'date': 'Tomorrow, 10:00 AM',
        'location': 'Central Park, City Center',
        'description':
            'Join us for an amazing community gathering and activity session. Connect with fellow enthusiasts and enjoy!',
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        title: Text(
          categoryTitle,
          style: const TextStyle(color: green, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        iconTheme: const IconThemeData(color: green),
      ),
      body: SafeArea(
        child: sampleActivities.isEmpty
            ? Center(
                child: Text(
                  'No items found in $categoryTitle',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: sampleActivities.length,
                itemBuilder: (context, index) {
                  final item = sampleActivities[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE6E1D8)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFFFAF7F2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Text(
                              item['title']!,
                              style: const TextStyle(color: green),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 16, color: green),
                                    const SizedBox(width: 8),
                                    Text(item['date']!),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 16, color: green),
                                    const SizedBox(width: 8),
                                    Text(item['location']!),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(item['description']!),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close',
                                    style: TextStyle(color: green)),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Action confirmed for ${item['title']}'),
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                    backgroundColor: green),
                                child: const Text('View Details'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: lime,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.event_note,
                                  color: green, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['date']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['location']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
