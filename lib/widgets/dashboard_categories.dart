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

  _DashboardCategoriesState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            bottom: 8,
            left: 16,
            right: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.tle_category,
                style: textTheme.titleLarge,
              ),
              InkWell(
                onTap: () {
                  Get.to(() => AllCategoriesScreen(
                        analytics: widget.analytics,
                        observer: widget.observer,
                      ));
                },
                child: Text(
                  "${AppLocalizations.of(context)!.btn_view_all} ",
                  style: textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 3; // 3 cards per row
            double cardHeight = 140;
            // Increase height for better visibility
            double spacing = 16; // Maintain spacing
            int rowCount =
                (widget.topCategoryList.length / crossAxisCount).ceil();
            double dynamicHeight =
                (rowCount * cardHeight) + ((rowCount - 1) * spacing);

            return SizedBox(
              height: dynamicHeight,
              child: GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scrolling
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: widget.topCategoryList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Ensure 3 cards per row
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 0.8, // Adjust for better height
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
                      Get.to(() => SubCategoriesScreen
                      (
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
            );
          },
        ),
      ],
    );
  }
}
