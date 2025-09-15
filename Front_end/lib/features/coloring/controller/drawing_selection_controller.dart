import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../const/app_const.dart';

class DrawingSelectionController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> drawings = <Map<String, dynamic>>[].obs;
  final String baseUrl = AppConstants.baseUrl;

  @override
  void onInit() {
    super.onInit();
    fetchDrawings();
  }

  Future<void> fetchDrawings() async {
    try {
      isLoading.value = true;
      final url = Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.apiPrefix}${AppConstants.drawings}');
      print('Requesting drawings URL: $url');

      final response = await http.get(url);
      print(
          'Drawings status code: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        drawings.value =
            data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load drawings: ${response.body}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Drawings request error: $e');
      Get.snackbar(
        'Error',
        'Network issue: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDrawings() async {
    await fetchDrawings();
  }
}
