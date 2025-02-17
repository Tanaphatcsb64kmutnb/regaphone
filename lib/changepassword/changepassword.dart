// import 'package:flutter/material.dart';

// class ChangePasswordPage extends StatefulWidget {
//   const ChangePasswordPage({super.key});

//   @override
//   State<ChangePasswordPage> createState() => _ChangePasswordPageState();
// }

// class _ChangePasswordPageState extends State<ChangePasswordPage> {
//   String? _selectedOption;

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
//               'กรุณาเลือกช่องทางการรีเซ็ตรหัสผ่าน OTP',
//               style: TextStyle(
//                 color: Colors.white54,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 30),
//             // Radio options
//             ListTile(
//               title: const Text(
//                 'Email',
//                 style: TextStyle(color: Colors.white),
//               ),
//               contentPadding: EdgeInsets.zero,
//               leading: Radio<String>(
//                 value: 'email',
//                 groupValue: _selectedOption,
//                 onChanged: (String? value) {
//                   setState(() {
//                     _selectedOption = value;
//                   });
//                 },
//                 fillColor: MaterialStateProperty.all(Colors.white),
//               ),
//             ),
//             ListTile(
//               title: const Text(
//                 'เบอร์โทรศัพท์',
//                 style: TextStyle(color: Colors.white),
//               ),
//               contentPadding: EdgeInsets.zero,
//               leading: Radio<String>(
//                 value: 'phone',
//                 groupValue: _selectedOption,
//                 onChanged: (String? value) {
//                   setState(() {
//                     _selectedOption = value;
//                   });
//                 },
//                 fillColor: MaterialStateProperty.all(Colors.white),
//               ),
//             ),
//             const SizedBox(height: 30),
//             // Submit Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Handle password reset logic here
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   'ตกลง',
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
import 'changeuseemail.dart';
import 'changeusetel.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  String? _selectedOption;

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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'กรุณาเลือกช่องทางการรีเซ็ตรหัสผ่าน OTP',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            // Radio options
            ListTile(
              title: const Text(
                'Email',
                style: TextStyle(color: Colors.white),
              ),
              contentPadding: EdgeInsets.zero,
              leading: Radio<String>(
                value: 'email',
                groupValue: _selectedOption,
                onChanged: (String? value) {
                  setState(() {
                    _selectedOption = value;
                  });
                },
                fillColor: MaterialStateProperty.all(Colors.white),
              ),
            ),
            ListTile(
              title: const Text(
                'เบอร์โทรศัพท์',
                style: TextStyle(color: Colors.white),
              ),
              contentPadding: EdgeInsets.zero,
              leading: Radio<String>(
                value: 'phone',
                groupValue: _selectedOption,
                onChanged: (String? value) {
                  setState(() {
                    _selectedOption = value;
                  });
                },
                fillColor: MaterialStateProperty.all(Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedOption == 'email') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangeUseEmailPage(),
                      ),
                    );
                  } else if (_selectedOption == 'phone') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangeUseTelPage(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ตกลง',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
