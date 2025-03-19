import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:user/models/category_list_model.dart';
import 'package:user/screens/all_categories_screen.dart';
import 'package:user/screens/sub_categories_screen.dart';
import 'package:user/widgets/select_category_card.dart';

class DashboardCategories extends StatefulWidget {
  final FirebaseAnalytics? analytics;
  final FirebaseAnalyticsObserver? observer;
  final List<CategoryList> topCategoryList;

  const DashboardCategories(
      {super.key,
      this.analytics,
      this.observer,
      required this.topCategoryList});

  @override
  State<DashboardCategories> createState() {
    return _DashboardCategoriesState();
  }
}

class _DashboardCategoriesState extends State<DashboardCategories> {
  int _selectedIndex = 0;
  double _buttonPosition = 20; // Initial position
  bool _movingUp = true;

  @override
  void initState() {
    super.initState();
    _startButtonAnimation();
  }

  void _startButtonAnimation() {
    Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        _buttonPosition = _movingUp ? 30 : 20;
        _movingUp = !_movingUp;
      });
    });
  }

  _DashboardCategoriesState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.42,
          child: Column(
            children: [
              // Explore Menu with Centered Text and Lines
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                               // Dark Gray
                              Colors.black,
                              Colors.black54, // Light Gray
                              Colors.black12,// Black
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Explore Menu",
                        style: textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              Colors.black12, // Light Gray
                              Colors.black54, // Dark Gray
                              Colors.black,   // Black
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: widget.topCategoryList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    return SelectCategoryCard(
                      key: UniqueKey(),
                      category: widget.topCategoryList[index],
                      onPressed: () {
                        setState(() {
                          widget.topCategoryList
                              .map((e) => e.isSelected = false)
                              .toList();
                          _selectedIndex = index;
                          if (_selectedIndex == index) {
                            widget.topCategoryList[index].isSelected = true;
                          }
                        });
                        Get.to(() => SubCategoriesScreen(
                          analytics: widget.analytics,
                          observer: widget.observer,
                          screenHeading: widget.topCategoryList[index].title,
                          categoryId: widget.topCategoryList[index].catId,
                        ));
                      },
                      isSelected: widget.topCategoryList[index].isSelected,
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Gradient Effect at Bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.7),
                  Colors.white,
                ],
              ),
            ),
          ),
        ),

        // "View All" Button at Bottom Center
        AnimatedPositioned(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          bottom: _buttonPosition,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                fixedSize: const Size(95, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xffe54740), width: 0.5),
                ),
              ),
              onPressed: () {
                Get.to(() => AllCategoriesScreen(
                  analytics: widget.analytics,
                  observer: widget.observer,
                ));
              },
              child: const Text("View all"),
            ),
          ),
        ),
      ],
    );
  }
}
