// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:regaproject/Home/Home.dart';
// import '../Sign-Up/SignUp.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import '../Home/notification_dialog.dart';
// import '../services/session_service.dart';
// import '../changepassword/changeuseemail.dart'; // Import the password reset page

// class SignInPage extends StatefulWidget {
//   final Map<String, dynamic>? pendingNotification;

//   const SignInPage({
//     super.key,
//     this.pendingNotification,
//   });

//   @override
//   _SignInPageState createState() => _SignInPageState();
// }

// class _SignInPageState extends State<SignInPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   bool _isLoading = false;

//   void _signIn() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         // ดึง email จาก username
//         final String email =
//             await _getUserEmailFromUsername(_usernameController.text.trim());

//         // เข้าสู่ระบบด้วย email และ password
//         final UserCredential userCredential =
//             await _auth.signInWithEmailAndPassword(
//           email: email,
//           password: _passwordController.text.trim(),
//         );

//         // บันทึก FCM Token
//         await _saveFCMToken(userCredential.user!.uid);

//         // ดึงข้อมูลผู้ใช้จาก Firestore
//         final userDoc = await _firestore
//             .collection('users')
//             .doc(userCredential.user!.uid)
//             .get();

//         // แปลงข้อมูลเป็น Map
//         final userData = userDoc.data() as Map<String, dynamic>;

//         // บันทึก session
//         await SessionService.saveSession({
//           'uid': userCredential.user!.uid,
//           'email': email,
//           'username': userData['username'],
//           'lastLogin': DateTime.now().toIso8601String(),
//         });

//         if (mounted) {
//           _showLoginSuccessPopup(context);
//         }

//         print('User signed in successfully: ${userCredential.user?.email}');
//       } on FirebaseAuthException catch (e) {
//         String message;
//         if (e.code == 'user-not-found') {
//           message = 'No user found with this username.';
//         } else if (e.code == 'wrong-password') {
//           message = 'Incorrect password.';
//         } else {
//           message = 'Login failed: ${e.message}';
//         }

//         // Show error dialog
//         if (mounted) {
//           _showErrorDialog(message);
//         }
//       } catch (e) {
//         if (mounted) {
//           _showErrorDialog('An error occurred. Please try again.');
//         }
//         print('Error during sign in: $e');
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }

//   Future<String> _getUserEmailFromUsername(String username) async {
//     try {
//       final QuerySnapshot querySnapshot = await _firestore
//           .collection('users')
//           .where('username', isEqualTo: username)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isEmpty) {
//         throw FirebaseAuthException(
//           code: 'user-not-found',
//           message: 'No user found with this username.',
//         );
//       }

