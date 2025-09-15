// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:numberpicker/numberpicker.dart';
// import '../../../const/app_colors.dart';
// import '../controller/profile_setup_controller.dart';
//
// class ProfileSetupScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(ProfileSetupController());
//     final usernameController = TextEditingController();
//
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: GetBuilder<ProfileSetupController>(
//             builder: (controller) => Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text('Welcome!',
//                     style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textColor)),
//                 const SizedBox(height: 10),
//                 CircleAvatar(
//                   radius: 60,
//                   backgroundColor: AppColors.accentColor,
//                   child: Text(
//                     usernameController.text.isNotEmpty
//                         ? usernameController.text[0].toUpperCase()
//                         : '?',
//                     style: const TextStyle(
//                         fontSize: 48, color: AppColors.primaryColor),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 TextField(
//                   controller: usernameController,
//                   decoration: InputDecoration(
//                     labelText: 'Your Name',
//                     labelStyle: const TextStyle(
//                         fontSize: 20, color: AppColors.primaryColor),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)),
//                     filled: true,
//                     fillColor: AppColors.backgroundColor.withOpacity(0.5),
//                   ),
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                       fontSize: 24, color: AppColors.primaryColor),
//                   keyboardType: TextInputType.name,
//                   onChanged: controller.setUsername,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   controller.message,
//                   style: const TextStyle(fontSize: 20, color: Colors.red),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text('Your Age',
//                     style:
//                         TextStyle(fontSize: 20, color: AppColors.primaryColor)),
//                 NumberPicker(
//                   value: controller.age,
//                   minValue: 3,
//                   maxValue: 12,
//                   onChanged: controller.setAge,
//                   textStyle: const TextStyle(
//                       fontSize: 20, color: AppColors.primaryColor),
//                   selectedTextStyle: const TextStyle(
//                       fontSize: 28, color: AppColors.accentColor),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: AppColors.primaryColor),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 ElevatedButton(
//                   onPressed: () => controller.navigateToMain(context),
//                   child: const Text('Let’s Draw!',
//                       style: TextStyle(
//                           fontSize: 24, color: AppColors.primaryColor)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.accentColor,
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 20, horizontal: 48),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16)),
//                     elevation: 5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../../const/app_colors.dart';
import '../controller/profile_setup_controller.dart';

class ProfileSetupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileSetupController());
    final usernameController = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF87CEEB), // Sky blue
              Color(0xFFFFB6C1), // Light pink
              Color(0xFF98FB98), // Pale green
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: GetBuilder<ProfileSetupController>(
                  builder: (controller) => ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated stars decoration
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStar(Colors.yellow, 22),
                                _buildStar(Colors.orange, 18),
                                _buildStar(Colors.pink, 20),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Welcome text with playful styling
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Welcome!',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                  fontFamily: 'Comic Sans MS',
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Avatar with colorful border
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.red,
                                    Colors.yellow,
                                    Colors.blue,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(4),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.accentColor,
                                child: Text(
                                  usernameController.text.isNotEmpty
                                      ? usernameController.text[0].toUpperCase()
                                      : '😊',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: AppColors.textColor,
                                    fontFamily: 'Comic Sans MS',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Name input with kid-friendly styling
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Your Name ✨',
                                  labelStyle: const TextStyle(
                                    fontSize: 18,
                                    color: AppColors.textColor,
                                    fontFamily: 'Comic Sans MS',
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                        color: AppColors.primaryColor,
                                        width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                        color: AppColors.primaryColor,
                                        width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                        color: AppColors.accentColor, width: 3),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.9),
                                  prefixIcon: const Icon(
                                    Icons.star,
                                    color: AppColors.textColor,
                                    size: 24,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: AppColors.textColor,
                                  fontFamily: 'Comic Sans MS',
                                ),
                                keyboardType: TextInputType.name,
                                onChanged: controller.setUsername,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Error message with friendly styling
                            Text(
                              controller.message,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.redAccent,
                                fontFamily: 'Comic Sans MS',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Age picker with colorful styling
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.cake,
                                          color: AppColors.textColor, size: 24),
                                      SizedBox(width: 8),
                                      Text(
                                        'Your Age',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: AppColors.textColor,
                                          fontFamily: 'Comic Sans MS',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.accentColor,
                                          AppColors.primaryColor
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: NumberPicker(
                                      value: controller.age,
                                      minValue: 3,
                                      maxValue: 12,
                                      onChanged: controller.setAge,
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        color: AppColors.textColor,
                                        fontFamily: 'Comic Sans MS',
                                      ),
                                      selectedTextStyle: const TextStyle(
                                        fontSize: 28,
                                        color: Colors.white,
                                        fontFamily: 'Comic Sans MS',
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.primaryColor),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Button with playful styling
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.accentColor,
                                    AppColors.primaryColor
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () =>
                                    controller.navigateToMain(context),
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
                                    Icon(Icons.brush,
                                        color: Colors.white, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      'Let’s Draw!',
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.white,
                                        fontFamily: 'Comic Sans MS',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Bottom stars
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStar(Colors.blue, 18),
                                _buildStar(Colors.green, 20),
                                _buildStar(Colors.red, 18),
                              ],
                            ),
                          ],
                        ),
                      ))),
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
