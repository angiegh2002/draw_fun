// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../const/app_colors.dart';
// import '../../../const/app_const.dart';
// import '../controller/home_controller.dart';
//
// class HomeScreen extends StatelessWidget {
//   final String userId;
//
//   HomeScreen({required this.userId});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(HomeController(userId));
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text('Kids Drawing Game',
//             style: TextStyle(color: AppColors.textColor)),
//         backgroundColor: AppColors.primaryColor,
//       ),
//       body: GetBuilder<HomeController>(
//         builder: (controller) => Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: AppColors.backgroundColor.withOpacity(0.5),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () {}, // Placeholder for profile edit
//                       child: CircleAvatar(
//                         backgroundColor: AppColors.accentColor,
//                         radius: 30,
//                         child: Text(
//                           controller.username.isNotEmpty
//                               ? controller.username[0].toUpperCase()
//                               : '?',
//                           style: const TextStyle(
//                               fontSize: 24, color: AppColors.textColor),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             controller.username.isNotEmpty
//                                 ? controller.username
//                                 : 'Friend',
//                             style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.textColor),
//                           ),
//                           Text(
//                             'Age ${controller.age > 0 ? controller.age : '?'}',
//                             style: const TextStyle(
//                                 fontSize: 18, color: AppColors.textColor),
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       icon:
//                           const Icon(Icons.logout, color: AppColors.textColor),
//                       onPressed: () => controller.logout(context),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: controller.categories.isEmpty
//                     ? const Center(
//                         child: CircularProgressIndicator(
//                             color: AppColors.primaryColor))
//                     : GridView.count(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 16,
//                         mainAxisSpacing: 16,
//                         children: controller.categories.map((category) {
//                           return Card(
//                             clipBehavior: Clip.antiAlias,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16)),
//                             elevation: 4,
//                             child: InkWell(
//                               onTap: () => controller.navigateToCategory(
//                                   context, category.id, 'learn'), // Pass mode
//                               child: Stack(
//                                 fit: StackFit.expand,
//                                 children: [
//                                   category.image.isNotEmpty
//                                       ? Image.network(
//                                           '${AppConstants.baseUrl}${category.image}',
//                                           fit: BoxFit.fill,
//                                           errorBuilder:
//                                               (context, error, stackTrace) =>
//                                                   Container(
//                                             color: AppColors.backgroundColor,
//                                             child: const Icon(Icons.error,
//                                                 size: 50,
//                                                 color: AppColors.textColor),
//                                           ),
//                                         )
//                                       : Container(
//                                           color: AppColors.backgroundColor,
//                                           child: const Icon(Icons.image,
//                                               size: 100,
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
//                                         category.name,
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
//                         }).toList(),
//                       ),
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
import '../controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  HomeScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController(userId));

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Kids Drawing Game',
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
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {}, // Placeholder for profile edit
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentColor,
                                AppColors.primaryColor
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 30,
                            child: Text(
                              controller.username.isNotEmpty
                                  ? controller.username[0].toUpperCase()
                                  : '😊',
                              style: const TextStyle(
                                fontSize: 24,
                                color: AppColors.textColor,
                                fontFamily: 'Comic Sans MS',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.username.isNotEmpty
                                  ? controller.username
                                  : 'Friend',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                                fontFamily: 'Comic Sans MS',
                              ),
                            ),
                            Text(
                              'Age ${controller.age > 0 ? controller.age : '?'}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.textColor,
                                fontFamily: 'Comic Sans MS',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout,
                            color: AppColors.textColor, size: 28),
                        onPressed: () => controller.logout(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
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
                                    context, category.id, 'learn'),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    category.image.isNotEmpty
                                        ? Image.network(
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
                                        : Container(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
