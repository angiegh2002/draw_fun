import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/drawing_path.dart';
import '../../../models/level_model.dart';
import '../../../const/app_const.dart';

class LearnCanvasController extends GetxController {
  var isLoading = false.obs;
  var imageUrl = ''.obs;
  var isCompleted = false.obs;
  var currentLevel = 'easy'.obs;
  var showNextLevelButton = false.obs;
  var currentDot = 1.obs;
  var nextDot = 2.obs;
  var dots = <Map<String, dynamic>>[].obs;
  var message = ''.obs;
  var isSuccessMessage = false.obs;

  var drawingPaths = <DrawingPath>[].obs;
  var currentDrawingPoints = <Offset>[].obs;
  var isDrawing = false.obs;

  var selectedColor = Colors.black.obs;
  var selectedStrokeWidth = 3.0.obs;
  var showDrawingTools = false.obs;

  var showDots = true.obs;
  var dotSize = 10.0.obs;
  var dotTolerance = 20.0.obs;

  var imageDimensions = const Size(400, 400).obs;
  var canvasSize = const Size(400, 400).obs;

  var totalDots = 0.obs;

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

  final int categoryId;
  final int drawingId;
  final List<String> levels = ['easy', 'medium', 'hard'];

  LearnCanvasController({required this.categoryId, required this.drawingId});

  @override
  void onInit() {
    super.onInit();
    loadDrawingLevel();
  }

