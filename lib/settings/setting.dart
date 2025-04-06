// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../Sign-In/SignIn.dart';
// import '../changepassword/changepassword.dart';

// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'ตั้งค่า',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildSettingOption(
//                   context,
//                   icon: Icons
//                       .lock_reset, // Changed icon to represent password change
//                   label: 'เปลี่ยนรหัสผ่าน', // Changed label as requested
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const ChangePasswordPage(),
//                       ),
//                     );
//                   },
//                 ),
//                 // _buildSettingOption(
//                 //   context,
//                 //   icon: Icons.notifications,
//                 //   label: 'การแจ้งเตือน - ปิด',
//                 //   onTap: () {
//                 //     // Handle notifications
//                 //   },
//                 // ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             // Delete account button with text label
//             _buildDeleteWithLabel(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSettingOption(
//     BuildContext context, {
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 2),
//             ),
//             child: Icon(
//               icon,
//               color: Colors.white,
//               size: 30,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   // New method for delete button with text label
//   Widget _buildDeleteWithLabel(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _showDeleteConfirmation(context),
//       child: Column(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.red[600],
//             ),
//             child: const Icon(
//               Icons.delete,
//               color: Colors.white,
//               size: 30,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'ลบบัญชี',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDeleteConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('ลบบัญชี'),
//         content: const Text(
//           'ทางเรารู้สึกเศร้าใจมากๆ ที่คุณต้องการเลิกใช้บริการของเรา\nคุณต้องการยืนยันการลบบัญชีหรือไม่?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('ยกเลิก'),
//           ),
//           TextButton(
//             onPressed: () => _deleteAccount(context),
//             style: TextButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text(
//               'ยืนยัน',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _deleteAccount(BuildContext context) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         // Delete user data from Firestore
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .delete();

//         // Delete the user from Firebase Authentication
//         await user.delete();

//         // Sign out the user
//         await FirebaseAuth.instance.signOut();

//         // Navigate to the sign-in page
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const SignInPage()),
//           (route) => false,
//         );
//       }
//     } catch (e) {
//       print('Error deleting account: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('เกิดข้อผิดพลาดในการลบบัญชี')),
//       );
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Sign-In/SignIn.dart';
import '../changepassword/changepassword.dart';
import 'dart:ui';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ตั้งค่า',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1F1F1F),
                  Color(0xFF121212),
                ],
              ),
            ),
          ),

          // Background pattern
          Opacity(
            opacity: 0.05,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://transparenttextures.com/patterns/cubes.png'),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header text
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 20.0),
                    child: Text(
                      'บัญชีของคุณ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Settings options cards
                  _buildSettingsSection(context),

                  const SizedBox(height: 40),

                  // Version info at bottom
                  const Spacer(),
                  Center(
                    child: Text(
                      'เวอร์ชัน 1.0.5',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Change password option
          _buildSettingOption(
            context,
            icon: Icons.lock_outline,
            iconColor: const Color.fromARGB(255, 255, 255, 255),
            label: 'เปลี่ยนรหัสผ่าน',
            description: 'ปรับปรุงความปลอดภัยของบัญชี',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.only(left: 70.0),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          // Delete account option
          _buildSettingOption(
            context,
            icon: Icons.delete_outline,
            iconColor: const Color(0xFFFF5252),
            label: 'ลบบัญชี',
            description: 'ลบข้อมูลบัญชีและประวัติการใช้งานทั้งหมด',
            onTap: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Row(
          children: [
            // Icon with background
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
            ),

            const SizedBox(width: 20),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.navigate_next,
              color: Colors.white.withOpacity(0.4),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF202020),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF5252),
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'ลบบัญชี',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'ทางเรารู้สึกเศร้าใจมากๆ ที่คุณต้องการเลิกใช้บริการของเรา\n\nการลบบัญชีจะเป็นการลบข้อมูลทั้งหมดของคุณอย่างถาวรและไม่สามารถกู้คืนได้ คุณต้องการยืนยันการลบบัญชีหรือไม่?',
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => _deleteAccount(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'ยืนยันการลบบัญชี',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: const AlertDialog(
            backgroundColor: Color(0xFF202020),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  'กำลังลบบัญชี...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();

        // Delete the user from Firebase Authentication
        await user.delete();

        // Sign out the user
        await FirebaseAuth.instance.signOut();

        // Navigate to the sign-in page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
          (route) => false,
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      print('Error deleting account: $e');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    'เกิดข้อผิดพลาดในการลบบัญชี: ${e.toString().substring(0, 50)}...'),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'ปิด',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }
}
