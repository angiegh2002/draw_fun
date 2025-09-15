// import 'package:flutter/material.dart';
// import '../const/app_colors.dart';
// import 'coloring/view/drawing_selection_screen.dart';
// import 'hand_drawing/view/hand_drawing_screen.dart';
// import 'home/view/home_screen.dart';
//
// class MainScreen extends StatefulWidget {
//   final String userId;
//
//   MainScreen({required this.userId});
//
//   @override
//   _MainScreenState createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;
//   late List<Widget> _screens;
//
//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       HomeScreen(userId: widget.userId),
//       HandDrawingScreen(),
//       const DrawingSelectionScreen(),
//     ];
//   }
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.edit), label: 'Hand Drawing'),
//           BottomNavigationBarItem(icon: Icon(Icons.palette), label: 'Coloring'),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         backgroundColor: AppColors.primaryColor,
//         selectedItemColor: AppColors.textColor,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../const/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import 'coloring/view/drawing_selection_screen.dart';
import 'hand_drawing/view/hand_drawing_screen.dart';
import 'home/view/home_screen.dart';

class MainScreen extends StatefulWidget {
  final String userId;

  MainScreen({required this.userId});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(userId: widget.userId),
      HandDrawingScreen(),
      const DrawingSelectionScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFE0FFFF), // Light cyan for card visibility
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
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
              blurRadius: 8,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 30),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit, size: 30),
              label: 'Hand Drawing',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.palette, size: 30),
              label: 'Coloring',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: AppColors.textColor.withOpacity(0.7),
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 12,
          ),
          elevation: 0,
          iconSize: 30,
        ),
      ),
    );
  }
}
