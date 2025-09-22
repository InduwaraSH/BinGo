import 'package:bingo/a.dart';
import 'package:bingo/b.dart';
import 'package:bingo/c.dart';
import 'package:bingo/d.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigControll());

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: Obx(
        () => Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Page content
              Padding(
                padding: const EdgeInsets.only(bottom: 0), // space for nav bar
                child: controller.screens[controller.selectedIndex.value],
              ),

              // Floating nav bar with shadow
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: SafeArea(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(150, 255, 255, 255),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BottomNavigationBar(
                        currentIndex: controller.selectedIndex.value,
                        onTap: (index) =>
                            controller.selectedIndex.value = index,
                        backgroundColor: Colors.white,
                        type: BottomNavigationBarType.fixed,
                        elevation: 0,
                        selectedItemColor: Colors.black,
                        unselectedItemColor: Colors.black54,
                        showUnselectedLabels: true,
                        selectedFontSize: 12,
                        selectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedFontSize: 12,
                        items: [
                          _navItem(
                            Iconsax.home,
                            "Home",
                            controller.selectedIndex.value == 0,
                          ),
                          _navItem(
                            Iconsax.truck,
                            "Route",
                            controller.selectedIndex.value == 1,
                          ),
                          _navItem(
                            Iconsax.trash,
                            "Jobs",
                            controller.selectedIndex.value == 2,
                          ),
                          _navItem(
                            Iconsax.coin,
                            "Payment",
                            controller.selectedIndex.value == 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, String label, bool active) {
    return BottomNavigationBarItem(
      icon: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: active ? 1.2 : 1.0),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: Icon(icon, color: active ? Colors.black : Colors.black54),
        ),
      ),
      label: label,
    );
  }
}

class NavigControll extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final screens = [page(), pgtwo(), pgthree(), pgfour()];
}