  Future<void> loadDrawingLevel({String? level}) async {
    try {
      isLoading.value = true;
      final levelToLoad = level ?? currentLevel.value;
      currentLevel.value = levelToLoad;

      final url = Uri.parse(
          '${AppConstants.baseUrl}/api/categories/$categoryId/drawings/$drawingId/?mode=learn&level=$levelToLoad');
      print('Loading level: $url');

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      print('Response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final levelModel = LevelModel.fromJson(data);

        imageUrl.value = '${AppConstants.baseUrl}/${levelModel.imageUrl}';
        await _loadImageDimensions();

        currentDot.value = levelModel.currentDot.number;
        nextDot.value = levelModel.nextDot?.number ?? (currentDot.value + 1);
        totalDots.value = levelModel.totalDots;

        dots.assignAll(_scaleDots([
          levelModel.currentDot.toJson(),
          if (levelModel.nextDot != null) levelModel.nextDot!.toJson(),
        ]));

        isCompleted.value = levelModel.isCompleted;
        showNextLevelButton.value = levelModel.isCompleted;

        message.value = levelModel.message ?? '';
        isSuccessMessage.value = data['success'] ?? false;

        if (!levelModel.isCompleted) {
          drawingPaths.clear();
          currentDrawingPoints.clear();
        }

        if (Get.isDialogOpen == true) {
          Get.back();
          print('Closed completion dialog after loading new level');
        }
      } else if (response.statusCode == 400 &&
          response.body.contains('No more dots')) {
        final currentIndex = levels.indexOf(levelToLoad);
        if (currentIndex < levels.length - 1) {
          // Load the next level
          final nextLevelName = levels[currentIndex + 1];
          print(
              'Level $levelToLoad completed, loading next level: $nextLevelName');
          await loadDrawingLevel(level: nextLevelName);
        } else {
          // All levels completed, show dialog
          print('All levels completed for drawing $drawingId');
          _showAllLevelsCompletedDialog();
        }
      } else {
        throw Exception('Failed to load level: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading level: $e');
      // Check if error indicates completion
      if (e.toString().contains('No more dots')) {
        final currentIndex = levels.indexOf(currentLevel.value);
        if (currentIndex < levels.length - 1) {
          final nextLevelName = levels[currentIndex + 1];
          print(
              'Level ${currentLevel.value} completed, loading next level: $nextLevelName');
          await loadDrawingLevel(level: nextLevelName);
        } else {
          print('All levels completed for drawing $drawingId');
          _showAllLevelsCompletedDialog();
        }
      } else {
        imageUrl.value = '';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadImageDimensions() async {
    try {
      if (imageUrl.value.isNotEmpty) {
        imageDimensions.value = const Size(400, 400);
      }
    } catch (e) {
      print('Error loading image dimensions: $e');
      imageDimensions.value = const Size(400, 400);
    }
  }

  List<Map<String, dynamic>> _scaleDots(
      List<Map<String, dynamic>> originalDots) {
    return originalDots.map((dot) {
      final x = dot['x']?.toDouble() ?? 0.0;
      final y = dot['y']?.toDouble() ?? 0.0;

      final scaleX = canvasSize.value.width / imageDimensions.value.width;
      final scaleY = canvasSize.value.height / imageDimensions.value.height;

      final scaledX = (x * scaleX).clamp(0.0, canvasSize.value.width);
      final scaledY = (y * scaleY).clamp(0.0, canvasSize.value.height);

      print('Scaling dot ${dot['number']}: ($x, $y) -> ($scaledX, $scaledY)');

      return {
        ...dot,
        'x': scaledX,
        'y': scaledY,
      };
    }).toList();
  }

  Future<void> updateDot(int dotNumber) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/api/drawings/$drawingId/?mode=learn&level=${currentLevel.value}');
    try {
      print('Updating dot $dotNumber');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'dot_number': dotNumber}),
      );
      print('Update dot response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final levelModel = LevelModel.fromJson(data);
        totalDots.value = levelModel.totalDots;

        final oldCurrentDot = currentDot.value;

        currentDot.value = levelModel.currentDot.number;
        nextDot.value = levelModel.nextDot?.number ?? (currentDot.value + 1);

        List<Map<String, dynamic>> updatedDots = [
          levelModel.currentDot.toJson(),
        ];
        if (levelModel.nextDot != null) {
          updatedDots.add(levelModel.nextDot!.toJson());
        } else if (levelModel.closeContour &&
            levelModel.currentDot.number == levelModel.totalDots) {
          final firstDot = dots.firstWhere((dot) => dot['number'] == 1,
              orElse: () =>
                  {'number': 1, 'x': 0.0, 'y': 0.0, 'position_ratio': 0.0});
          updatedDots.add(firstDot);
          nextDot.value = 1;
        }
        dots.assignAll(_scaleDots(updatedDots));

        if (levelModel.isCompleted ||
            (levelModel.nextDot == null &&
                levelModel.currentDot.number >= levelModel.totalDots)) {
          print('Level completed detected via 200 response');
          if (levelModel.closeContour) {
            final firstDot = dots.firstWhere((dot) => dot['number'] == 1,
                orElse: () =>
                    {'number': 1, 'x': 0.0, 'y': 0.0, 'position_ratio': 0.0});
            final lastDot = dots.firstWhere(
                (dot) => dot['number'] == levelModel.totalDots,
                orElse: () => {
                      'number': levelModel.totalDots,
                      'x': 0.0,
                      'y': 0.0,
                      'position_ratio': 0.0
                    });
            final closingPath = DrawingPath(
              points: [
                Offset(lastDot['x'].toDouble(), lastDot['y'].toDouble()),
                Offset(firstDot['x'].toDouble(), firstDot['y'].toDouble())
              ],
              color: selectedColor.value,
              strokeWidth: selectedStrokeWidth.value,
            );
            drawingPaths.add(closingPath);
            print('Added closing path from dot ${levelModel.totalDots} to 1');
          }
          isCompleted.value = true;
          showNextLevelButton.value = true;
          message.value = 'Level Completed!';
          isSuccessMessage.value = true;
          _showCompletionDialog(levelModel);
          Future.delayed(const Duration(seconds: 2), () {
            print('Proceeding to next level after delay');
            nextLevel();
          });
        } else if (levelModel.currentDot.number > oldCurrentDot) {
          message.value = levelModel.message ?? 'Great job!';
          isSuccessMessage.value = true;
        } else {
          _removeLastDrawingPath();
          message.value = levelModel.message ?? 'Try again';
          isSuccessMessage.value = false;
        }
      } else if (response.statusCode == 400 &&
          response.body.contains('No more dots')) {
        print('Level completed detected via 400 response');
        LevelModel levelModel;
        try {
          final data = json.decode(response.body);
          levelModel = LevelModel.fromJson(data);
          totalDots.value = levelModel.totalDots;
        } catch (e) {
          print('Failed to parse 400 response as LevelModel: $e');
          levelModel = LevelModel(
            imageUrl: imageUrl.value,
            totalDots: totalDots.value,
            currentIndex: currentDot.value,
            mode: 'learn',
            currentDot: Dot(
              x: dots
                  .firstWhere((dot) => dot['number'] == currentDot.value,
                      orElse: () => {
                            'number': currentDot.value,
                            'x': 0.0,
                            'y': 0.0,
                            'position_ratio': 0.0
                          })['x']
                  .toInt(),
              y: dots
                  .firstWhere((dot) => dot['number'] == currentDot.value,
                      orElse: () => {
                            'number': currentDot.value,
                            'x': 0.0,
                            'y': 0.0,
                            'position_ratio': 0.0
                          })['y']
                  .toInt(),
              number: currentDot.value,
              positionRatio: 0.0,
            ),
            nextDot: null,
            contourId: 0,
            closeContour: true,
            isCompleted: true,
            message: 'Level Completed!',
          );
        }

        if (levelModel.closeContour) {
          final firstDot = dots.firstWhere((dot) => dot['number'] == 1,
              orElse: () =>
                  {'number': 1, 'x': 0.0, 'y': 0.0, 'position_ratio': 0.0});
          final lastDot = dots.firstWhere(
              (dot) => dot['number'] == levelModel.totalDots,
              orElse: () => {
                    'number': levelModel.totalDots,
                    'x': 0.0,
                    'y': 0.0,
                    'position_ratio': 0.0
                  });
          final closingPath = DrawingPath(
            points: [
              Offset(lastDot['x'].toDouble(), lastDot['y'].toDouble()),
              Offset(firstDot['x'].toDouble(), firstDot['y'].toDouble())
            ],
            color: selectedColor.value,
            strokeWidth: selectedStrokeWidth.value,
          );
          drawingPaths.add(closingPath);
          print('Added closing path from dot ${levelModel.totalDots} to 1');
        }
        isCompleted.value = true;
        showNextLevelButton.value = true;
        message.value = 'Level Completed!';
        isSuccessMessage.value = true;
        _showCompletionDialog(levelModel);
        Future.delayed(const Duration(seconds: 2), () {
          print('Proceeding to next level after delay');
          nextLevel();
        });
      } else {
        _removeLastDrawingPath();
        message.value = 'Failed to connect dot $dotNumber';
        isSuccessMessage.value = false;
      }
    } catch (e) {
      print('Error updating dot: $e');
      if (e.toString().contains('No more dots')) {
        print('Level completed detected via error');
        final levelModel = LevelModel(
          imageUrl: imageUrl.value,
          totalDots: totalDots.value,
          currentIndex: currentDot.value,
          mode: 'learn',
          currentDot: Dot(
            x: dots
                .firstWhere((dot) => dot['number'] == currentDot.value,
                    orElse: () => {
                          'number': currentDot.value,
                          'x': 0.0,
                          'y': 0.0,
                          'position_ratio': 0.0
                        })['x']
                .toInt(),
            y: dots
                .firstWhere((dot) => dot['number'] == currentDot.value,
                    orElse: () => {
                          'number': currentDot.value,
                          'x': 0.0,
                          'y': 0.0,
                          'position_ratio': 0.0
                        })['y']
                .toInt(),
            number: currentDot.value,
            positionRatio: 0.0,
          ),
          nextDot: null,
          contourId: 0,
          closeContour: true,
          isCompleted: true,
          message: 'Level Completed!',
        );

        if (levelModel.closeContour) {
          final firstDot = dots.firstWhere((dot) => dot['number'] == 1,
              orElse: () =>
                  {'number': 1, 'x': 0.0, 'y': 0.0, 'position_ratio': 0.0});
          final lastDot = dots.firstWhere(
              (dot) => dot['number'] == levelModel.totalDots,
              orElse: () => {
                    'number': levelModel.totalDots,
                    'x': 0.0,
                    'y': 0.0,
                    'position_ratio': 0.0
                  });
          final closingPath = DrawingPath(
            points: [
              Offset(lastDot['x'].toDouble(), lastDot['y'].toDouble()),
              Offset(firstDot['x'].toDouble(), firstDot['y'].toDouble())
            ],
            color: selectedColor.value,
            strokeWidth: selectedStrokeWidth.value,
          );
          drawingPaths.add(closingPath);
          print('Added closing path from dot ${levelModel.totalDots} to 1');
        }
        isCompleted.value = true;
        showNextLevelButton.value = true;
        message.value = 'Level Completed!';
        isSuccessMessage.value = true;
        _showCompletionDialog(levelModel);
        Future.delayed(const Duration(seconds: 2), () {
          print('Proceeding to next level after delay');
          nextLevel();
        });
      } else {
        _removeLastDrawingPath();
        message.value = 'Network error: $e';
        isSuccessMessage.value = false;
      }
    }
  }

