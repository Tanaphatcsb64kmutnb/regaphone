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
import '../yogaprogrampose/YogaListPage.dart';

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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInPage()),
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
            onPressed: () => Navigator.pop(context),
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
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                _buildMainCard(),
                const SizedBox(height: 16),
                _buildGridCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const YogaListPage()),
        );
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: const DecorationImage(
            image: AssetImage('assets/img/yoga1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'รายการโยคะทั้งหมด',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'เริ่มต้นการฝึกโยคะของคุณ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        _buildCard(
          'รายการใช้งานของคุณ',
          'assets/img/yoga2.png',
          onTap: () {
            // Navigate to favorites page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const YogaListPage()),
            );
          },
        ),
        _buildCard(
          'ประวัติการใช้งาน',
          'assets/img/yoga3.png',
          onTap: () {
            // Navigate to history page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const YogaListPage()),
            );
          },
        ),
        _buildCard(
          'เกี่ยวกับเรา',
          'assets/img/yoga4.png',
          onTap: () {
            // Navigate to about page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const YogaListPage()),
            );
          },
        ),
        _buildCard(
          'ติดต่อเรา',
          'assets/img/yoga5.png',
          onTap: () => _contactUs(context),
        ),
        _buildCard(
          'ทดลอง Mediapipe',
          'assets/img/yoga1.png',
          onTap: () => _testMediapipe(context),
        ),
      ],
    );
  }

  Widget _buildCard(String title, String imagePath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white24,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'สวัสดี, $username',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showLogoutConfirmation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('ออกจากระบบ'),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'หน้าหลัก', () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(Icons.favorite, 'รายการโปรด', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const YogaListPage()),
              );
            }),
            _buildDrawerItem(Icons.history, 'ประวัติ', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const YogaListPage()),
              );
            }),
            _buildDrawerItem(Icons.info, 'เกี่ยวกับเรา', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const YogaListPage()),
              );
            }),
            _buildDrawerItem(Icons.contact_mail, 'ติดต่อเรา', () {
              Navigator.pop(context);
              _contactUs(context);
            }),
            _buildDrawerItem(Icons.settings, 'ตั้งค่า', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const YogaListPage()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}
