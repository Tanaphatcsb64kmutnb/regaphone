import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';

class InAppMessageDialog extends StatelessWidget {
  final RemoteMessage message;
  final bool isFullScreen;

  const InAppMessageDialog({
    Key? key,
    required this.message,
    this.isFullScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isFullScreen) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text('Notification', style: TextStyle(color: Colors.pink)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.pink),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _buildContent(context),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // ดึงข้อมูลจาก message
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    final imageUrl = message.data['imageUrl'];
    final timestamp = DateTime.now();
    final formattedDate = DateFormat('dd/MMM/yyyy hh:mm a').format(timestamp);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Text(
              'การแจ้งเตือน',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Message body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              body,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),

          // Image if available
          if (imageUrl != null) ...[
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],

          // Timestamp
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
