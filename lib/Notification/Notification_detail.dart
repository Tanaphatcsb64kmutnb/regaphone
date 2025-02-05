import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationDetailPage extends StatelessWidget {
  final String title;
  final String body;
  final DateTime timestamp;
  final String? imageUrl;
  final Map<String, dynamic>? additionalData;

  const NotificationDetailPage({
    Key? key,
    required this.title,
    required this.body,
    required this.timestamp,
    this.imageUrl,
    this.additionalData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title:
            const Text('Notification', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(timestamp),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (additionalData != null && additionalData!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...additionalData!.entries.map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.key}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value.toString(),
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
