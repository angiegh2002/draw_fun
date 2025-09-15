import 'package:draw_fun/const/app_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/drawing_path.dart';

class DrawCanvasController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var imageUrl = ''.obs;
  var isCompleted = false.obs;
  var currentLevel = 'easy'.obs;
  var showNextLevelButton = false.obs;
  var dots = <Map<String, dynamic>>[].obs; // List of dots with coordinates
  var connectedDots = <int>{}.obs; // Track connected dot numbers

  // Drawing variables
  var drawingPaths = <DrawingPath>[].obs;
  var currentDrawingPoints = <Offset>[].obs;
  var isDrawing = false.obs;

  // Drawing customization
  var selectedColor = Colors.black.obs;
  var selectedStrokeWidth = 3.0.obs;
  var showDrawingTools = false.obs;

  // Available colors and stroke widths
  final List<MaterialColor> availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
  ];

  final List<double> availableStrokeWidths = [2.0, 3.0, 5.0, 8.0, 12.0];

  // Level parameters
  final int categoryId;
  final int drawingId;

  // Available levels
  final List<String> levels = ['easy', 'medium', 'hard'];

  DrawCanvasController({required this.categoryId, required this.drawingId});

  @override
  void onInit() {
    super.onInit();
    loadDrawingLevel();
  }

  Future<void> loadDrawingLevel({String? level}) async {
    try {
      isLoading.value = true;
      final levelToLoad = level ?? currentLevel.value;
      final url = Uri.parse(
          '${AppConstants.baseUrl}/api/categories/$categoryId/drawings/$drawingId/?mode=draw&level=$levelToLoad');
      print('Requesting URL: $url');

      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      print('Response status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final levelModel = DrawLevelModel.fromJson(data);
        // Avoid double slashes in the URL
        imageUrl.value =
            '${AppConstants.baseUrl}/${levelModel.imageUrl.startsWith('/') ? levelModel.imageUrl.substring(1) : levelModel.imageUrl}';
        isCompleted.value = levelModel.isCompleted;
        // Populate dots with currentDot and nextDot
        dots.assignAll([
          levelModel.currentDot.toJson(),
          if (levelModel.nextDot != null) levelModel.nextDot!.toJson(),
        ]);
        print('Loaded level: $levelToLoad');
        print('Image URL set to: ${imageUrl.value}, Dots: ${dots.length}');
        print('Is completed: ${isCompleted.value}');
        if (isCompleted.value) showNextLevelButton.value = true;
      } else {
        Get.snackbar(
            'Error', 'Failed to load drawing level: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load drawing: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      imageUrl.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  void startDrawing(Offset point) {
    isDrawing.value = true;
    currentDrawingPoints.clear();
    currentDrawingPoints.add(point);
  }

  void updateDrawing(Offset point) {
    if (isDrawing.value) currentDrawingPoints.add(point);
  }

  void endDrawing() {
    if (isDrawing.value && currentDrawingPoints.isNotEmpty) {
      drawingPaths.add(DrawingPath(
        points: List<Offset>.from(currentDrawingPoints),
        color: selectedColor.value,
        strokeWidth: selectedStrokeWidth.value,
      ));
      currentDrawingPoints.clear();
      isDrawing.value = false;
      checkIfDotsConnected();
    }
  }

  void checkIfDotsConnected() {
    if (drawingPaths.isNotEmpty) {
      final lastPath = drawingPaths.last;
      for (var dot in dots) {
        final x = dot['x'].toDouble();
        final y = dot['y'].toDouble();
        final number = dot['number'] as int? ?? 0;
        if (lastPath.points.any((point) =>
            (point.dx - x).abs() < 20 && (point.dy - y).abs() < 20)) {
          connectedDots.add(number);
        }
      }
      if (connectedDots.length >= dots.length) {
        completeLevel();
      }
    }
  }

  void retryLevel() {
    drawingPaths.clear();
    currentDrawingPoints.clear();
    connectedDots.clear();
    isCompleted.value = false;
    showNextLevelButton.value = false;
    loadDrawingLevel();
  }

  void nextLevel() {
    final currentIndex = levels.indexOf(currentLevel.value);
    if (currentIndex < levels.length - 1) {
      currentLevel.value = levels[currentIndex + 1];
      retryLevel();
    } else {
      Get.snackbar('Congratulations!', 'All levels completed!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      Get.back();
    }
  }

  void completeLevel() {
    isCompleted.value = true;
    showNextLevelButton.value = true;
    Get.snackbar('Congratulations!', 'Level completed!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
  }

  void toggleDrawingTools() {
    showDrawingTools.value = !showDrawingTools.value;
  }

  void selectColor(MaterialColor color) {
    selectedColor.value = color;
  }

  void selectStrokeWidth(double width) {
    selectedStrokeWidth.value = width;
  }

  // Get current level display name
  String get currentLevelName {
    return currentLevel.value.capitalize ?? currentLevel.value;
  }

  // Check if there's a next level available
  bool get hasNextLevel {
    final currentIndex = levels.indexOf(currentLevel.value);
    return currentIndex < levels.length - 1;
  }
}

class DrawLevelModel {
  final String imageUrl;
  final int totalDots;
  final int currentIndex;
  final String mode;
  final Dot currentDot;
  final Dot? nextDot;
  final bool isCompleted;

  DrawLevelModel({
    required this.imageUrl,
    required this.totalDots,
    required this.currentIndex,
    required this.mode,
    required this.currentDot,
    this.nextDot,
    required this.isCompleted,
  });

  factory DrawLevelModel.fromJson(Map<String, dynamic> json) {
    return DrawLevelModel(
      imageUrl: json['image_url'] ?? '',
      totalDots: json['total_dots'] ?? 0,
      currentIndex: json['current_index'] ?? 0,
      mode: json['mode'] ?? 'draw',
      currentDot: Dot.fromJson(json['current_dot'] ?? {}),
      nextDot: json['next_dot'] != null ? Dot.fromJson(json['next_dot']) : null,
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

class Dot {
  final double x;
  final double y;
  final int number;

  Dot({
    required this.x,
    required this.y,
    this.number = 0,
  });

  factory Dot.fromJson(Map<String, dynamic> json) {
    return Dot(
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      number: json['number'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        if (number != 0) 'number': number,
      };
}
