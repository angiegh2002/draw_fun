import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../const/app_colors.dart';
import '../../../widgets/custom_app_bar.dart';
import '../controller/coloring_controller.dart';
import '../widget/coloring_canvas_widget.dart';

class ColoringScreen extends StatelessWidget {
  final int drawingId;

  const ColoringScreen({required this.drawingId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ColoringController(drawingId: drawingId),
      tag: 'coloring_$drawingId',
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: controller.title.value.isNotEmpty
            ? 'Coloring - ${controller.title.value}'
            : 'Coloring',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.delete<ColoringController>(tag: 'coloring_$drawingId');
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white),
            onPressed: () => controller.undo(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.clearCanvas(),
            tooltip: 'Clear Canvas',
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () => controller.saveColoring(),
            tooltip: 'Save Coloring',
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFE0FFFF), // Light cyan for visibility
        child: Obx(
          () => controller.isLoading.value
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryColor))
              : controller.imageUrl.value.isEmpty
                  ? const Center(
                      child: Text(
                        'Failed to load coloring image 😊',
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.textColor,
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Canvas area
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.accentColor,
                                  AppColors.primaryColor,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ColoringCanvas(controller: controller),
                            ),
                          ),
                        ),
                        // Color palette
                        Container(
                          height: 80,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Colors: 🎨',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Comic Sans MS',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Colors.red,
                                    Colors.blue,
                                    Colors.green,
                                    Colors.yellow,
                                    Colors.orange,
                                    Colors.purple,
                                    Colors.pink,
                                    Colors.brown,
                                    Colors.black,
                                    Colors.grey,
                                    Colors.cyan,
                                    Colors.lime,
                                    Colors.indigo,
                                    Colors.teal,
                                    Colors.amber,
                                    Colors.deepOrange,
                                    Colors.lightBlue,
                                    Colors.lightGreen,
                                  ].map((color) {
                                    return Obx(() => GestureDetector(
                                          onTap: () =>
                                              controller.changeColor(color),
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 20),
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: controller.selectedColor
                                                            .value ==
                                                        color
                                                    ? AppColors.textColor
                                                    : Colors.white,
                                                width: controller.selectedColor
                                                            .value ==
                                                        color
                                                    ? 3
                                                    : 1,
                                              ),
                                              boxShadow: controller
                                                          .selectedColor
                                                          .value ==
                                                      color
                                                  ? [
                                                      BoxShadow(
                                                        color: color
                                                            .withOpacity(0.5),
                                                        spreadRadius: 2,
                                                        blurRadius: 4,
                                                      )
                                                    ]
                                                  : null,
                                            ),
                                          ),
                                        ));
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Brush size slider
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
                              bottom: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Brush Size: 🖌️',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Comic Sans MS',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Obx(() => Slider(
                                      value: controller.brushSize.value,
                                      min: 2.0,
                                      max: 25.0,
                                      divisions: 23,
                                      label: controller.brushSize.value
                                          .round()
                                          .toString(),
                                      activeColor: AppColors.accentColor,
                                      inactiveColor: AppColors.accentColor
                                          .withOpacity(0.3),
                                      onChanged: (value) =>
                                          controller.changeBrushSize(value),
                                    )),
                              ),
                              const SizedBox(width: 12),
                              Obx(() => Container(
                                    width: controller.brushSize.value
                                        .clamp(15, 30),
                                    height: controller.brushSize.value
                                        .clamp(15, 30),
                                    decoration: BoxDecoration(
                                      color: controller.selectedColor.value,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        // Bottom stars decoration
                        const SizedBox(height: 16),
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
