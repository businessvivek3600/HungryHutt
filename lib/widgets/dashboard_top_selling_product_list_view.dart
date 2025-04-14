import 'package:flutter/material.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:user/models/category_product_model.dart';
import 'package:user/screens/productlist_screen.dart';
import 'package:user/widgets/products_menu.dart';

import 'gradient_heading_row.dart';

class DashboardTopSellingProductList extends StatelessWidget {
  final FirebaseAnalytics? analytics;
  final FirebaseAnalyticsObserver? observer;
  final List<Product> topSellingProducts;

  const DashboardTopSellingProductList(
      {super.key,
      this.analytics,
      this.observer,
      required this.topSellingProducts});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        buildGradientHeadingRow(context, '${AppLocalizations.of(context)!.lbl_top_selling} ',),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ProductsMenu(
            analytics: analytics,
            observer: observer,
            categoryProductList: topSellingProducts,
          ),
        )
      ],
    );
  }
}
