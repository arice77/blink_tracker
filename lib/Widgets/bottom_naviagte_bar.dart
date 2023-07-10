import 'package:blink_tracker/main.dart';
import 'package:flutter/material.dart';

class BottomNavigator extends StatelessWidget {
  const BottomNavigator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return BottomNavigationBar(
          onTap: (value) {
            if (value == 1) {
              Navigator.pushReplacementNamed(context, '/analytics');
            } else {
              Navigator.pushReplacementNamed(context, MyApp.routeName);
            }
          },
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.white,
          selectedLabelStyle: const TextStyle(color: Colors.white),
          unselectedLabelStyle: const TextStyle(color: Colors.white),
          backgroundColor: const Color.fromARGB(255, 31, 31, 30),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.analytics), label: 'Analytics')
          ]);
    });
  }
}
