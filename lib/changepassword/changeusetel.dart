// import 'package:flutter/material.dart';

// class ChangeUseTelPage extends StatefulWidget {
//   const ChangeUseTelPage({super.key});

//   @override
//   State<ChangeUseTelPage> createState() => _ChangeUseTelPageState();
// }

// class _ChangeUseTelPageState extends State<ChangeUseTelPage> {
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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// class ChangeUseTelPage extends StatefulWidget {
//   const ChangeUseTelPage({super.key});

//   @override
//   State<ChangeUseTelPage> createState() => _ChangeUseTelPageState();
// }

// class _ChangeUseTelPageState extends State<ChangeUseTelPage> {
//   final TextEditingController _otpController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String? _verificationId;
//   String? _phoneNumber;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserPhoneNumber();
//   }

//   /// ดึงเบอร์โทรจาก Firestore (users collection)
//   Future<void> _fetchUserPhoneNumber() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();

//       if (doc.exists && doc.data()?['tel'] != null) {
//         String rawPhone = doc.data()!['tel']; // เบอร์ที่ดึงมา
//         String formattedPhone = "+66" + rawPhone.substring(1); // แปลง E.164

//         setState(() {
//           _phoneNumber = formattedPhone;
//         });

//         // ส่ง OTP ทันทีที่ได้เบอร์โทร
//         _sendOTP();
//       } else {
//         _showMessage("❌ ไม่พบเบอร์โทรของคุณ");
//       }
//     }
//   }

//   /// ส่ง OTP ไปที่เบอร์โทร
//   Future<void> _sendOTP() async {
//     if (_phoneNumber == null) return;

//     await _auth.verifyPhoneNumber(
//       phoneNumber: _phoneNumber!,
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         await _auth.signInWithCredential(credential);
//         _showMessage("✅ OTP ยืนยันสำเร็จ!");
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         _showMessage("❌ ส่ง OTP ล้มเหลว: ${e.message}");
//       },
//       codeSent: (String verificationId, int? resendToken) {
//         setState(() {
//           _verificationId = verificationId;
//         });
//         _showMessage("📩 OTP ถูกส่งไปที่ $_phoneNumber");
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         _verificationId = verificationId;
//       },
//     );
//   }

//   /// ตรวจสอบ OTP ที่ผู้ใช้กรอก
//   Future<void> _verifyOTP() async {
//     if (_verificationId == null || _otpController.text.isEmpty) return;

//     try {
//       final credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId!,
//         smsCode: _otpController.text.trim(),
//       );

//       await _auth.signInWithCredential(credential);
//       _showMessage("✅ ยืนยัน OTP สำเร็จ! ไปหน้าถัดไป...");
//       // TODO: นำทางไปหน้าตั้งรหัสผ่านใหม่
//     } catch (e) {
//       _showMessage("❌ OTP ไม่ถูกต้อง");
//     }
//   }

//   /// แสดงข้อความแจ้งเตือน
//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(message, style: const TextStyle(color: Colors.white)),
//       backgroundColor: Colors.red,
//     ));
//   }

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
//         title: const Text('เปลี่ยนรหัสผ่าน',
//             style: TextStyle(color: Colors.white)),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               _phoneNumber == null
//                   ? 'กำลังโหลดเบอร์โทรศัพท์...'
//                   : 'OTP ถูกส่งไปที่ $_phoneNumber',
//               style: const TextStyle(color: Colors.white54, fontSize: 16),
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
//                 onPressed: _verifyOTP,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white24,
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text('ยืนยัน OTP',
//                     style: TextStyle(color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangeUseTelPage extends StatefulWidget {
  const ChangeUseTelPage({super.key});

  @override
  State<ChangeUseTelPage> createState() => _ChangeUseTelPageState();
}

class _ChangeUseTelPageState extends State<ChangeUseTelPage> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _phoneNumber;

  // Mock OTP สำหรับทดสอบ
  final String _mockOTP = "123456";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserPhoneNumber();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserPhoneNumber() async {
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data()?['tel'] != null) {
          String rawPhone = doc.data()!['tel'];
          setState(() {
            _phoneNumber = rawPhone;
            _isLoading = false;
          });
          _showMessage(
              "📱 เบอร์โทรของคุณคือ: $rawPhone\nรหัส OTP คือ: $_mockOTP");
        } else {
          setState(() => _isLoading = false);
          _showMessage("❌ ไม่พบข้อมูลเบอร์โทรศัพท์");
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage("❌ เกิดข้อผิดพลาดในการดึงข้อมูล: ${e.toString()}");
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      _showMessage("⚠️ กรุณากรอกรหัส OTP");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_otpController.text.trim() == _mockOTP) {
        // สำเร็จ
        _showMessage("✅ ยืนยัน OTP สำเร็จ!");

        // TODO: นำทางไปหน้าเปลี่ยนรหัสผ่าน
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const ChangePasswordPage(),
        //   ),
        // );
      } else {
        _showMessage("❌ รหัส OTP ไม่ถูกต้อง กรุณาลองใหม่");
      }
    } catch (e) {
      _showMessage("❌ เกิดข้อผิดพลาด: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: message.startsWith("✅")
          ? Colors.green
          : message.startsWith("⚠️")
              ? Colors.orange
              : Colors.red,
      duration: const Duration(seconds: 3),
    ));
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
          'เปลี่ยนรหัสผ่าน',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ส่วนแสดงข้อมูลเบอร์โทรและ OTP
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _phoneNumber == null
                                ? 'กำลังโหลดข้อมูล...'
                                : 'เบอร์โทรศัพท์: $_phoneNumber',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'รหัส OTP สำหรับทดสอบ: $_mockOTP',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ช่องกรอก OTP
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'กรุณากรอกรหัส OTP',
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        counterStyle: TextStyle(color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ปุ่มยืนยัน OTP
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'ยืนยัน OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
