// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../const/app_colors.dart';
// import '../../../const/app_const.dart';
// import '../../home/controller/home_controller.dart';
//
// class HandDrawingScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final controller =
//         Get.put(HomeController('sessionId')); // Use existing controller
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text('Hand Drawing',
//             style: TextStyle(color: AppColors.textColor)),
//         backgroundColor: AppColors.primaryColor,
//       ),
//       body: GetBuilder<HomeController>(
//         builder: (controller) => Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Expanded(
//                 child: Center(
//                   child: controller.categories.isEmpty
//                       ? const Center(
//                           child: CircularProgressIndicator(
//                               color: AppColors.primaryColor))
//                       : GridView.count(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 16,
//                           mainAxisSpacing: 16,
//                           children: controller.categories.map((category) {
//                             return Card(
//                               clipBehavior: Clip.antiAlias,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16)),
//                               elevation: 4,
//                               child: InkWell(
//                                 onTap: () => controller.navigateToCategory(
//                                     context, category.id, 'draw'),
//                                 child: Stack(
//                                   fit: StackFit.expand,
//                                   children: [
//                                     if (category.image.isNotEmpty)
//                                       Image.network(
//                                         '${AppConstants.baseUrl}${category.image}',
//                                         fit: BoxFit.fill,
//                                         errorBuilder:
//                                             (context, error, stackTrace) =>
//                                                 Container(
//                                           color: AppColors.backgroundColor,
//                                           child: const Icon(Icons.error,
//                                               size: 50,
//                                               color: AppColors.textColor),
//                                         ),
//                                       )
//                                     else
//                                       Container(
//                                         color: AppColors.backgroundColor,
//                                         child: const Icon(Icons.image,
//                                             size: 100,
//                                             color: AppColors.textColor),
//                                       ),
//                                     Positioned(
//                                       bottom: 0,
//                                       left: 0,
//                                       right: 0,
//                                       child: Container(
//                                         padding: const EdgeInsets.symmetric(
//                                             vertical: 8, horizontal: 12),
//                                         color: AppColors.primaryColor
//                                             .withOpacity(0.7),
//                                         child: Text(
//                                           category.name,
//                                           style: const TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.bold,
//                                             color: AppColors.textColor,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         ),
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
import '../../home/controller/home_controller.dart';

class HandDrawingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(HomeController('sessionId')); // Use existing controller

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Pick a Drawing to Create!',
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
        child: GetBuilder<HomeController>(
          builder: (controller) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: controller.categories.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          )
                        : GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: controller.categories.map((category) {
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 6,
                                shadowColor: Colors.black.withOpacity(0.2),
                                child: InkWell(
                                  onTap: () => controller.navigateToCategory(
                                      context, category.id, 'draw'),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (category.image.isNotEmpty)
                                        Image.network(
                                          '${AppConstants.baseUrl}${category.image}',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.backgroundColor,
                                                  AppColors.accentColor,
                                                ],
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.image,
                                              size: 60,
                                              color: AppColors.textColor,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.backgroundColor,
                                                AppColors.accentColor,
                                              ],
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.image,
                                            size: 60,
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.primaryColor,
                                                AppColors.accentColor,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(20),
                                            ),
                                          ),
                                          child: Text(
                                            category.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontFamily: 'Comic Sans MS',
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
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
