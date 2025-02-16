// import 'package:flutter/material.dart';
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
//                   icon: Icons.person,
//                   label: 'แก้ไขโปรไฟล์',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const ChangePasswordPage(),
//                       ),
//                     );
//                   },
//                 ),
//                 _buildSettingOption(
//                   context,
//                   icon: Icons.notifications,
//                   label: 'การแจ้งเตือน - ปิด',
//                   onTap: () {
//                     // Handle notifications
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             _buildDeleteButton(context),
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

//   Widget _buildDeleteButton(BuildContext context) {
//     return Container(
//       width: 60,
//       height: 60,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.red[600],
//       ),
//       child: IconButton(
//         icon: const Icon(
//           Icons.delete,
//           color: Colors.white,
//           size: 30,
//         ),
//         onPressed: () {
//           // Handle delete action
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Sign-In/SignIn.dart';
import '../changepassword/changepassword.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ตั้งค่า',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // _buildSettingOption(
                //   context,
                //   icon: Icons.person,
                //   label: 'แก้ไขโปรไฟล์',
                //   onTap: () {
                //     // Navigate to profile settings
                //   },
                // ),

                _buildSettingOption(
                  context,
                  icon: Icons.person,
                  label: 'แก้ไขโปรไฟล์',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),
                _buildSettingOption(
                  context,
                  icon: Icons.notifications,
                  label: 'การแจ้งเตือน - ปิด',
                  onTap: () {
                    // Handle notifications
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDeleteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red[600],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () {
          _showDeleteConfirmation(context);
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบบัญชี'),
        content: const Text(
          'ทางเรารู้สึกเศร้าใจมากๆ ที่คุณต้องการเลิกใช้บริการของเรา\nคุณต้องการยืนยันการลบบัญชีหรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => _deleteAccount(context),
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'ยืนยัน',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
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
      print('Error deleting account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการลบบัญชี')),
      );
    }
  }
}
