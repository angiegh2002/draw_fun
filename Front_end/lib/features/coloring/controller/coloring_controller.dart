import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui' as ui;
import '../../../const/app_const.dart';

class ColoringController extends GetxController {
  final int drawingId;
  final RxBool isLoading = true.obs;
  final RxString imageUrl = ''.obs;
  final RxString title = ''.obs;
  final RxMap<String, dynamic> boundingBox = <String, dynamic>{}.obs;

  ui.Image? loadedImage;
  final RxList<Paint> paintHistory = <Paint>[].obs;
  final RxList<Offset> pointHistory = <Offset>[].obs;
  final RxList<List<Offset>> strokeHistory = <List<Offset>>[].obs;
  final RxList<Color> colorHistory = <Color>[].obs;
  final RxList<double> brushSizeHistory = <double>[].obs;
  final Rx<Color> selectedColor = Colors.red.obs;
  final RxDouble brushSize = 5.0.obs;
  final RxList<Offset> currentStroke = <Offset>[].obs;

  ColoringController({required this.drawingId});

  @override
  void onInit() {
    super.onInit();
    fetchColoringData();
  }

  Future<void> fetchColoringData() async {
    try {
      isLoading.value = true;
      final url = Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.apiPrefix}${AppConstants.coloring}$drawingId/');
      print('Requesting coloring URL: $url');

      final response = await http.get(url);
      print(
          'Coloring status code: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        imageUrl.value = data['image_url'] ?? '';
        title.value = data['title'] ?? '';
        boundingBox.value = data['bounding_box'] ?? {};

        if (imageUrl.value.isNotEmpty) {
          await _loadImage();
        }
      } else {
        Get.snackbar('Error', 'Failed to load coloring data: ${response.body}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Coloring request error: $e');
      Get.snackbar('Error', 'Network issue: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadImage() async {
    try {
      final String fullImageUrl = '${AppConstants.baseUrl}${imageUrl.value}';
      print('Loading image from: $fullImageUrl');

      final response = await http.get(Uri.parse(fullImageUrl));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        loadedImage = frame.image;
        print(
            'Image loaded successfully: ${loadedImage!.width}x${loadedImage!.height}');
        update();
      } else {
        print('Failed to load image: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to load coloring image',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error loading image: $e');
      Get.snackbar('Error', 'Error loading image: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void changeColor(Color color) {
    selectedColor.value = color;
  }

  void changeBrushSize(double size) {
    brushSize.value = size;
  }

  void addPoint(Offset point) {
    currentStroke.add(point);
  }

  void startNewStroke() {
    if (currentStroke.isNotEmpty) {
      strokeHistory.add(List.from(currentStroke));
      colorHistory.add(selectedColor.value);
      brushSizeHistory.add(brushSize.value);
      currentStroke.clear();
    }
  }

  void clearCanvas() {
    strokeHistory.clear();
    colorHistory.clear();
    brushSizeHistory.clear();
    currentStroke.clear();

    Get.snackbar(
      'Canvas Cleared',
      'All coloring has been cleared',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void undo() {
    if (strokeHistory.isNotEmpty) {
      strokeHistory.removeLast();
      colorHistory.removeLast();
      brushSizeHistory.removeLast();

      Get.snackbar(
        'Undo',
        'Last stroke removed',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  void saveColoring() {
    // Dummy Saving
    Get.snackbar(
      'Save',
      'Coloring saved successfully!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  bool get hasStrokes => strokeHistory.isNotEmpty || currentStroke.isNotEmpty;

  @override
  void onClose() {
    loadedImage?.dispose();
    super.onClose();
  }
}
