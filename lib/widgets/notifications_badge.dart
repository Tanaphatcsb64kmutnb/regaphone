import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationBadge extends StatelessWidget {
  final Stream<QuerySnapshot> notificationsStream;

  const NotificationBadge({
    Key? key,
    required this.notificationsStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: notificationsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final unreadCount =
              snapshot.data!.docs.where((doc) => doc['isRead'] == false).length;

          if (unreadCount > 0) {
            return Stack(
              children: [
                const Icon(Icons.notifications, color: Colors.white),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          }
        }
        return const Icon(Icons.notifications, color: Colors.white);
      },
    );
  }
}

// Add to HomePage class:
/*
  // Add this to your _HomePageState class
  late Stream<QuerySnapshot> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _notificationsStream = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update AppBar leading widget:
  leading: IconButton(
    icon: NotificationBadge(
      notificationsStream: _notificationsStream,
    ),
    onPressed: () => _openNotifications(context),
  ),
*/