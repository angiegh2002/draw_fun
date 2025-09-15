// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../const/app_colors.dart';
// import '../../../const/app_const.dart';
// import '../controller/drawings_controller.dart';
//
// class DrawingsScreen extends StatelessWidget {
//   final int categoryId;
//   final String mode; // New param
//
//   const DrawingsScreen(
//       {super.key, required this.categoryId, required this.mode});
//
//   @override
//   Widget build(BuildContext context) {
//     Get.deleteAll();
//     final controller = Get.put(
//       DrawingsController(categoryId: categoryId, mode: mode),
//       tag: 'drawings_$categoryId',
//     );
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Drawings',
//             style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textColor)),
//         backgroundColor: AppColors.primaryColor,
//         elevation: 4,
//       ),
//       body: Obx(
//         () => Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Expanded(
//                 child: controller.drawings.isEmpty
//                     ? const Center(
//                         child: CircularProgressIndicator(
//                             color: AppColors.primaryColor))
//                     : GridView.builder(
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 16,
//                           mainAxisSpacing: 16,
//                           childAspectRatio: 0.85,
//                         ),
//                         itemCount: controller.drawings.length,
//                         itemBuilder: (context, index) {
//                           final drawing = controller.drawings[index];
//                           return Card(
//                             clipBehavior: Clip.antiAlias,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16)),
//                             elevation: 4,
//                             child: InkWell(
//                               onTap: () => controller.navigateToDrawing(
//                                   context, drawing.id),
//                               child: Stack(
//                                 fit: StackFit.expand,
//                                 children: [
//                                   drawing.imageUrl.isNotEmpty
//                                       ? Image.network(
//                                           '${AppConstants.baseUrl}${drawing.imageUrl}',
//                                           fit: BoxFit.fill,
//                                           errorBuilder:
//                                               (context, error, stackTrace) =>
//                                                   Container(
//                                             color: AppColors.backgroundColor,
//                                             child: const Icon(Icons.error,
//                                                 size: 48,
//                                                 color: AppColors.textColor),
//                                           ),
//                                         )
//                                       : Container(
//                                           color: AppColors.backgroundColor,
//                                           child: const Icon(Icons.image,
//                                               size: 48,
//                                               color: AppColors.textColor),
//                                         ),
//                                   Positioned(
//                                     bottom: 0,
//                                     left: 0,
//                                     right: 0,
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 8, horizontal: 12),
//                                       color: AppColors.primaryColor
//                                           .withOpacity(0.7),
//                                       child: Text(
//                                         drawing.title,
//                                         style: const TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: AppColors.textColor,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         Get.delete<DrawingsController>(
//                             tag: 'drawings_$categoryId');
//                         Navigator.pop(context);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.accentColor,
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 12, horizontal: 24),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                         elevation: 4,
//                       ),
//                       child: const Text('Back',
//                           style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.textColor)),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../const/app_colors.dart';
import '../../../const/app_const.dart';
import '../../../widgets/custom_app_bar.dart';
import '../controller/drawings_controller.dart';

class DrawingsScreen extends StatelessWidget {
  final int categoryId;
  final String mode;

  const DrawingsScreen(
      {super.key, required this.categoryId, required this.mode});

  @override
  Widget build(BuildContext context) {
    Get.deleteAll();
    final controller = Get.put(
      DrawingsController(categoryId: categoryId, mode: mode),
      tag: 'drawings_$categoryId',
    );
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Choose a Drawing!',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.delete<DrawingsController>(tag: 'drawings_$categoryId');
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0FFFF), // Light cyan
              Color(0xFFFFF8DC), // Cornsilk
            ],
          ),
        ),
        child: Obx(
          () => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: controller.drawings.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: controller.drawings.length,
                          itemBuilder: (context, index) {
                            final drawing = controller.drawings[index];
                            return GestureDetector(
                              onTap: () => controller.navigateToDrawing(
                                  context, drawing.id),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.accentColor,
                                              AppColors.primaryColor,
                                            ],
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                          child: drawing.imageUrl.isNotEmpty
                                              ? Image.network(
                                                  '${AppConstants.baseUrl}${drawing.imageUrl}',
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                        color: AppColors
                                                            .primaryColor,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          AppColors
                                                              .backgroundColor,
                                                          AppColors.accentColor,
                                                        ],
                                                      ),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.image,
                                                        color:
                                                            AppColors.textColor,
                                                        size: 50,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        AppColors
                                                            .backgroundColor,
                                                        AppColors.accentColor,
                                                      ],
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.image,
                                                      color:
                                                          AppColors.textColor,
                                                      size: 50,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            drawing.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textColor,
                                              fontFamily: 'Comic Sans MS',
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  AppColors.primaryColor,
                                                  AppColors.accentColor,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'Tap to draw',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Comic Sans MS',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Bottom stars decoration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStar(Colors.yellow, 20),
                    _buildStar(Colors.blue, 18),
                    _buildStar(Colors.red, 20),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.accentColor,
                              AppColors.primaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.delete<DrawingsController>(
                                tag: 'drawings_$categoryId');
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back,
                                  color: Colors.white, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Back',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Comic Sans MS',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
