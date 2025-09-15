// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../models/drawing_path.dart';
// import '../controller/draw_canvas_controller.dart';
//
// class DrawCanvasScreen extends StatelessWidget {
//   final int categoryId;
//   final int drawingId;
//
//   const DrawCanvasScreen({
//     super.key,
//     required this.categoryId,
//     required this.drawingId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Initialize controller with parameters
//     final controller = Get.put(
//       DrawCanvasController(
//         categoryId: categoryId,
//         drawingId: drawingId,
//       ),
//       tag: 'drawing_${categoryId}_$drawingId',
//     );
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Obx(() => Text('Drawing - ${controller.currentLevelName}')),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         elevation: 2,
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//
//         return Column(
//           children: [
//             // Level info and controls
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
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                       'Level: ${controller.currentLevel.value.capitalize ?? controller.currentLevel.value}',
//                       style: const TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold)),
//                   Row(
//                     children: [
//                       ElevatedButton.icon(
//                         onPressed: controller.toggleDrawingTools,
//                         icon: const Icon(Icons.palette),
//                         label: const Text('Tools'),
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                             foregroundColor: Colors.white),
//                       ),
//                       const SizedBox(width: 8),
//                       ElevatedButton.icon(
//                         onPressed: controller.retryLevel,
//                         icon: const Icon(Icons.refresh),
//                         label: const Text('Retry'),
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orange,
//                             foregroundColor: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // Drawing canvas
//             Expanded(
//               child: Center(
//                 child: AspectRatio(
//                   aspectRatio: 1,
//                   child: Container(
//                     width: 400,
//                     height: 400,
//                     color: Colors.white,
//                     child: Stack(
//                       children: [
//                         // Background image with dots
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
//                                       Icon(
//                                         Icons.error,
//                                         size: 64,
//                                         color: Colors.red,
//                                       ),
//                                       SizedBox(height: 16),
//                                       Text(
//                                         'Failed to load image',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           color: Colors.red,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//
//                         // Drawing overlay
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
//                               ),
//                               size: Size.infinite,
//                             ),
//                           ),
//                         ),
//
//                         // Drawing tools overlay
//                         if (controller.showDrawingTools.value)
//                           Positioned(
//                             top: 0,
//                             left: 0,
//                             right: 0,
//                             child: Container(
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[100],
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.2),
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 children: [
//                                   // Color selection
//                                   Row(
//                                     children: [
//                                       const Text(
//                                         'Colors: ',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold),
//                                       ),
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
//
//                                   const SizedBox(height: 12),
//
//                                   // Stroke width selection
//                                   Row(
//                                     children: [
//                                       const Text(
//                                         'Size: ',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold),
//                                       ),
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
//                                                       Text(
//                                                         '${width.toInt()}px',
//                                                         style: TextStyle(
//                                                           fontSize: 12,
//                                                           color: controller
//                                                                       .selectedStrokeWidth
//                                                                       .value ==
//                                                                   width
//                                                               ? Colors.white
//                                                               : Colors.black,
//                                                         ),
//                                                       ),
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
//                                 ],
//                               ),
//                             ),
//                           ),
//
//                         // Completion overlay
//                         if (controller.isCompleted.value)
//                           Positioned.fill(
//                             child: Container(
//                               color: Colors.black.withOpacity(0.3),
//                               child: Center(
//                                 child: Card(
//                                   margin: const EdgeInsets.all(32),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(24),
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         const Icon(
//                                           Icons.check_circle,
//                                           size: 64,
//                                           color: Colors.green,
//                                         ),
//                                         const SizedBox(height: 16),
//                                         const Text(
//                                           'Level Completed!',
//                                           style: TextStyle(
//                                             fontSize: 24,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Text(
//                                           'Great job completing ${controller.currentLevelName} level!',
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(fontSize: 16),
//                                         ),
//                                         const SizedBox(height: 24),
//                                         Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             ElevatedButton(
//                                               onPressed: controller.retryLevel,
//                                               child: const Text('Retry'),
//                                             ),
//                                             const SizedBox(width: 16),
//                                             if (controller.hasNextLevel)
//                                               ElevatedButton(
//                                                 onPressed: controller.nextLevel,
//                                                 style: ElevatedButton.styleFrom(
//                                                   backgroundColor: Colors.green,
//                                                   foregroundColor: Colors.white,
//                                                 ),
//                                                 child: const Text('Next Level'),
//                                               )
//                                             else
//                                               ElevatedButton(
//                                                 onPressed: () => Get.back(),
//                                                 style: ElevatedButton.styleFrom(
//                                                   backgroundColor: Colors.blue,
//                                                   foregroundColor: Colors.white,
//                                                 ),
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
//             // Bottom controls
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 4,
//                     offset: const Offset(0, -2),
//                   ),
//                 ],
//               ),
//               child: SizedBox(
//                 height: 56,
//                 child: Row(
//                   children: [
//                     if (!controller.isCompleted.value &&
//                         controller.drawingPaths.isNotEmpty)
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: controller.completeLevel,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: const Text(
//                             'Complete Level',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                     if (controller.showNextLevelButton.value &&
//                         !controller.isCompleted.value &&
//                         controller.hasNextLevel)
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: controller.nextLevel,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: const Text(
//                             'Next Level',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                     if (controller.isCompleted.value ||
//                         controller.drawingPaths.isEmpty)
//                       Expanded(child: Container()),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }
//
// // Custom painter for drawing lines
// class DrawingPainter extends CustomPainter {
//   final List<DrawingPath> completedPaths;
//   final List<Offset> currentPath;
//   final Color currentColor;
//   final double currentStrokeWidth;
//   final bool isDrawing;
//
//   DrawingPainter({
//     required this.completedPaths,
//     required this.currentPath,
//     required this.currentColor,
//     required this.currentStrokeWidth,
//     required this.isDrawing,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // Draw all completed paths with their individual properties
//     for (final drawingPath in completedPaths) {
//       if (drawingPath.points.isNotEmpty) {
//         final paint = Paint()
//           ..color = drawingPath.color
//           ..strokeWidth = drawingPath.strokeWidth
//           ..strokeCap = StrokeCap.round
//           ..style = PaintingStyle.stroke;
//
//         final path = Path();
//         path.moveTo(drawingPath.points.first.dx, drawingPath.points.first.dy);
//
//         for (int i = 1; i < drawingPath.points.length; i++) {
//           path.lineTo(drawingPath.points[i].dx, drawingPath.points[i].dy);
//         }
//
//         canvas.drawPath(path, paint);
//       }
//     }
//
//     // Draw current path being drawn with current selected properties
//     if (currentPath.isNotEmpty) {
//       final currentPaint = Paint()
//         ..color = currentColor.withOpacity(0.8)
//         ..strokeWidth = currentStrokeWidth
//         ..strokeCap = StrokeCap.round
//         ..style = PaintingStyle.stroke;
//
//       final path = Path();
//       path.moveTo(currentPath.first.dx, currentPath.first.dy);
//
//       for (int i = 1; i < currentPath.length; i++) {
//         path.lineTo(currentPath[i].dx, currentPath[i].dy);
//       }
//
//       canvas.drawPath(path, currentPaint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/drawing_path.dart';
import '../controller/draw_canvas_controller.dart';
import '../../../const/app_colors.dart';

class DrawCanvasScreen extends StatelessWidget {
  final int categoryId;
  final int drawingId;

  const DrawCanvasScreen({
    super.key,
    required this.categoryId,
    required this.drawingId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      DrawCanvasController(
        categoryId: categoryId,
        drawingId: drawingId,
      ),
      tag: 'drawing_${categoryId}_$drawingId',
    );

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Drawing - ${controller.currentLevelName}')),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        color: const Color(0xFFE0FFFF),
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
                        // Background image with dots
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
                                      Icon(Icons.error,
                                          size: 64, color: AppColors.textColor),
                                      SizedBox(height: 16),
                                      Text(
                                        'Failed to load image ðŸ˜Š',
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
                        // Drawing overlay
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
                              ),
                              size: const Size(400, 400),
                            ),
                          ),
                        ),
                        // Completion overlay
                        if (controller.isCompleted.value)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.7),
                              child: Center(
                                child: Card(
                                  margin: const EdgeInsets.all(32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          size: 64,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Level Completed!',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Comic Sans MS',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Great job completing ${controller.currentLevelName} level!',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Comic Sans MS',
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    AppColors.accentColor,
                                                    AppColors.primaryColor,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.15),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: ElevatedButton(
                                                onPressed:
                                                    controller.retryLevel,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12,
                                                      horizontal: 16),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Retry',
                                                  style: TextStyle(
                                                    fontFamily: 'Comic Sans MS',
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            if (controller.hasNextLevel)
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      AppColors.accentColor,
                                                      AppColors.primaryColor,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
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
                                                child: ElevatedButton(
                                                  onPressed:
                                                      controller.nextLevel,
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Next Level',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Comic Sans MS',
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            else
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      AppColors.accentColor,
                                                      AppColors.primaryColor,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
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
                                                child: ElevatedButton(
                                                  onPressed: () => Get.back(),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Finish',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Comic Sans MS',
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Top level info and controls
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
                    Text(
                      'Level: ${controller.currentLevel.value.capitalize ?? controller.currentLevel.value}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Comic Sans MS',
                      ),
                    ),
                    Row(
                      children: [
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
                                Text('Tools',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Comic Sans MS',
                                      fontSize: 16,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: controller.retryLevel,
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
                                Icon(Icons.refresh,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 4),
                                Text('Retry',
                                    style: TextStyle(
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
                  ],
                ),
              ),
              // Bottom controls
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
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        if (!controller.isCompleted.value &&
                            controller.drawingPaths.isNotEmpty)
                          Expanded(
                            child: Container(
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
                              child: ElevatedButton(
                                onPressed: controller.completeLevel,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Complete Level',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Comic Sans MS',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (controller.showNextLevelButton.value &&
                            !controller.isCompleted.value &&
                            controller.hasNextLevel)
                          Expanded(
                            child: Container(
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
                              child: ElevatedButton(
                                onPressed: controller.nextLevel,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Next Level',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Comic Sans MS',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (controller.isCompleted.value ||
                            controller.drawingPaths.isEmpty)
                          Expanded(child: Container()),
                      ],
                    ),
                  ),
                ),
              ),
              // Tools panel (overlay on top of bottom controls)
              Obx(() => Positioned(
                    left: 0,
                    right: 0,
                    bottom: 76,
                    // Height of bottom controls (56) + padding (16) + margin
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
                                  // Color selection
                                  Row(
                                    children: [
                                      const Text(
                                        'Colors: ',
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
                                        'Size: ',
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
}

// Custom painter for drawing lines
class DrawingPainter extends CustomPainter {
  final List<DrawingPath> completedPaths;
  final List<Offset> currentPath;
  final Color currentColor;
  final double currentStrokeWidth;
  final bool isDrawing;

  DrawingPainter({
    required this.completedPaths,
    required this.currentPath,
    required this.currentColor,
    required this.currentStrokeWidth,
    required this.isDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all completed paths with their individual properties
    for (final drawingPath in completedPaths) {
      if (drawingPath.points.isNotEmpty) {
        final paint = Paint()
          ..color = drawingPath.color
          ..strokeWidth = drawingPath.strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        final path = Path();
        path.moveTo(drawingPath.points.first.dx, drawingPath.points.first.dy);

        for (int i = 1; i < drawingPath.points.length; i++) {
          path.lineTo(drawingPath.points[i].dx, drawingPath.points[i].dy);
        }

        canvas.drawPath(path, paint);
      }
    }

    // Draw current path being drawn with current selected properties
    if (currentPath.isNotEmpty) {
      final currentPaint = Paint()
        ..color = currentColor.withOpacity(0.8)
        ..strokeWidth = currentStrokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(currentPath.first.dx, currentPath.first.dy);

      for (int i = 1; i < currentPath.length; i++) {
        path.lineTo(currentPath[i].dx, currentPath[i].dy);
      }

      canvas.drawPath(path, currentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
