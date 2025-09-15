import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../const/app_const.dart';
import '../../../models/category_model.dart';
import '../../drawing/view/drawing_screen.dart';
import '../../profile/view/profile_screen.dart';

class HomeController extends GetxController {
  final String sessionId;
  String username = '';
  int age = 0;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  HomeController(this.sessionId);

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    fetchCategories();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('user_name') ?? 'Friend';
    age = prefs.getInt('user_age') ?? 0;
    update();
  }

  Future<void> fetchCategories() async {
    try {
      final url = Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.apiPrefix}${AppConstants.categories}');
      print('Requesting categories URL: $url');
      final response = await http.get(url);
      print(
          'Categories status code: ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        categories.assignAll(
            jsonList.map((json) => CategoryModel.fromJson(json)).toList());
      } else {
        print('Error: Failed to load categories: ${response.body}');
        categories.assignAll([
          CategoryModel(id: 1, name: 'Animals', image: '', drawingCount: 0),
          CategoryModel(id: 2, name: 'Vehicles', image: '', drawingCount: 0),
        ]);
      }
    } catch (e) {
      print('Categories request error: $e');
      categories.assignAll([
        CategoryModel(id: 1, name: 'Animals', image: '', drawingCount: 0),
        CategoryModel(id: 2, name: 'Vehicles', image: '', drawingCount: 0),
      ]);
    }
    update();
  }

  void navigateToCategory(BuildContext context, int categoryId, String mode) {
    print('navigateToCategory: mode=$mode, categoryId=$categoryId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DrawingsScreen(categoryId: categoryId, mode: mode),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
      );
    }
  }
}
