// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../Sign-In/SignIn.dart'; // Import your SignInPage

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String username = 'User';

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//   }

//   void _fetchUserData() async {
//     final User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       // Fetch user data from Firestore
//       final DocumentSnapshot userData = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();
//       setState(() {
//         username = userData['username'] ?? 'User';
//       });
//     }
//   }

//   void _showLogoutConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context); // Close the dialog
//             },
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               FirebaseAuth.instance.signOut().then((value) {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const SignInPage()),
//                 );
//               });
//             },
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: const Text(
//           'REGA',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         actions: [
//           Builder(
//             builder: (context) => IconButton(
//               icon: const Icon(Icons.menu, color: Colors.white),
//               onPressed: () {
//                 Scaffold.of(context).openEndDrawer();
//               },
//             ),
//           ),
//         ],
//       ),
//       endDrawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(
//                 color: Colors.black,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'สวัสดี, $username',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   ElevatedButton(
//                     onPressed: () {
//                       _showLogoutConfirmation(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.redAccent,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: const Text('Logout'),
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.home),
//               title: const Text('หน้าหลัก'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.favorite),
//               title: const Text('รายการโปรด'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: Navigate to favorite page
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.history),
//               title: const Text('ประวัติ'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: Navigate to history page
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.contact_mail),
//               title: const Text('ติดต่อเรา'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: Navigate to contact page
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.settings),
//               title: const Text('ตั้งค่า'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: Navigate to settings page
//               },
//             ),
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 16,
//                   crossAxisSpacing: 16,
//                   childAspectRatio: 0.77,
//                   children: [
//                     _buildImageCard(
//                         'รายการโยคะทั้งหมด', 'assets/img/yoga1.png'),
//                     _buildImageCard('รายการโปรดของคุณ', 'assets/img/yoga2.png'),
//                     _buildImageCard(
//                         'ประวัติการเล่นของคุณ', 'assets/img/yoga3.png'),
//                     _buildImageCard('เกี่ยวกับเรา', 'assets/img/yoga4.png'),
//                     _buildImageCard('ติดต่อเรา', 'assets/img/yoga_pose1.png'),
//                     _buildImageCard('ติดต่อเรา', 'assets/img/yoga_pose3.png'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildImageCard(String title, String imageName) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         image: DecorationImage(
//           image: AssetImage(imageName),
//           fit: BoxFit.cover,
//         ),
//       ),
//       child: Container(
//         alignment: Alignment.bottomCenter,
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           title,
//           style: const TextStyle(
//             fontSize: 14,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Sign-In/SignIn.dart';
import '../CameraMediapipe/cameramediapipe.dart';
import '../yogaprogrampose/YogaListPage.dart'; // เพิ่มการ import ไฟล์ YogaListPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = 'User';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        username = userData['username'] ?? 'User';
      });
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              });
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _testMediapipe(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraMediapipeApp()),
    );
  }

  void _contactUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Us'),
        content: const Text('This is the contact us page.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'REGA',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'สวัสดี, $username',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      _showLogoutConfirmation(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('หน้าหลัก'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('รายการโปรด'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('ประวัติ'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail),
              title: const Text('ติดต่อเรา'),
              onTap: () {
                Navigator.pop(context);
                _contactUs(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('ตั้งค่า'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.77,
                  children: [
                    _buildImageCard(
                      'รายการโยคะทั้งหมด',
                      'assets/img/yoga1.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const YogaListPage(),
                          ),
                        );
                      },
                    ),
                    _buildImageCard('รายการโปรดของคุณ', 'assets/img/yoga2.png'),
                    _buildImageCard(
                        'ประวัติการเล่นของคุณ', 'assets/img/yoga3.png'),
                    _buildImageCard('เกี่ยวกับเรา', 'assets/img/yoga4.png'),
                    _buildImageCard('ติดต่อเรา', null,
                        onTap: () => _contactUs(context)),
                    _buildImageCard('ทดลอง Mediapipe', null,
                        onTap: () => _testMediapipe(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(String title, String? imageName,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: imageName != null
              ? DecorationImage(
                  image: AssetImage(imageName),
                  fit: BoxFit.cover,
                )
              : null,
          color: Colors.grey.shade800,
        ),
        child: Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
