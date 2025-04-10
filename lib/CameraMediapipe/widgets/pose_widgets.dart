// import 'package:flutter/material.dart';

// class PoseDetectionCardWidget extends StatelessWidget {
//   final String currentPose;
//   final double confidence;
//   final bool isConnected;

//   const PoseDetectionCardWidget({
//     super.key,
//     required this.currentPose,
//     required this.confidence,
//     required this.isConnected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: const Color(0xFF13121A).withOpacity(0.85),
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Detected Pose:',
//                 style: TextStyle(
//                   color: Color(0xFF9FA4B4),
//                   fontSize: 14,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: isConnected
//                       ? Colors.green.withOpacity(0.2)
//                       : Colors.red.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       isConnected ? Icons.wifi : Icons.wifi_off,
//                       color: isConnected ? Colors.green : Colors.red,
//                       size: 12,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       isConnected ? 'Connected' : 'Disconnected',
//                       style: TextStyle(
//                         color: isConnected ? Colors.green : Colors.red,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             currentPose,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               const Text(
//                 'Score:',
//                 style: TextStyle(
//                   color: Color(0xFF9FA4B4),
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 '${(confidence * 100).toStringAsFixed(1)}%',
//                 style: TextStyle(
//                   color: confidence > 0.7
//                       ? Colors.green
//                       : confidence > 0.4
//                           ? const Color(0xFFFFA000)
//                           : Colors.red,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Container(
//                   height: 10,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   child: FractionallySizedBox(
//                     alignment: Alignment.centerLeft,
//                     widthFactor: confidence,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: confidence > 0.7
//                             ? Colors.green
//                             : confidence > 0.4
//                                 ? const Color(0xFFFFA000)
//                                 : Colors.red,
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CurrentPoseDisplayWidget extends StatelessWidget {
//   final String poseName;
//   final String detectedPose;
//   final bool isResting;

//   const CurrentPoseDisplayWidget({
//     super.key,
//     required this.poseName,
//     required this.detectedPose,
//     this.isResting = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bool isPoseCorrect = detectedPose == poseName;
//     final bool isLongPoseName = poseName.length > 15;

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF13121A).withOpacity(0.9),
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             spreadRadius: 1,
//           ),
//         ],
//         border: Border.all(
//           color: isResting
//               ? Colors.blueAccent.withOpacity(0.5)
//               : (isPoseCorrect
//                   ? const Color(0xFF4CAF50).withOpacity(0.5)
//                   : Colors.redAccent.withOpacity(0.5)),
//           width: 2,
//         ),
//       ),
//       child: isResting
//           ? const Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.self_improvement,
//                   color: Colors.white70,
//                   size: 28,
//                 ),
//                 SizedBox(width: 12),
//                 Text(
//                   "Resting...",
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             )
//           : Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // For long pose names, use Expanded and handle overflow
//                 Expanded(
//                   child: Center(
//                     child: Text(
//                       poseName,
//                       style: TextStyle(
//                         color: isPoseCorrect ? Colors.green : Colors.white,
//                         fontSize: isLongPoseName
//                             ? 18
//                             : 22, // Smaller font for long names
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                       overflow:
//                           TextOverflow.ellipsis, // Handle extra long names
//                       maxLines: isLongPoseName
//                           ? 2
//                           : 1, // Allow 2 lines for long names
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: isPoseCorrect
//                         ? Colors.green.withOpacity(0.2)
//                         : Colors.red.withOpacity(0.2),
//                   ),
//                   child: Center(
//                     child: Icon(
//                       isPoseCorrect ? Icons.check : Icons.close,
//                       color: isPoseCorrect ? Colors.green : Colors.red,
//                       size: 24,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class PoseDetectionCardWidget extends StatelessWidget {
  final String currentPose;
  final double confidence;
  final bool isConnected;

  const PoseDetectionCardWidget({
    super.key,
    required this.currentPose,
    required this.confidence,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF13121A).withOpacity(0.85),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detected Pose:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF9FA4B4),
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isConnected
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.wifi : Icons.wifi_off,
                      color: isConnected ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isConnected ? 'Connected' : 'Disconnected',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentPose,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Score:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF9FA4B4),
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(confidence * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: confidence > 0.7
                          ? Colors.green
                          : confidence > 0.4
                              ? const Color(0xFFFFA000)
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: confidence,
                    child: Container(
                      decoration: BoxDecoration(
                        color: confidence > 0.7
                            ? Colors.green
                            : confidence > 0.4
                                ? const Color(0xFFFFA000)
                                : Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CurrentPoseDisplayWidget extends StatelessWidget {
  final String poseName;
  final String detectedPose;
  final bool isResting;

  const CurrentPoseDisplayWidget({
    super.key,
    required this.poseName,
    required this.detectedPose,
    this.isResting = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPoseCorrect = detectedPose == poseName;
    final bool isLongPoseName = poseName.length > 15;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF13121A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: isResting
              ? Colors.blueAccent.withOpacity(0.5)
              : (isPoseCorrect
                  ? const Color(0xFF4CAF50).withOpacity(0.5)
                  : Colors.redAccent.withOpacity(0.5)),
          width: 2,
        ),
      ),
      child: isResting
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.self_improvement,
                  color: Colors.white70,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  "Resting...",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // For long pose names, use Expanded and handle overflow
                Expanded(
                  child: Center(
                    child: Text(
                      poseName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isPoseCorrect ? Colors.green : Colors.white,
                            fontSize: isLongPoseName ? 18 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: isLongPoseName ? 2 : 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPoseCorrect
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Icon(
                      isPoseCorrect ? Icons.check : Icons.close,
                      color: isPoseCorrect ? Colors.green : Colors.red,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