  void _showCompletionDialog(LevelModel levelModel) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Level Completed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Great job completing ${currentLevel.value.capitalize} level!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    print('Displayed completion dialog');
  }

  void _showAllLevelsCompletedDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'All Levels Completed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have completed all levels for this drawing!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Get.back(closeOverlays: true);
                Get.back(closeOverlays: true);
                print('Navigated back to drawings screen');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Choose New Drawing',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    print('Displayed all levels completed dialog');
  }

  void _removeLastDrawingPath() {
    if (drawingPaths.isNotEmpty) {
      drawingPaths.removeLast();
      print(
          'Removed last drawing path. Remaining paths: ${drawingPaths.length}');
    }
  }

  void startDrawing(Offset point) {
    isDrawing.value = true;
    currentDrawingPoints.clear();
    currentDrawingPoints.add(point);
    print('Started drawing at $point');
  }

  void updateDrawing(Offset point) {
    if (isDrawing.value) {
      currentDrawingPoints.add(point);
    }
  }

  void endDrawing() {
    if (isDrawing.value && currentDrawingPoints.isNotEmpty) {
      final newPath = DrawingPath(
        points: List.from(currentDrawingPoints),
        color: selectedColor.value,
        strokeWidth: selectedStrokeWidth.value,
      );
      drawingPaths.add(newPath);
      isDrawing.value = false;

      final lastPoint = currentDrawingPoints.last;
      final nextDotData =
          dots.firstWhereOrNull((dot) => dot['number'] == nextDot.value);
      currentDrawingPoints.clear();

      if (nextDotData != null) {
        final dotX = nextDotData['x'].toDouble();
        final dotY = nextDotData['y'].toDouble();

        print(
            'Checking connection: last point ($lastPoint) vs next dot ($dotX, $dotY)');
        print(
            'Distance: ${(lastPoint - Offset(dotX, dotY)).distance}, Tolerance: ${dotTolerance.value}');

        if (_isPointNearDot(lastPoint, Offset(dotX, dotY))) {
          print('Valid connection detected, updating dot ${nextDot.value}');
          updateDot(nextDot.value);
        } else {
          print('Invalid connection - removing path');
          _removeLastDrawingPath();
          message.value =
              'Connect to dot ${nextDot.value} (distance: ${(lastPoint - Offset(dotX, dotY)).distance.toStringAsFixed(1)})';
          isSuccessMessage.value = false;
        }
      } else if (currentDot.value >= totalDots.value &&
          dots.any((dot) => dot['number'] == currentDot.value)) {
        print('Last dot reached, updating dot ${currentDot.value}');
        updateDot(currentDot.value);
      } else {
        print('No next dot found');
        _removeLastDrawingPath();
        message.value = 'No next dot found';
        isSuccessMessage.value = false;
      }
    }
  }

  bool _isPointNearDot(Offset point, Offset dotCenter) {
    final distance = (point - dotCenter).distance;
    return distance <= dotTolerance.value;
  }

  void retryLevel() {
    drawingPaths.clear();
    currentDrawingPoints.clear();
    isCompleted.value = false;
    showNextLevelButton.value = false;
    message.value = '';
    loadDrawingLevel();
    print('Retrying level ${currentLevel.value}');
  }

  void nextLevel() {
    final currentIndex = levels.indexOf(currentLevel.value);
    if (currentIndex < levels.length - 1) {
      final nextLevelName = levels[currentIndex + 1];
      drawingPaths.clear();
      currentDrawingPoints.clear();
      isCompleted.value = false;
      showNextLevelButton.value = false;
      message.value = '';
      loadDrawingLevel(level: nextLevelName);
      print('Moving to next level: $nextLevelName');
    } else {
      _showAllLevelsCompletedDialog();
    }
  }

  void toggleDrawingTools() {
    showDrawingTools.value = !showDrawingTools.value;
    print('Toggled drawing tools: ${showDrawingTools.value}');
  }

  void selectColor(MaterialColor color) {
    selectedColor.value = color;
    print('Selected color: $color');
  }

  void selectStrokeWidth(double width) {
    selectedStrokeWidth.value = width;
    print('Selected stroke width: $width');
  }

  void toggleDots() {
    showDots.value = !showDots.value;
    print('Toggled dots visibility: ${showDots.value}');
  }

  void adjustDotSize(double size) {
    dotSize.value = size.clamp(5.0, 20.0);
    print('Adjusted dot size: ${dotSize.value}');
  }

  void adjustDotTolerance(double tolerance) {
    dotTolerance.value = tolerance.clamp(10.0, 50.0);
    print('Adjusted dot tolerance: ${dotTolerance.value}');
  }

  void adjustDotPosition(int dotNumber, Offset newPosition) {
    final dotIndex = dots.indexWhere((dot) => dot['number'] == dotNumber);
    if (dotIndex != -1) {
      dots[dotIndex] = {
        ...dots[dotIndex],
        'x': newPosition.dx.clamp(0.0, canvasSize.value.width),
        'y': newPosition.dy.clamp(0.0, canvasSize.value.height),
      };
      dots.refresh();
      print('Adjusted dot $dotNumber position to $newPosition');
    }
  }
}
