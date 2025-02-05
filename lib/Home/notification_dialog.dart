// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class NotificationDialog extends StatelessWidget {
//   final QueryDocumentSnapshot notification;

//   const NotificationDialog({
//     Key? key,
//     required this.notification,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final data = notification.data() as Map<String, dynamic>;
//     final type = data['type'] ?? '';

//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.95),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'การแจ้งเตือน',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.white),
//                   onPressed: () {
//                     FirebaseFirestore.instance
//                         .collection('notifications')
//                         .doc(notification.id)
//                         .update({'isRead': true, 'status': 'read'});
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               type,
//               style: const TextStyle(
//                 color: Colors.white70,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[900],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 data['title'] ?? '',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.left,
//               ),
//             ),
//             if (data['message'] != null) ...[
//               const SizedBox(height: 12),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[900],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   data['message'],
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//               ),
//             ],
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationDialog extends StatelessWidget {
  final Map<String, dynamic> notificationData;

  const NotificationDialog({
    Key? key,
    required this.notificationData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = notificationData['title'] ?? 'การแจ้งเตือน';
    final body = notificationData['body'] ?? '';
    final timestamp = DateTime.fromMillisecondsSinceEpoch(
        notificationData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch);
    final formattedDate = DateFormat('dd/MMM/yyyy hh:mm a').format(timestamp);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.pink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.pink),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'การแจ้งเตือน',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        body,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
