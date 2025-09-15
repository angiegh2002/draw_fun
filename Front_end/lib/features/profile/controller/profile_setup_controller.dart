import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../const/app_const.dart';
import '../../../models/user_model.dart';
import '../../main_screen.dart';

class ProfileSetupController extends GetxController {
  String _username = '';
  int _age = 3;
  String _message = '';

  String get message => _message;

  int get age => _age;

  void setUsername(String username) {
    _username = username;
    update();
  }

  void setAge(int age) {
    _age = age;
    update();
  }

  Future<void> saveProfile(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', user.username);
    await prefs.setInt('user_age', user.age);
    await prefs.setString('user_id', user.id);
  }

  Future<bool> lookupUser(BuildContext context) async {
    try {
      final url = Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.apiPrefix}${AppConstants.userLookup}?username=$_username&age=$_age');
      print('Requesting lookup URL: $url');
      final response = await http.get(url);
      print(
          'Lookup status code: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final user = UserModel.fromJson(json);
        await saveProfile(user);
        if (context.mounted) {
          print('Navigating to MainScreen with sessionId: ${user.id}');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(userId: user.id)),
          );
        }
        return true; // User found, login successful
      } else if (response.statusCode == 404 || response.statusCode == 400) {
        final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
        _message = error == 'Username and age are required'
            ? 'Please enter your name and age!'
            : 'Name or age not found!';
        update();
        return false; // User not found
      } else {
        _message = 'Something went wrong, try again!';
        update();
        return false;
      }
    } catch (e) {
      print('Lookup request error: $e');
      _message = 'Something went wrong, try again!';
      update();
      return false;
    }
  }

  Future<bool> signup(BuildContext context) async {
    try {
      final url = Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.apiPrefix}${AppConstants.userSignup}');
      print('Requesting signup URL: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': _username, 'age': _age}),
      );
      print(
          'Signup status code: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final user = UserModel.fromJson(json);
        await saveProfile(user);
        if (context.mounted) {
          print('Navigating to MainScreen with sessionId: ${user.id}');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(userId: user.id)),
          );
        }
        return true; // Signup successful
      } else if (response.statusCode == 400) {
        _message = 'Oops! That name is taken, try a unique name!';
        update();
        return false;
      } else {
        _message = 'Signup failed, try again!';
        update();
        return false;
      }
    } catch (e) {
      print('Signup request error: $e');
      _message = 'Something went wrong, try again!';
      update();
      return false;
    }
  }

  Future<void> navigateToMain(BuildContext context) async {
    if (_username.isNotEmpty && _age > 0) {
      print('Starting navigateToMain');
      _message = ''; // Clear previous messages
      update();
      final userExists = await lookupUser(context);
      if (!userExists) {
        await signup(context);
      }
    } else {
      _message = 'Please enter your name and age!';
      update();
    }
  }
}
