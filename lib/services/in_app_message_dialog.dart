// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:intl/intl.dart';

// class InAppMessageDialog extends StatelessWidget {
//   final RemoteMessage message;
//   final bool isFullScreen;

//   const InAppMessageDialog({
//     Key? key,
//     required this.message,
//     this.isFullScreen = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (isFullScreen) {
//       return Scaffold(
//         appBar: AppBar(
//           title:
//               const Text('Notification', style: TextStyle(color: Colors.pink)),
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back, color: Colors.pink),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//         body: _buildContent(context),
//       );
//     }

//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: Container(
//         width: double.infinity,
//         margin: const EdgeInsets.symmetric(horizontal: 20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: _buildContent(context),
//       ),
//     );
//   }

//   Widget _buildContent(BuildContext context) {
//     // ดึงข้อมูลจาก message
//     final title = message.notification?.title ?? '';
//     final body = message.notification?.body ?? '';
//     final imageUrl = message.data['imageUrl'];
//     final timestamp = DateTime.now();
//     final formattedDate = DateFormat('dd/MMM/yyyy hh:mm a').format(timestamp);

//     return SingleChildScrollView(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Title
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             child: Text(
//               'การแจ้งเตือน',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.pink,
//               ),
//             ),
//           ),

//           // Content
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//           ),

//           const SizedBox(height: 8),

//           // Message body
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               body,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.black54,
//               ),
//             ),
//           ),

//           // Image if available
//           if (imageUrl != null) ...[
//             const SizedBox(height: 16),
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               width: double.infinity,
//               height: 200,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 image: DecorationImage(
//                   image: NetworkImage(imageUrl),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ],

//           // Timestamp
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Align(
//               alignment: Alignment.bottomRight,
//               child: Text(
//                 formattedDate,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
        backgroundColor: Colors.black87,
        appBar: AppBar(
          title: const Text(
            'Notification',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
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
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white24,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
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
          // Header with notification icon
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white24,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: Colors.pink,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'การแจ้งเตือน',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Content area
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 12),

                // Message body
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),

                // Image if available
                if (imageUrl != null) ...[
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.white10,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.pink),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Timestamp and status
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.pink.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ใหม่',
                        style: TextStyle(
                          color: Colors.pink,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
