// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../models/drawing_path.dart';
// import '../controller/learn_canvas_controller.dart';
//
// class LearnCanvasScreen extends StatelessWidget {
//   final int categoryId;
//   final int drawingId;
//
//   const LearnCanvasScreen(
//       {Key? key, required this.categoryId, required this.drawingId})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(
//         LearnCanvasController(categoryId: categoryId, drawingId: drawingId),
//         tag: 'learn_$categoryId\_$drawingId');
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Obx(() => Text(
//             'Learn - ${controller.currentLevel.value.capitalize ?? controller.currentLevel.value}')),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         elevation: 2,
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         return Column(
//           children: [
//             // Header with level info and controls
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 boxShadow: [
//                   BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2)),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                           'Level: ${controller.currentLevel.value.capitalize ?? controller.currentLevel.value}',
//                           style: const TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),
//                       Column(
//                         children: [
//                           ElevatedButton.icon(
//                             onPressed: controller.toggleDrawingTools,
//                             icon: const Icon(Icons.palette),
//                             label: const Text('Tools'),
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue,
//                                 foregroundColor: Colors.white),
//                           ),
//                           const SizedBox(width: 8),
//                           ElevatedButton.icon(
//                             onPressed: controller.toggleDots,
//                             icon: Icon(controller.showDots.value
//                                 ? Icons.visibility_off
//                                 : Icons.visibility),
//                             label: Text(controller.showDots.value
//                                 ? 'Hide Dots'
//                                 : 'Show Dots'),
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.purple,
//                                 foregroundColor: Colors.white),
//                           ),
//                           const SizedBox(width: 8),
//                           // NEW: Button to use image dots only
//                         ],
//                       ),
//                     ],
//                   ),
//
//                   // Progress indicator
//                   if (!controller.isCompleted.value)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 12),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.info_outline,
//                               size: 16, color: Colors.blue),
//                           const SizedBox(width: 8),
//                           Text(
//                             'Connect dot ${controller.currentDot.value} to dot ${controller.nextDot.value}',
//                             style: const TextStyle(
//                                 fontSize: 14, color: Colors.blue),
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//
//             // Main canvas area
//             Expanded(
//               child: Center(
//                 child: AspectRatio(
//                   aspectRatio: 1, // 400x400 canvas
//                   child: Container(
//                     width: 400,
//                     height: 400,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border.all(color: Colors.grey.shade300),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Stack(
//                       children: [
//                         // Background image
//                         if (controller.imageUrl.value.isNotEmpty)
//                           Positioned.fill(
//                             child: Image.network(
//                               controller.imageUrl.value,
//                               fit: BoxFit.contain,
//                               loadingBuilder:
//                                   (context, child, loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return Center(
//                                   child: CircularProgressIndicator(
//                                     value: loadingProgress.expectedTotalBytes !=
//                                             null
//                                         ? loadingProgress
//                                                 .cumulativeBytesLoaded /
//                                             loadingProgress.expectedTotalBytes!
//                                         : null,
//                                   ),
//                                 );
//                               },
//                               errorBuilder: (context, error, stackTrace) {
//                                 return const Center(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(Icons.error,
//                                           size: 64, color: Colors.red),
//                                       SizedBox(height: 16),
//                                       Text('Failed to load image',
//                                           style: TextStyle(
//                                               fontSize: 16, color: Colors.red)),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//
//                         // Drawing canvas
//                         Positioned.fill(
//                           child: GestureDetector(
//                             onPanStart: (details) =>
//                                 controller.startDrawing(details.localPosition),
//                             onPanUpdate: (details) =>
//                                 controller.updateDrawing(details.localPosition),
//                             onPanEnd: (details) => controller.endDrawing(),
//                             child: CustomPaint(
//                               painter: DrawingPainter(
//                                 completedPaths: controller.drawingPaths,
//                                 currentPath: controller.currentDrawingPoints,
//                                 currentColor: controller.selectedColor.value,
//                                 currentStrokeWidth:
//                                     controller.selectedStrokeWidth.value,
//                                 isDrawing: controller.isDrawing.value,
//                                 dots: controller.dots,
//                                 currentDot: controller.currentDot.value,
//                                 nextDot: controller.nextDot.value,
//                                 showDots: controller.showDots.value,
//                                 dotSize: controller.dotSize.value,
//                               ),
//                               size: const Size(400, 400),
//                             ),
//                           ),
//                         ),
//
//                         // Drawing tools panel
//                         if (controller.showDrawingTools.value)
//                           Positioned(
//                             top: 0,
//                             left: 0,
//                             right: 0,
//                             child: Container(
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 border: Border(
//                                   bottom: BorderSide(
//                                     color: Colors.grey.shade300,
//                                     width: 1,
//                                   ),
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                       color: Colors.black.withOpacity(0.1),
//                                       blurRadius: 4,
//                                       offset: const Offset(0, 2))
//                                 ],
//                               ),
//                               child: Column(
//                                 children: [
//                                   // Colors selection
//                                   Row(
//                                     children: [
//                                       const Text('Colors: ',
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.bold)),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: SingleChildScrollView(
//                                           scrollDirection: Axis.horizontal,
//                                           child: Row(
//                                             children: controller.availableColors
//                                                 .map((color) {
//                                               return GestureDetector(
//                                                 onTap: () => controller
//                                                     .selectColor(color),
//                                                 child: Container(
//                                                   margin: const EdgeInsets.only(
//                                                       right: 8),
//                                                   width: 32,
//                                                   height: 32,
//                                                   decoration: BoxDecoration(
//                                                     color: color,
//                                                     shape: BoxShape.circle,
//                                                     border: Border.all(
//                                                       color: controller
//                                                                   .selectedColor
//                                                                   .value ==
//                                                               color
//                                                           ? Colors.black
//                                                           : Colors
//                                                               .grey.shade300,
//                                                       width: controller
//                                                                   .selectedColor
//                                                                   .value ==
//                                                               color
//                                                           ? 3
//                                                           : 1,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               );
//                                             }).toList(),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 8),
//
//                                   // Stroke width selection
//                                   Row(
//                                     children: [
//                                       const Text('Size: ',
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.bold)),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: SingleChildScrollView(
//                                           scrollDirection: Axis.horizontal,
//                                           child: Row(
//                                             children: controller
//                                                 .availableStrokeWidths
//                                                 .map((width) {
//                                               return GestureDetector(
//                                                 onTap: () => controller
//                                                     .selectStrokeWidth(width),
//                                                 child: Container(
//                                                   margin: const EdgeInsets.only(
//                                                       right: 12),
//                                                   padding: const EdgeInsets
//                                                       .symmetric(
//                                                       horizontal: 8,
//                                                       vertical: 4),
//                                                   decoration: BoxDecoration(
//                                                     color: controller
//                                                                 .selectedStrokeWidth
//                                                                 .value ==
//                                                             width
//                                                         ? Colors.blue
//                                                         : Colors.grey.shade200,
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             4),
//                                                     border: Border.all(
//                                                       color: controller
//                                                                   .selectedStrokeWidth
//                                                                   .value ==
//                                                               width
//                                                           ? Colors.blue
//                                                           : Colors
//                                                               .grey.shade300,
//                                                     ),
//                                                   ),
//                                                   child: Row(
//                                                     mainAxisSize:
//                                                         MainAxisSize.min,
//                                                     children: [
//                                                       Container(
//                                                         width: 20,
//                                                         height: width,
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color: controller
//                                                                       .selectedStrokeWidth
//                                                                       .value ==
//                                                                   width
//                                                               ? Colors.white
//                                                               : Colors.black,
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       width /
//                                                                           2),
//                                                         ),
//                                                       ),
//                                                       const SizedBox(width: 4),
//                                                       Text('${width.toInt()}px',
//                                                           style: TextStyle(
//                                                             fontSize: 12,
//                                                             color: controller
//                                                                         .selectedStrokeWidth
//                                                                         .value ==
//                                                                     width
//                                                                 ? Colors.white
//                                                                 : Colors.black,
//                                                           )),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               );
//                                             }).toList(),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//
//                                   // Dot settings (when dots are enabled)
//                                   if (controller.showDots.value) ...[
//                                     const SizedBox(height: 12),
//                                     Row(
//                                       children: [
//                                         const Text('Dot Size: ',
//                                             style: TextStyle(
//                                                 fontWeight: FontWeight.bold)),
//                                         Expanded(
//                                           child: Slider(
//                                             value: controller.dotSize.value,
//                                             min: 5.0,
//                                             max: 20.0,
//                                             divisions: 15,
//                                             label: controller.dotSize.value
//                                                 .round()
//                                                 .toString(),
//                                             onChanged: controller.adjustDotSize,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 16),
//                                         const Text('Tolerance: ',
//                                             style: TextStyle(
//                                                 fontWeight: FontWeight.bold)),
//                                         Expanded(
//                                           child: Slider(
//                                             value:
//                                                 controller.dotTolerance.value,
//                                             min: 10.0,
//                                             max: 50.0,
//                                             divisions: 40,
//                                             label: controller.dotTolerance.value
//                                                 .round()
//                                                 .toString(),
//                                             onChanged:
//                                                 controller.adjustDotTolerance,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ],
//                               ),
//                             ),
//                           ),
//
//                         // Completion overlay
//                         if (controller.isCompleted.value)
//                           Positioned.fill(
//                             child: Container(
//                               color: Colors.black.withOpacity(0.7),
//                               child: Center(
//                                 child: Card(
//                                   margin: const EdgeInsets.all(32),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(24),
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         const Icon(Icons.check_circle,
//                                             size: 64, color: Colors.green),
//                                         const SizedBox(height: 16),
//                                         const Text('Level Completed!',
//                                             style: TextStyle(
//                                                 fontSize: 24,
//                                                 fontWeight: FontWeight.bold)),
//                                         const SizedBox(height: 8),
//                                         Text(
//                                             'Great job completing ${controller.currentLevel.value.capitalize ?? controller.currentLevel.value} level!',
//                                             textAlign: TextAlign.center,
//                                             style:
//                                                 const TextStyle(fontSize: 16)),
//                                         const SizedBox(height: 24),
//                                         Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             if (controller.levels.indexOf(
//                                                     controller
//                                                         .currentLevel.value) <
//                                                 2)
//                                               ElevatedButton(
//                                                 onPressed: controller.nextLevel,
//                                                 style: ElevatedButton.styleFrom(
//                                                     backgroundColor:
//                                                         Colors.green,
//                                                     foregroundColor:
//                                                         Colors.white),
//                                                 child: const Text('Next Level'),
//                                               )
//                                             else
//                                               ElevatedButton(
//                                                 onPressed: () => Get.back(),
//                                                 style: ElevatedButton.styleFrom(
//                                                     backgroundColor:
//                                                         Colors.blue,
//                                                     foregroundColor:
//                                                         Colors.white),
//                                                 child: const Text('Finish'),
//                                               ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // Bottom status and message area
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 boxShadow: [
//                   BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 4,
//                       offset: const Offset(0, -2))
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Message display
//                   if (controller.message.value.isNotEmpty)
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 12),
//                       margin: const EdgeInsets.only(bottom: 16),
//                       decoration: BoxDecoration(
//                         color: controller.isSuccessMessage.value
//                             ? Colors.green.withOpacity(0.1)
//                             : Colors.red.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: controller.isSuccessMessage.value
//                               ? Colors.green
//                               : Colors.red,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             controller.isSuccessMessage.value
//                                 ? Icons.check_circle
//                                 : Icons.error,
//                             color: controller.isSuccessMessage.value
//                                 ? Colors.green
//                                 : Colors.red,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               controller.message.value,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: controller.isSuccessMessage.value
//                                     ? Colors.green.shade800
//                                     : Colors.red.shade800,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                   // Action buttons
//                   Row(
//                     children: [
//                       // Next Level button (only when level is completed but not all levels)
//                       if (controller.showNextLevelButton.value &&
//                           controller.levels
//                                   .indexOf(controller.currentLevel.value) <
//                               2)
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: controller.nextLevel,
//                             icon: const Icon(Icons.arrow_forward),
//                             label: const Text('Next Level'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                           ),
//                         ),
//
//                       // Finish button (when all levels completed)
//                       if (controller.showNextLevelButton.value &&
//                           controller.levels
//                                   .indexOf(controller.currentLevel.value) >=
//                               2)
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: () => Get.back(),
//                             icon: const Icon(Icons.check),
//                             label: const Text('Finish'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }
//
// class DrawingPainter extends CustomPainter {
//   final List<DrawingPath> completedPaths;
//   final List<Offset> currentPath;
//   final Color currentColor;
//   final double currentStrokeWidth;
//   final bool isDrawing;
//   final List<Map<String, dynamic>> dots;
//   final int currentDot;
//   final int nextDot;
//   final bool showDots;
//   final double dotSize;
//
//   DrawingPainter({
//     required this.completedPaths,
//     required this.currentPath,
//     required this.currentColor,
//     required this.currentStrokeWidth,
//     required this.isDrawing,
//     required this.dots,
//     required this.currentDot,
//     required this.nextDot,
//     required this.showDots,
//     required this.dotSize,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // Draw completed paths
//     for (final path in completedPaths) {
//       if (path.points.isNotEmpty) {
//         final paint = Paint()
//           ..color = path.color
//           ..strokeWidth = path.strokeWidth
//           ..strokeCap = StrokeCap.round
//           ..strokeJoin = StrokeJoin.round
//           ..style = PaintingStyle.stroke;
//
//         final pathObj = Path()
//           ..moveTo(path.points.first.dx, path.points.first.dy);
//         for (int i = 1; i < path.points.length; i++) {
//           pathObj.lineTo(path.points[i].dx, path.points[i].dy);
//         }
//         canvas.drawPath(pathObj, paint);
//       }
//     }
//
//     // Draw current path
//     if (currentPath.isNotEmpty) {
//       final paint = Paint()
//         ..color = currentColor.withOpacity(0.8)
//         ..strokeWidth = currentStrokeWidth
//         ..strokeCap = StrokeCap.round
//         ..strokeJoin = StrokeJoin.round
//         ..style = PaintingStyle.stroke;
//
//       final path = Path()..moveTo(currentPath.first.dx, currentPath.first.dy);
//       for (int i = 1; i < currentPath.length; i++) {
//         path.lineTo(currentPath[i].dx, currentPath[i].dy);
//       }
//       canvas.drawPath(path, paint);
//     }
//
//     // Draw dots only if enabled
//     if (showDots) {
//       final dotPaint = Paint()
//         ..color = Colors.black.withOpacity(0.6)
//         ..style = PaintingStyle.fill;
//       final currentDotPaint = Paint()
//         ..color = Colors.green
//         ..style = PaintingStyle.fill;
//       final nextDotPaint = Paint()
//         ..color = Colors.red
//         ..style = PaintingStyle.fill;
//
//       for (var dot in dots) {
//         final x = dot['x'].toDouble();
//         final y = dot['y'].toDouble();
//         final number = dot['number'] as int;
//
//         // Choose paint based on dot type
//         final paint = number == currentDot
//             ? currentDotPaint
//             : number == nextDot
//                 ? nextDotPaint
//                 : dotPaint;
//
//         // Draw dot circle
//         canvas.drawCircle(Offset(x, y), dotSize, paint);
//
//         // Draw dot number
//         final textPainter = TextPainter(
//           text: TextSpan(
//             text: number.toString(),
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: dotSize * 0.8,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           textDirection: TextDirection.ltr,
//         );
//         textPainter.layout();
//
//         // Center the text on the dot
//         final textOffset = Offset(
//           x - textPainter.width / 2,
//           y - textPainter.height / 2,
//         );
//         textPainter.paint(canvas, textOffset);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../models/drawing_path.dart';
// import '../../../widgets/custom_app_bar.dart';
// import '../controller/learn_canvas_controller.dart';
// import '../../../const/app_colors.dart';
//
// class LearnCanvasScreen extends StatelessWidget {
//   final int categoryId;
//   final int drawingId;
//
//   const LearnCanvasScreen(
//       {Key? key, required this.categoryId, required this.drawingId})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(
//         LearnCanvasController(categoryId: categoryId, drawingId: drawingId),
//         tag: 'learn_$categoryId\_$drawingId');
//
//     return Scaffold(
//       appBar: CustomAppBar(
//         title:
//             'Learn - ${controller.currentLevel.value.capitalize ?? controller.currentLevel.value}',
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: Container(
//         color: const Color(0xFFE0FFFF), // Light cyan for visibility
//         child: Obx(() {
//           if (controller.isLoading.value) {
//             return const Center(
//               child: CircularProgressIndicator(color: AppColors.primaryColor),
//             );
//           }
//
//           return Column(
//             children: [
//               // Top message and Hide/Show Dots
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [
//                       AppColors.primaryColor,
//                       AppColors.accentColor,
//                     ],
//                   ),
//                   borderRadius: const BorderRadius.vertical(
//                     bottom: Radius.circular(12),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.15),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Message display
//                     if (controller.message.value.isNotEmpty)
//                       Expanded(
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 8),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: controller.isSuccessMessage.value
//                                   ? [
//                                       Colors.green.shade300,
//                                       Colors.green.shade500,
//                                     ]
//                                   : [
//                                       Colors.red.shade300,
//                                       Colors.red.shade500,
//                                     ],
//                             ),
//                             borderRadius: BorderRadius.circular(8),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.15),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 controller.isSuccessMessage.value
//                                     ? Icons.star
//                                     : Icons.error,
//                                 color: Colors.white,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   controller.message.value,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w500,
//                                     fontFamily: 'Comic Sans MS',
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     else
//                       const SizedBox.shrink(),
//                     // Hide/Show Dots toggle
//                     GestureDetector(
//                       onTap: controller.toggleDots,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 8),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [
//                               AppColors.accentColor,
//                               AppColors.primaryColor,
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.15),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               controller.showDots.value
//                                   ? Icons.visibility_off
//                                   : Icons.visibility,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                                 controller.showDots.value
//                                     ? 'Hide Dots 👀'
//                                     : 'Show Dots 👀',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontFamily: 'Comic Sans MS',
//                                   fontSize: 16,
//                                 )),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Main canvas area
//               Expanded(
//                 child: Center(
//                   child: AspectRatio(
//                     aspectRatio: 1, // 400x400 canvas
//                     child: Container(
//                       width: 400,
//                       height: 400,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [
//                             AppColors.accentColor,
//                             AppColors.primaryColor,
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.15),
//                             blurRadius: 8,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Stack(
//                           children: [
//                             // Background image
//                             if (controller.imageUrl.value.isNotEmpty)
//                               Positioned.fill(
//                                 child: Image.network(
//                                   controller.imageUrl.value,
//                                   fit: BoxFit.contain,
//                                   loadingBuilder:
//                                       (context, child, loadingProgress) {
//                                     if (loadingProgress == null) return child;
//                                     return Center(
//                                       child: CircularProgressIndicator(
//                                         value: loadingProgress
//                                                     .expectedTotalBytes !=
//                                                 null
//                                             ? loadingProgress
//                                                     .cumulativeBytesLoaded /
//                                                 loadingProgress
//                                                     .expectedTotalBytes!
//                                             : null,
//                                         color: AppColors.primaryColor,
//                                       ),
//                                     );
//                                   },
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return const Center(
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Icon(Icons.image,
//                                               size: 64,
//                                               color: AppColors.textColor),
//                                           SizedBox(height: 16),
//                                           Text(
//                                             'Failed to load image 😊',
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               color: AppColors.textColor,
//                                               fontFamily: 'Comic Sans MS',
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             // Drawing canvas
//                             Positioned.fill(
//                               child: GestureDetector(
//                                 onPanStart: (details) => controller
//                                     .startDrawing(details.localPosition),
//                                 onPanUpdate: (details) => controller
//                                     .updateDrawing(details.localPosition),
//                                 onPanEnd: (details) => controller.endDrawing(),
//                                 child: CustomPaint(
//                                   painter: DrawingPainter(
//                                     completedPaths: controller.drawingPaths,
//                                     currentPath:
//                                         controller.currentDrawingPoints,
//                                     currentColor:
//                                         controller.selectedColor.value,
//                                     currentStrokeWidth:
//                                         controller.selectedStrokeWidth.value,
//                                     isDrawing: controller.isDrawing.value,
//                                     dots: controller.dots,
//                                     currentDot: controller.currentDot.value,
//                                     nextDot: controller.nextDot.value,
//                                     showDots: controller.showDots.value,
//                                     dotSize: controller.dotSize.value,
//                                   ),
//                                   size: const Size(400, 400),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               // Bottom status with tools toggle
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [
//                       AppColors.primaryColor,
//                       AppColors.accentColor,
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.15),
//                       blurRadius: 8,
//                       offset: const Offset(0, -4),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Tools toggle
//                     GestureDetector(
//                       onTap: controller.toggleDrawingTools,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 8),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [
//                               AppColors.accentColor,
//                               AppColors.primaryColor,
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.15),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           children: const [
//                             Icon(Icons.palette, color: Colors.white, size: 20),
//                             SizedBox(width: 4),
//                             Text('Tools 🎨',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontFamily: 'Comic Sans MS',
//                                   fontSize: 16,
//                                 )),
//                           ],
//                         ),
//                       ),
//                     ),
//                     // Next Level button
//                     if (controller.showNextLevelButton.value &&
//                         controller.levels
//                                 .indexOf(controller.currentLevel.value) <
//                             2)
//                       Container(
//                         margin: const EdgeInsets.only(left: 16),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [
//                               AppColors.accentColor,
//                               AppColors.primaryColor,
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.15),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: ElevatedButton.icon(
//                           onPressed: controller.nextLevel,
//                           icon: const Icon(Icons.arrow_forward,
//                               color: Colors.white),
//                           label: const Text(
//                             'Next Level',
//                             style: TextStyle(
//                               fontFamily: 'Comic Sans MS',
//                               fontSize: 16,
//                             ),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.transparent,
//                             shadowColor: Colors.transparent,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 12, horizontal: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     // Finish button
//                     if (controller.showNextLevelButton.value &&
//                         controller.levels
//                                 .indexOf(controller.currentLevel.value) >=
//                             2)
//                       Container(
//                         margin: const EdgeInsets.only(left: 16),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [
//                               AppColors.accentColor,
//                               AppColors.primaryColor,
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.15),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: ElevatedButton.icon(
//                           onPressed: () => Get.back(),
//                           icon: const Icon(Icons.check, color: Colors.white),
//                           label: const Text(
//                             'Finish',
//                             style: TextStyle(
//                               fontFamily: 'Comic Sans MS',
//                               fontSize: 16,
//                             ),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.transparent,
//                             shadowColor: Colors.transparent,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 12, horizontal: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               // Tools panel (fixed bottom overlay)
//               Obx(() => AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     height: controller.showDrawingTools.value ? 50 : 0,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [
//                           AppColors.primaryColor,
//                           AppColors.accentColor,
//                         ],
//                       ),
//                       borderRadius: const BorderRadius.vertical(
//                         top: Radius.circular(20),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.15),
//                           blurRadius: 8,
//                           offset: const Offset(0, -4),
//                         ),
//                       ],
//                     ),
//                     child: controller.showDrawingTools.value
//                         ? SingleChildScrollView(
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Colors selection
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       'Colors: 🎨',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: Colors.white,
//                                         fontFamily: 'Comic Sans MS',
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: SingleChildScrollView(
//                                         scrollDirection: Axis.horizontal,
//                                         child: Row(
//                                           children: controller.availableColors
//                                               .map((color) {
//                                             return GestureDetector(
//                                               onTap: () =>
//                                                   controller.selectColor(color),
//                                               child: Container(
//                                                 margin: const EdgeInsets.only(
//                                                     right: 8),
//                                                 width: 32,
//                                                 height: 32,
//                                                 decoration: BoxDecoration(
//                                                   color: color,
//                                                   shape: BoxShape.circle,
//                                                   border: Border.all(
//                                                     color: controller
//                                                                 .selectedColor
//                                                                 .value ==
//                                                             color
//                                                         ? AppColors.textColor
//                                                         : Colors.white,
//                                                     width: controller
//                                                                 .selectedColor
//                                                                 .value ==
//                                                             color
//                                                         ? 3
//                                                         : 1,
//                                                   ),
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Colors.black
//                                                           .withOpacity(0.15),
//                                                       blurRadius: 4,
//                                                       offset:
//                                                           const Offset(0, 2),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             );
//                                           }).toList(),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 8),
//                                 // Stroke width selection
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       'Size: 🖌️',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: Colors.white,
//                                         fontFamily: 'Comic Sans MS',
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: SingleChildScrollView(
//                                         scrollDirection: Axis.horizontal,
//                                         child: Row(
//                                           children: controller
//                                               .availableStrokeWidths
//                                               .map((width) {
//                                             return GestureDetector(
//                                               onTap: () => controller
//                                                   .selectStrokeWidth(width),
//                                               child: Container(
//                                                 margin: const EdgeInsets.only(
//                                                     right: 12),
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 8,
//                                                         vertical: 4),
//                                                 decoration: BoxDecoration(
//                                                   gradient: controller
//                                                               .selectedStrokeWidth
//                                                               .value ==
//                                                           width
//                                                       ? const LinearGradient(
//                                                           colors: [
//                                                             AppColors
//                                                                 .accentColor,
//                                                             AppColors
//                                                                 .primaryColor,
//                                                           ],
//                                                         )
//                                                       : null,
//                                                   color: controller
//                                                               .selectedStrokeWidth
//                                                               .value ==
//                                                           width
//                                                       ? null
//                                                       : Colors.white
//                                                           .withOpacity(0.9),
//                                                   borderRadius:
//                                                       BorderRadius.circular(8),
//                                                   border: Border.all(
//                                                     color: Colors.white,
//                                                     width: 1,
//                                                   ),
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Colors.black
//                                                           .withOpacity(0.15),
//                                                       blurRadius: 4,
//                                                       offset:
//                                                           const Offset(0, 2),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 child: Row(
//                                                   mainAxisSize:
//                                                       MainAxisSize.min,
//                                                   children: [
//                                                     Container(
//                                                       width: 20,
//                                                       height: width,
//                                                       decoration: BoxDecoration(
//                                                         color: controller
//                                                                     .selectedStrokeWidth
//                                                                     .value ==
//                                                                 width
//                                                             ? Colors.white
//                                                             : AppColors
//                                                                 .textColor,
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(
//                                                                     width / 2),
//                                                       ),
//                                                     ),
//                                                     const SizedBox(width: 4),
//                                                     Text(
//                                                       '${width.toInt()}px',
//                                                       style: TextStyle(
//                                                         fontSize: 12,
//                                                         color: controller
//                                                                     .selectedStrokeWidth
//                                                                     .value ==
//                                                                 width
//                                                             ? Colors.white
//                                                             : AppColors
//                                                                 .textColor,
//                                                         fontFamily:
//                                                             'Comic Sans MS',
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             );
//                                           }).toList(),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 // // Dot settings (when dots are enabled)
//                                 // if (controller.showDots.value)
//                                 //   Column(
//                                 //     children: [
//                                 //       const SizedBox(height: 12),
//                                 //       Row(
//                                 //         children: [
//                                 //           const Text(
//                                 //             'Dot Size: ⚪',
//                                 //             style: TextStyle(
//                                 //               fontWeight: FontWeight.bold,
//                                 //               fontSize: 16,
//                                 //               color: Colors.white,
//                                 //               fontFamily: 'Comic Sans MS',
//                                 //             ),
//                                 //           ),
//                                 //           Expanded(
//                                 //             child: Slider(
//                                 //               value: controller.dotSize.value,
//                                 //               min: 5.0,
//                                 //               max: 20.0,
//                                 //               divisions: 15,
//                                 //               label: controller.dotSize.value
//                                 //                   .round()
//                                 //                   .toString(),
//                                 //               activeColor:
//                                 //                   AppColors.accentColor,
//                                 //               inactiveColor: AppColors
//                                 //                   .accentColor
//                                 //                   .withOpacity(0.3),
//                                 //               onChanged:
//                                 //                   controller.adjustDotSize,
//                                 //             ),
//                                 //           ),
//                                 //         ],
//                                 //       ),
//                                 //     ],
//                                 //   ),
//                               ],
//                             ),
//                           )
//                         : null,
//                   )),
//               // Bottom stars decoration
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildStar(Colors.yellow, 20),
//                   _buildStar(Colors.blue, 18),
//                   _buildStar(Colors.red, 20),
//                 ],
//               ),
//               const SizedBox(height: 16),
//             ],
//           );
//         }),
//       ),
//     );
//   }
//
//   Widget _buildStar(Color color, double size) {
//     return Icon(
//       Icons.star,
//       color: color,
//       size: size,
//       shadows: [
//         Shadow(
//           color: Colors.black.withOpacity(0.2),
//           offset: const Offset(1, 1),
//           blurRadius: 4,
//         ),
//       ],
//     );
//   }
// }
//
// class DrawingPainter extends CustomPainter {
//   final List<DrawingPath> completedPaths;
//   final List<Offset> currentPath;
//   final Color currentColor;
//   final double currentStrokeWidth;
//   final bool isDrawing;
//   final List<Map<String, dynamic>> dots;
//   final int currentDot;
//   final int nextDot;
//   final bool showDots;
//   final double dotSize;
//
//   DrawingPainter({
//     required this.completedPaths,
//     required this.currentPath,
//     required this.currentColor,
//     required this.currentStrokeWidth,
//     required this.isDrawing,
//     required this.dots,
//     required this.currentDot,
//     required this.nextDot,
//     required this.showDots,
//     required this.dotSize,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // Draw completed paths
//     for (final path in completedPaths) {
//       if (path.points.isNotEmpty) {
//         final paint = Paint()
//           ..color = path.color
//           ..strokeWidth = path.strokeWidth
//           ..strokeCap = StrokeCap.round
//           ..strokeJoin = StrokeJoin.round
//           ..style = PaintingStyle.stroke;
//
//         final pathObj = Path()
//           ..moveTo(path.points.first.dx, path.points.first.dy);
//         for (int i = 1; i < path.points.length; i++) {
//           pathObj.lineTo(path.points[i].dx, path.points[i].dy);
//         }
//         canvas.drawPath(pathObj, paint);
//       }
//     }
//
//     // Draw current path
//     if (currentPath.isNotEmpty) {
//       final paint = Paint()
//         ..color = currentColor.withOpacity(0.8)
//         ..strokeWidth = currentStrokeWidth
//         ..strokeCap = StrokeCap.round
//         ..strokeJoin = StrokeJoin.round
//         ..style = PaintingStyle.stroke;
//
//       final path = Path()..moveTo(currentPath.first.dx, currentPath.first.dy);
//       for (int i = 1; i < currentPath.length; i++) {
//         path.lineTo(currentPath[i].dx, currentPath[i].dy);
//       }
//       canvas.drawPath(path, paint);
//     }
//
//     // Draw dots only if enabled
//     if (showDots) {
//       final dotPaint = Paint()
//         ..color = Colors.black.withOpacity(0.6)
//         ..style = PaintingStyle.fill;
//       final currentDotPaint = Paint()
//         ..color = Colors.green
//         ..style = PaintingStyle.fill;
//       final nextDotPaint = Paint()
//         ..color = Colors.red
//         ..style = PaintingStyle.fill;
//
//       for (var dot in dots) {
//         final x = dot['x'].toDouble();
//         final y = dot['y'].toDouble();
//         final number = dot['number'] as int;
//
//         // Choose paint based on dot type
//         final paint = number == currentDot
//             ? currentDotPaint
//             : number == nextDot
//                 ? nextDotPaint
//                 : dotPaint;
//
//         // Draw dot circle
//         canvas.drawCircle(Offset(x, y), dotSize, paint);
//
//         // Draw dot number
//         final textPainter = TextPainter(
//           text: TextSpan(
//             text: number.toString(),
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: dotSize * 0.8,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           textDirection: TextDirection.ltr,
//         );
//         textPainter.layout();
//
//         // Center the text on the dot
//         final textOffset = Offset(
//           x - textPainter.width / 2,
//           y - textPainter.height / 2,
//         );
//         textPainter.paint(canvas, textOffset);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/drawing_path.dart';
import '../../../widgets/custom_app_bar.dart';
import '../controller/learn_canvas_controller.dart';
import '../../../const/app_colors.dart';

class LearnCanvasScreen extends StatelessWidget {
  final int categoryId;
  final int drawingId;

  const LearnCanvasScreen(
      {Key? key, required this.categoryId, required this.drawingId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
        LearnCanvasController(categoryId: categoryId, drawingId: drawingId),
        tag: 'learn_$categoryId\_$drawingId');

    return Scaffold(
      appBar: CustomAppBar(
        title:
            'Learn - ${controller.currentLevel.value.capitalize ?? controller.currentLevel.value}',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        color: const Color(0xFFE0FFFF), // Light cyan for visibility
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          return Stack(
            children: [
              // Main canvas area
              Center(
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.accentColor,
                        AppColors.primaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        // Background image
                        if (controller.imageUrl.value.isNotEmpty)
                          Positioned.fill(
                            child: Image.network(
                              controller.imageUrl.value,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: AppColors.primaryColor,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image,
                                          size: 64, color: AppColors.textColor),
                                      SizedBox(height: 16),
                                      Text(
                                        'Failed to load image 😊',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textColor,
                                          fontFamily: 'Comic Sans MS',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        // Drawing canvas
                        Positioned.fill(
                          child: GestureDetector(
                            onPanStart: (details) =>
                                controller.startDrawing(details.localPosition),
                            onPanUpdate: (details) =>
                                controller.updateDrawing(details.localPosition),
                            onPanEnd: (details) => controller.endDrawing(),
                            child: CustomPaint(
                              painter: DrawingPainter(
                                completedPaths: controller.drawingPaths,
                                currentPath: controller.currentDrawingPoints,
                                currentColor: controller.selectedColor.value,
                                currentStrokeWidth:
                                    controller.selectedStrokeWidth.value,
                                isDrawing: controller.isDrawing.value,
                                dots: controller.dots,
                                currentDot: controller.currentDot.value,
                                nextDot: controller.nextDot.value,
                                showDots: controller.showDots.value,
                                dotSize: controller.dotSize.value,
                              ),
                              size: const Size(400, 400),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Top message and Hide/Show Dots
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.accentColor,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Message display
                    if (controller.message.value.isNotEmpty)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: controller.isSuccessMessage.value
                                  ? [
                                      Colors.green.shade300,
                                      Colors.green.shade500,
                                    ]
                                  : [
                                      Colors.red.shade300,
                                      Colors.red.shade500,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                controller.isSuccessMessage.value
                                    ? Icons.star
                                    : Icons.error,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.message.value,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Comic Sans MS',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    // Hide/Show Dots toggle
                    GestureDetector(
                      onTap: controller.toggleDots,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.accentColor,
                              AppColors.primaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              controller.showDots.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                                controller.showDots.value
                                    ? 'Hide Dots 👀'
                                    : 'Show Dots 👀',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Comic Sans MS',
                                  fontSize: 16,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom status with tools toggle and action buttons
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.accentColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tools toggle
                      GestureDetector(
                        onTap: controller.toggleDrawingTools,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.accentColor,
                                AppColors.primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.palette,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 4),
                              Text('Tools 🎨',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Comic Sans MS',
                                    fontSize: 16,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      // Next Level button
                      if (controller.showNextLevelButton.value &&
                          controller.levels
                                  .indexOf(controller.currentLevel.value) <
                              2)
                        Container(
                          margin: const EdgeInsets.only(left: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.accentColor,
                                AppColors.primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: controller.nextLevel,
                            icon: const Icon(Icons.arrow_forward,
                                color: Colors.white),
                            label: const Text(
                              'Next Level',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      // Finish button
                      if (controller.showNextLevelButton.value &&
                          controller.levels
                                  .indexOf(controller.currentLevel.value) >=
                              2)
                        Container(
                          margin: const EdgeInsets.only(left: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.accentColor,
                                AppColors.primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text(
                              'Finish',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Tools panel (overlay on top of bottom status)
              Obx(() => Positioned(
                    left: 0,
                    right: 0,
                    bottom: 60,
                    // Height of the bottom status container + margin
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: controller.showDrawingTools.value ? 100 : 0,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.accentColor,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: controller.showDrawingTools.value
                          ? SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Colors selection
                                  Row(
                                    children: [
                                      const Text(
                                        'Colors: 🎨',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontFamily: 'Comic Sans MS',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: controller.availableColors
                                                .map((color) {
                                              return GestureDetector(
                                                onTap: () => controller
                                                    .selectColor(color),
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 8),
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: controller
                                                                  .selectedColor
                                                                  .value ==
                                                              color
                                                          ? AppColors.textColor
                                                          : Colors.white,
                                                      width: controller
                                                                  .selectedColor
                                                                  .value ==
                                                              color
                                                          ? 3
                                                          : 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.15),
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Stroke width selection
                                  Row(
                                    children: [
                                      const Text(
                                        'Size: 🖌️',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontFamily: 'Comic Sans MS',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: controller
                                                .availableStrokeWidths
                                                .map((width) {
                                              return GestureDetector(
                                                onTap: () => controller
                                                    .selectStrokeWidth(width),
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 12),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    gradient: controller
                                                                .selectedStrokeWidth
                                                                .value ==
                                                            width
                                                        ? const LinearGradient(
                                                            colors: [
                                                              AppColors
                                                                  .accentColor,
                                                              AppColors
                                                                  .primaryColor,
                                                            ],
                                                          )
                                                        : null,
                                                    color: controller
                                                                .selectedStrokeWidth
                                                                .value ==
                                                            width
                                                        ? null
                                                        : Colors.white
                                                            .withOpacity(0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.15),
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 20,
                                                        height: width,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: controller
                                                                      .selectedStrokeWidth
                                                                      .value ==
                                                                  width
                                                              ? Colors.white
                                                              : AppColors
                                                                  .textColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      width /
                                                                          2),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${width.toInt()}px',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: controller
                                                                      .selectedStrokeWidth
                                                                      .value ==
                                                                  width
                                                              ? Colors.white
                                                              : AppColors
                                                                  .textColor,
                                                          fontFamily:
                                                              'Comic Sans MS',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : null,
                    ),
                  )),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStar(Color color, double size) {
    return Icon(
      Icons.star,
      color: color,
      size: size,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(1, 1),
          blurRadius: 4,
        ),
      ],
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPath> completedPaths;
  final List<Offset> currentPath;
  final Color currentColor;
  final double currentStrokeWidth;
  final bool isDrawing;
  final List<Map<String, dynamic>> dots;
  final int currentDot;
  final int nextDot;
  final bool showDots;
  final double dotSize;

  DrawingPainter({
    required this.completedPaths,
    required this.currentPath,
    required this.currentColor,
    required this.currentStrokeWidth,
    required this.isDrawing,
    required this.dots,
    required this.currentDot,
    required this.nextDot,
    required this.showDots,
    required this.dotSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed paths
    for (final path in completedPaths) {
      if (path.points.isNotEmpty) {
        final paint = Paint()
          ..color = path.color
          ..strokeWidth = path.strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

        final pathObj = Path()
          ..moveTo(path.points.first.dx, path.points.first.dy);
        for (int i = 1; i < path.points.length; i++) {
          pathObj.lineTo(path.points[i].dx, path.points[i].dy);
        }
        canvas.drawPath(pathObj, paint);
      }
    }

    // Draw current path
    if (currentPath.isNotEmpty) {
      final paint = Paint()
        ..color = currentColor.withOpacity(0.8)
        ..strokeWidth = currentStrokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(currentPath.first.dx, currentPath.first.dy);
      for (int i = 1; i < currentPath.length; i++) {
        path.lineTo(currentPath[i].dx, currentPath[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // Draw dots only if enabled
    if (showDots) {
      final dotPaint = Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      final currentDotPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;
      final nextDotPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      for (var dot in dots) {
        final x = dot['x'].toDouble();
        final y = dot['y'].toDouble();
        final number = dot['number'] as int;

        // Choose paint based on dot type
        final paint = number == currentDot
            ? currentDotPaint
            : number == nextDot
                ? nextDotPaint
                : dotPaint;

        // Draw dot circle
        canvas.drawCircle(Offset(x, y), dotSize, paint);

        // Draw dot number
        final textPainter = TextPainter(
          text: TextSpan(
            text: number.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: dotSize * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Center the text on the dot
        final textOffset = Offset(
          x - textPainter.width / 2,
          y - textPainter.height / 2,
        );
        textPainter.paint(canvas, textOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
