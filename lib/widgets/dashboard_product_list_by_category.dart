import 'package:flutter/material.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:user/models/home_screen_data_model.dart';
import 'package:user/screens/productlist_screen.dart';
import 'package:user/theme/style.dart';
import 'package:user/widgets/bundle_offers_menu.dart';

class DashboardProductListByCategory extends StatelessWidget {
  final FirebaseAnalytics? analytics;
  final FirebaseAnalyticsObserver? observer;
  final List<CategoryProdList> productListByCategory;

  const DashboardProductListByCategory(
      {super.key,
      this.analytics,
      this.observer,
      required this.productListByCategory});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    print("_____________________12345678________________________${productListByCategory}");
    return ListView.builder(
        shrinkWrap: true,
        itemCount: productListByCategory.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  bottom: 8,
                  left: 16,
                  right: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${productListByCategory[index].catTitle}",
                          style: textTheme.titleLarge,
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => ProductListScreen(
                                  analytics: analytics,
                                  observer: observer,
                                  screenId: 0,
                                  categoryName:
                                      productListByCategory[index].catTitle,
                                  categoryId:
                                      productListByCategory[index].catId,
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
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        "${productListByCategory[index].description}",
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        style:
                            normalCaptionStyle(context).copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              //${productListByCategory[index].catTitle}
              BundleOffersMenu(
                analytics: analytics,
                observer: observer,
                categoryProductList: productListByCategory[index].products,
              ),
            ],
          );
        });
  }
}
