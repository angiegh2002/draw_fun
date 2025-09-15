import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import '../../../const/app_const.dart';
import '../../../models/drawing_model.dart';
import '../../drawing_canvas/view/draw_canvas_screen.dart';
import '../../drawing_canvas/view/learn_canvas_screen.dart';

class DrawingsController extends GetxController {
  final int categoryId;
  final String mode; // New param
  final RxList<DrawingModel> drawings = <DrawingModel>[].obs;
  final RxBool isLoading = true.obs;

  DrawingsController({required this.categoryId, required this.mode});

  @override
  void onInit() {
    super.onInit();
    fetchDrawings();
  }

  Future<void> fetchDrawings() async {
    try {
      isLoading.value = true;
      drawings.clear();
      print('fetch drawing in drawings: $mode');
      final url = Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.apiPrefix}${AppConstants.categories}$categoryId/${AppConstants.drawings}?mode=$mode');
      print('Requesting drawings URL: $url');
      final response = await http.get(url);
      print(
          'Drawings status code: ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        drawings.assignAll(
            jsonList.map((json) => DrawingModel.fromJson(json)).toList());
      } else {
        Get.snackbar('Error', 'Failed to load drawings: ${response.body}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Drawings request error: $e');
      Get.snackbar('Error', 'Network issue: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToDrawing(BuildContext context, int drawingId) {
    print('navigate to drawing: mode=$mode, drawingId=$drawingId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => mode == 'learn'
            ? LearnCanvasScreen(categoryId: categoryId, drawingId: drawingId)
            : DrawCanvasScreen(categoryId: categoryId, drawingId: drawingId),
      ),
    );
  }
}
