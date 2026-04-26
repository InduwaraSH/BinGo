import 'dart:ui';
import 'package:bingo/Driver/Dri_Home.dart';
import 'package:bingo/Driver/Dri_Jobs.dart';
import 'package:bingo/Driver/Dri_Route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class DriNavBar extends StatefulWidget {
  final String office_location;
  final String username;

  const DriNavBar({
    super.key,
    required this.office_location,
    required this.username,
  });

  @override
  State<DriNavBar> createState() => _DriNavBarState();
}

class _DriNavBarState extends State<DriNavBar> {
  late final DriNavigController _navController;

  @override
  void initState() {
    super.initState();
    Get.delete<DriNavigController>();
    _navController = Get.put(
      DriNavigController(widget.office_location, widget.username),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xFFF5F6FA),
        body: Stack(
          children: [
            _navController.screens[_navController.selectedIndex.value],
            Positioned(
              left: 18,
              right: 18,
              bottom: 20,
              child: SizedBox(
                height: 90,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(38),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        height: 82,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(38),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.03),
                          ),
                        ),
                        child: Row(
                          children: List.generate(
                            _navController.items.length,
                            (index) {
                              final item = _navController.items[index];
                              final bool active =
                                  _navController.selectedIndex.value == index;
                              final int flex = active ? 2 : 1;

                              return Expanded(
                                flex: flex,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      _navController.selectedIndex.value =
                                          index,
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 420),
                                    curve: Curves.easeOutCubic,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? Colors.white.withOpacity(0.06)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 320,
                                          ),
                                          curve: Curves.easeOut,
                                          padding:
                                              EdgeInsets.all(active ? 8 : 4),
                                          decoration: BoxDecoration(
                                            color: active
                                                ? Colors.white
                                                    .withOpacity(0.08)
                                                : Colors.transparent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: AnimatedScale(
                                            scale: active ? 1.25 : 1.0,
                                            duration: const Duration(
                                              milliseconds: 280,
                                            ),
                                            curve: Curves.easeOutBack,
                                            child: Icon(
                                              item['icon'],
                                              size: 24,
                                              color: active
                                                  ? Colors.white
                                                  : Colors.grey[400],
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: AnimatedSize(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                            child: AnimatedOpacity(
                                              opacity: active ? 1 : 0,
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: active ? 7 : 0,
                                                ),
                                                child: Text(
                                                  active
                                                      ? item['label']
                                                      : '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.fade,
                                                  softWrap: false,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    fontSize: 14,
                                                    letterSpacing: 0.2,
                                                  ),
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
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriNavigController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final String driverName;
  final String driverEmail;

  DriNavigController(this.driverName, this.driverEmail);

  late final List<Map<String, dynamic>> items = [
    {'icon': Iconsax.home, 'label': 'Home'},
    {'icon': Iconsax.map, 'label': 'Route'},
    {'icon': Iconsax.task_square, 'label': 'Jobs'},
  ];

  late final List<Widget> screens = [
    DriHome(driverName: driverName, driverEmail: driverEmail),
    DriRoute(driverEmail: driverEmail, driverName: driverName),
    DriJobs(driverEmail: driverEmail, driverName: driverName),
  ];
}
