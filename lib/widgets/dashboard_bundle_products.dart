import 'package:flutter/material.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:user/models/category_product_model.dart';
import 'package:user/screens/productlist_screen.dart';
import 'package:user/widgets/bundle_offers_menu.dart';

import 'gradient_heading_row.dart';

class DashboardBundleProducts extends StatelessWidget {
  final FirebaseAnalytics? analytics;
  final FirebaseAnalyticsObserver? observer;
  final String title;
  final String categoryName;
  final List<Product> dealProducts;
  final int? screenId;

  const DashboardBundleProducts(
      {super.key,
      this.analytics,
      this.observer,
      required this.title,
      required this.categoryName,
      required this.dealProducts,
      this.screenId});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        buildGradientHeadingRow(context, title),
        BundleOffersMenu(
          analytics: analytics,
          observer: observer,
          categoryProductList: dealProducts,
        ),
      ],
    );
  }
}
