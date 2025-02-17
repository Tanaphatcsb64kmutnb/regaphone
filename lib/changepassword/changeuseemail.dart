// import 'package:flutter/material.dart';

// class ChangeUseEmailPage extends StatefulWidget {
//   const ChangeUseEmailPage({super.key});

//   @override
//   State<ChangeUseEmailPage> createState() => _ChangeUseEmailPageState();
// }

// class _ChangeUseEmailPageState extends State<ChangeUseEmailPage> {
//   final TextEditingController _otpController = TextEditingController();

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
//           'เปลี่ยนรหัสผ่าน',
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
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'เราได้ส่ง OTP ไปให้คุณเรียบร้อยแล้ว',
//               style: TextStyle(
//                 color: Colors.white54,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: _otpController,
//               keyboardType: TextInputType.number,
//               style: const TextStyle(color: Colors.white),
//               decoration: const InputDecoration(
//                 labelText: 'กรุณากรอกเลข OTP',
//                 labelStyle: TextStyle(color: Colors.white54),
//                 enabledBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white54),
//                 ),
//                 focusedBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // เพิ่มเงื่อนไขหรือฟังก์ชันเพื่อไปหน้าถัดไป
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white24,
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   'ถัดไป',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangeUseEmailPage extends StatefulWidget {
  const ChangeUseEmailPage({super.key});

  @override
  State<ChangeUseEmailPage> createState() => _ChangeUseEmailPageState();
}

class _ChangeUseEmailPageState extends State<ChangeUseEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendPasswordResetEmail() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ส่งลิงก์รีเซ็ตรหัสผ่านไปที่อีเมลแล้ว')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

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
          'เปลี่ยนรหัสผ่านผ่านอีเมล',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'กรุณากรอกอีเมลของคุณ ระบบจะส่งลิงก์รีเซ็ตรหัสผ่านไปให้',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'อีเมล',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sendPasswordResetEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ส่งลิงก์รีเซ็ต',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
