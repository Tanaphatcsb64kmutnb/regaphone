import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'firebase_options.dart'; // Import generated firebase_options.dart
import 'package:regaproject/Home/Home.dart';
import 'Sign-In/SignIn.dart';
import 'Sign-Up/SignUp.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure widgets binding is initialized
  await Firebase.initializeApp(
    // Initialize Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MaterialApp(
      home: SignInPage(),
      debugShowCheckedModeBanner: false, // ปิด Debug Banner
    ),
  );
}


// //main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime Pose Detection Demo',
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Realtime Pose Detection')),
//         body: const LiveCameraScreen(),
//       ),
//     );
//   }
// }

// class LiveCameraScreen extends StatefulWidget {
//   const LiveCameraScreen({super.key});

//   @override
//   State<LiveCameraScreen> createState() => _LiveCameraScreenState();
// }

// class _LiveCameraScreenState extends State<LiveCameraScreen> {
//   bool isFrontCamera = true;

//   void toggleCamera() async {
//     try {
//       const platform = MethodChannel('live_camera_view');
//       await platform.invokeMethod(
//         'switchCamera',
//         {'camera': isFrontCamera ? 'front' : 'rear'},
//       );
//       setState(() {
//         isFrontCamera = !isFrontCamera;
//       });
//     } catch (e) {
//       print('Failed to switch camera: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Stack(
//           children: [
//             Center(
//               child: SizedBox(
//                 width: constraints.maxWidth,
//                 height: constraints.maxHeight,
//                 child: AndroidView(
//                   viewType: 'live_camera_view',
//                   creationParams: {'camera': isFrontCamera ? 'front' : 'rear'},
//                   creationParamsCodec: const StandardMessageCodec(),
//                   onPlatformViewCreated: (int id) {
//                     print('AndroidView created with id: $id');
//                   },
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 20,
//               left: 20,
//               right: 20,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   FloatingActionButton(
//                     onPressed: toggleCamera,
//                     backgroundColor: Colors.blue,
//                     child: Icon(
//                       isFrontCamera ? Icons.camera_front : Icons.camera_rear,
//                       size: 30,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
