// // cameramediapipe.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class CameraMediapipeApp extends StatelessWidget {
//   const CameraMediapipeApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime Pose Detection Demo',
//       home: const CameraMediapipeScreen(),
//     );
//   }
// }

// class CameraMediapipeScreen extends StatefulWidget {
//   const CameraMediapipeScreen({super.key});

//   @override
//   State<CameraMediapipeScreen> createState() => _CameraMediapipeScreenState();
// }

// class _CameraMediapipeScreenState extends State<CameraMediapipeScreen> {
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
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Realtime Pose Detection'),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return Stack(
//             children: [
//               Center(
//                 child: SizedBox(
//                   width: constraints.maxWidth,
//                   height: constraints.maxHeight,
//                   child: AndroidView(
//                     viewType: 'live_camera_view',
//                     creationParams: {
//                       'camera': isFrontCamera ? 'front' : 'rear'
//                     },
//                     creationParamsCodec: const StandardMessageCodec(),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 20,
//                 left: 20,
//                 right: 20,
//                 child: FloatingActionButton(
//                   onPressed: toggleCamera,
//                   backgroundColor: Colors.blue,
//                   child: Icon(
//                     isFrontCamera ? Icons.camera_front : Icons.camera_rear,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraMediapipeApp extends StatelessWidget {
  const CameraMediapipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Pose Detection Demo',
      home: const CameraMediapipeScreen(),
    );
  }
}

class CameraMediapipeScreen extends StatefulWidget {
  const CameraMediapipeScreen({super.key});

  @override
  State<CameraMediapipeScreen> createState() => _CameraMediapipeScreenState();
}

class _CameraMediapipeScreenState extends State<CameraMediapipeScreen> {
  bool isFrontCamera = true;
  static const platform =
      MethodChannel('live_camera_view'); // สร้าง MethodChannel เพียงครั้งเดียว

  void toggleCamera() async {
    try {
      await platform.invokeMethod(
        'switchCamera',
        {'camera': isFrontCamera ? 'front' : 'rear'},
      );
      setState(() {
        isFrontCamera = !isFrontCamera;
      });
    } catch (e) {
      print('Failed to switch camera: $e');
    }
  }

  @override
  void dispose() {
    // หากมีการสร้างทรัพยากรเพิ่มเติมหรือจำเป็นต้องปิดการเชื่อมต่อ ให้เพิ่มโค้ดที่นี่
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Pose Detection'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Center(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: AndroidView(
                    viewType: 'live_camera_view',
                    creationParams: {
                      'camera': isFrontCamera ? 'front' : 'rear'
                    },
                    creationParamsCodec: const StandardMessageCodec(),
                    // ถ้า Flutter SDK และ Native รองรับ Hybrid Composition ให้กำหนด useHybridComposition
                    // เช่น: creationParamsCodec: const StandardMessageCodec(),
                    //         // useHybridComposition: true,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: FloatingActionButton(
                  onPressed: toggleCamera,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