//       final String email = querySnapshot.docs.first.get('email') as String;
//       return email;
//     } catch (e) {
//       print('Error getting email from username: $e');
//       rethrow;
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _saveFCMToken(String userId) async {
//     try {
//       final fcmToken = await FirebaseMessaging.instance.getToken();

//       await FirebaseFirestore.instance.collection('users').doc(userId).update({
//         'fcmToken': fcmToken,
//         'tokenUpdatedAt': FieldValue.serverTimestamp()
//       });

//       print('FCM Token saved successfully');
//     } catch (e) {
//       print('Error saving FCM token: $e');
//     }
//   }

//   void _showLoginSuccessPopup(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('Welcome'),
//         content: const Text('You have successfully logged in!'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();

//               if (widget.pendingNotification != null) {
//                 Navigator.of(context).pushReplacement(
//                   MaterialPageRoute(
//                     builder: (context) => NotificationDialog(
//                       notificationData: widget.pendingNotification!,
//                     ),
//                   ),
//                 );
//               } else {
//                 Navigator.of(context).pushReplacement(
//                   MaterialPageRoute(
//                     builder: (context) => const HomePage(),
//                   ),
//                 );
//               }
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _signInWithGoogle() async {
//     // Implement Google Sign-In logic here
//     print('Google Sign-In button clicked');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background Image
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/img/yogabg.png'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           // Overlay
//           Container(
//             color: Colors.black.withOpacity(0.5),
//           ),
//           // Main Content
//           Center(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Text(
//                         'REGA',
//                         style: TextStyle(
//                           fontSize: 40,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 40),
//                       TextFormField(
//                         controller: _usernameController,
//                         style: const TextStyle(color: Colors.white),
//                         decoration: InputDecoration(
//                           labelText: 'USERNAME',
//                           labelStyle: const TextStyle(color: Colors.white),
//                           prefixIcon:
//                               const Icon(Icons.person, color: Colors.white),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white.withOpacity(0.3),
//                           enabled: !_isLoading,
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your username';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _passwordController,
//                         style: const TextStyle(color: Colors.white),
//                         decoration: InputDecoration(
//                           labelText: 'PASSWORD',
//                           labelStyle: const TextStyle(color: Colors.white),
//                           prefixIcon:
//                               const Icon(Icons.lock, color: Colors.white),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white.withOpacity(0.3),
//                           enabled: !_isLoading,
//                         ),
//                         obscureText: true,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your password';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 24),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _isLoading ? null : _signIn,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             backgroundColor: Colors.white.withOpacity(0.9),
//                           ),
//                           child: _isLoading
//                               ? const SizedBox(
//                                   height: 20,
//                                   width: 20,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                         Colors.black),
//                                   ),
//                                 )
//                               : const Text(
//                                   'LOGIN',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextButton(
//                         onPressed: _isLoading
//                             ? null
//                             : () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => const SignUpPage(),
//                                   ),
//                                 );
//                               },
//                         child: const Text(
//                           'Don\'t have an account? SIGN UP',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       const SizedBox(height: 8), // Add spacing between links
//                       TextButton(
//                         onPressed: _isLoading
//                             ? null
//                             : () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         const ChangeUseEmailPage(),
//                                   ),
//                                 );
//                               },
//                         child: const Text(
//                           'Forgot Password?',
//                           style: TextStyle(color: Colors.white70),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton.icon(
//                         onPressed: _isLoading ? null : _signInWithGoogle,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: Colors.black,
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 12,
//                             horizontal: 24,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         icon: const Icon(
//                           Icons.g_mobiledata,
//                           size: 24,
//                         ),
//                         label: const Text('Sign in with Google'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:regaproject/Home/Home.dart';
import '../Sign-Up/SignUp.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../Home/notification_dialog.dart';
import '../services/session_service.dart';
import '../changepassword/changeuseemail.dart';
import '../widgets/no_internet_dialog.dart';
import '../services/connectivity_service.dart';
import '../widgets/login_success_widget.dart'; // Import our new success widget
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatefulWidget {
  final Map<String, dynamic>? pendingNotification;

  const SignInPage({
    super.key,
    this.pendingNotification,
  });

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isLoading = false;

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Check for internet connection first
      bool isConnected = await _connectivityService.checkConnection();
      if (!isConnected) {
        setState(() {
          _isLoading = false;
        });

        // Show no internet dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => NoInternetDialog(
              onRetry: () {
                Navigator.pop(context);
                _signIn(); // Retry login when the user presses "Try Again"
              },
            ),
          );
        }
        return;
      }

      try {
        // ดึง email จาก username
        final String email =
            await _getUserEmailFromUsername(_usernameController.text.trim());

        // เข้าสู่ระบบด้วย email และ password
        final UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: email,
          password: _passwordController.text.trim(),
        );

        // บันทึก FCM Token
        await _saveFCMToken(userCredential.user!.uid);

        // ดึงข้อมูลผู้ใช้จาก Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        // แปลงข้อมูลเป็น Map
        final userData = userDoc.data() as Map<String, dynamic>;

        // บันทึก session
        await SessionService.saveSession({
          'uid': userCredential.user!.uid,
          'email': email,
          'username': userData['username'],
          'lastLogin': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          // Show the beautiful success widget instead of a regular alert dialog
          _showBeautifulLoginSuccess(context, userData['username'] ?? 'User');
        }

        print('User signed in successfully: ${userCredential.user?.email}');
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'No user found with this username.';
        } else if (e.code == 'wrong-password') {
          message = 'Incorrect password.';
        } else if (e.code == 'network-request-failed') {
          // Handle network error from Firebase
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => NoInternetDialog(
                onRetry: () {
                  Navigator.pop(context);
                  _signIn(); // Retry login
                },
              ),
            );
          }
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          return;
        } else {
          message = 'Login failed: ${e.message}';
        }

        // Show error dialog
        if (mounted) {
          _showErrorDialog(message);
        }
      } catch (e) {
        // Check if it's a network error
        if (e.toString().contains('network')) {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => NoInternetDialog(
                onRetry: () {
                  Navigator.pop(context);
                  _signIn(); // Retry login
                },
              ),
            );
          }
        } else {
          if (mounted) {
            _showErrorDialog('An error occurred. Please try again.');
          }
        }
        print('Error during sign in: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<String> _getUserEmailFromUsername(String username) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found with this username.',
        );
      }

      final String email = querySnapshot.docs.first.get('email') as String;
      return email;
    } catch (e) {
      print('Error getting email from username: $e');
      rethrow;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveFCMToken(String userId) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': fcmToken,
        'tokenUpdatedAt': FieldValue.serverTimestamp()
      });

      print('FCM Token saved successfully');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // New beautiful success screen
  void _showBeautifulLoginSuccess(BuildContext context, String username) {
    // Full-screen beautiful success widget with animation
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: SuccessScreen(
              username: username,
              onContinue: () {
                if (widget.pendingNotification != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => NotificationDialog(
                        notificationData: widget.pendingNotification!,
                      ),
                    ),
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  // Old dialog method (kept for reference)
  void _showLoginSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Welcome'),
        content: const Text('You have successfully logged in!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              if (widget.pendingNotification != null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => NotificationDialog(
                      notificationData: widget.pendingNotification!,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    // Check for internet connection first
    bool isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      setState(() {
        _isLoading = false;
      });

      // Show no internet dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => NoInternetDialog(
            onRetry: () {
              Navigator.pop(context);
              _signInWithGoogle(); // Retry Google login when the user presses "Try Again"
            },
          ),
        );
      }
      return;
    }

    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in flow
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain auth details from the Google sign-in
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if this is a new user
      final bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // Create a new user document in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': googleUser.displayName ??
              'User${DateTime.now().millisecondsSinceEpoch}',
          'email': googleUser.email,
          'photoURL': googleUser.photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // บันทึก FCM Token
      await _saveFCMToken(userCredential.user!.uid);

      // บันทึก session
      await SessionService.saveSession({
        'uid': userCredential.user!.uid,
        'email': googleUser.email,
        'username': googleUser.displayName ?? 'User',
        'lastLogin': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        // Show the beautiful success widget
        _showBeautifulLoginSuccess(context, googleUser.displayName ?? 'User');
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
      if (mounted) {
        _showErrorDialog(
            'Failed to sign in with Google. Please try again later.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/yogabg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Main Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'REGA',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'USERNAME',
                          labelStyle: const TextStyle(color: Colors.white),
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.3),
                          enabled: !_isLoading,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'PASSWORD',
                          labelStyle: const TextStyle(color: Colors.white),
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.3),
                          enabled: !_isLoading,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.9),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black),
                                  ),
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpPage(),
                                  ),
                                );
                              },
                        child: const Text(
                          'Don\'t have an account? SIGN UP',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8), // Add spacing between links
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ChangeUseEmailPage(),
                                  ),
                                );
                              },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(
                          Icons.g_mobiledata,
                          size: 24,
                        ),
                        label: const Text('Sign in with Google'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
