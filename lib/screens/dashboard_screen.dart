import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/home_screen_data_model.dart';
import 'package:user/screens/notification_screen.dart';
import 'package:user/screens/product_description_screen.dart';
import 'package:user/screens/productlist_screen.dart';
import 'package:user/screens/search_screen.dart';
import 'package:user/widgets/dashboard_widgets.dart';

import '../widgets/item_grid_large.dart';

class DashboardScreen extends BaseRoute {
  final Function()? onAppDrawerButtonPressed;

  const DashboardScreen(
      {super.key,
        super.analytics,
        super.observer,
        super.routeName = 'DashboardScreen',
        this.onAppDrawerButtonPressed});

  @override
  BaseRouteState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends BaseRouteState<DashboardScreen> {
  Future<HomeScreenData?> _homeDataFuture = Future.value(null);
  IconData lastTapped = Icons.notifications;
  AnimationController? menuAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CartController cartController = Get.put(CartController());

  _DashboardScreenState();

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        // floatingActionButton: DashboardFloatingActionButton(
        //     analytics: widget.analytics,
        //     observer: widget.observer,
        //     callNumberStore: callNumberStore,
        //     inviteFriendShareMessage: br.inviteFriendShareMessage),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 4,
              expandedHeight: 70,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              pinned: true,
              backgroundColor:    const Color(0xFF68a039),
             // expandedHeight: 220.0,
              // flexibleSpace: FlexibleSpaceBar(
              //   background: Container(
              //     decoration:   BoxDecoration(
              //       gradient: LinearGradient(
              //         begin: Alignment.topLeft,
              //         end: Alignment.bottomRight,
              //         colors: [
              //          // Color(0xFFFF8000).withOpacity(0.8), // Deep orange shade
              //           Color(0xFF539e83), Color(0xFF539e83), // Warm yellow-orange shade
              //         ],
              //       ),
              //       borderRadius: BorderRadius.only(
              //         bottomLeft: Radius.circular(20),
              //         bottomRight: Radius.circular(20),
              //       ),
              //     ),
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       children: [
              //         const SizedBox(height: 30),
              //         Image.asset(
              //           'assets/images/bannerap.png',
              //           fit: BoxFit.cover,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              leading: IconButton(
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                icon: const Icon(Icons.dashboard_outlined, color: Colors.white),
                onPressed: widget.onAppDrawerButtonPressed,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DashboardLocationTitle(
                    analytics: widget.analytics,
                    observer: widget.observer,
                    getCurrentPosition: getCurrentPosition,
                  ),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: const VisualDensity(horizontal: -4),
                        icon: const Icon(Icons.search_outlined, color: Colors.white),
                        onPressed: () => Get.to(() => SearchScreen(
                          analytics: widget.analytics,
                          observer: widget.observer,
                        )),
                      ),
                      if (global.currentUser?.id != null)
                        IconButton(
                          visualDensity: const VisualDensity(horizontal: -4),
                          icon: const Icon(Icons.notifications_none, color: Colors.white),
                          onPressed: () => Get.to(() => NotificationScreen(
                            analytics: widget.analytics,
                            observer: widget.observer,
                          )),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _onRefresh();
                },
                child: FutureBuilder<HomeScreenData?>(
                  future: _homeDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const DashboardLoadingView();
                    } else if (snapshot.connectionState == ConnectionState.done) {
                      if (global.nearStoreModel != null &&
                          global.nearStoreModel?.id != null &&
                          snapshot.hasData) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10,),
                              // const Padding(
                              //   padding: EdgeInsets.symmetric(
                              //     vertical: 16.0,
                              //     horizontal: 16,
                              //   ),
                              //   child: DashboardScreenHeading(),
                              // ),
                              (snapshot.data?.banner.isNotEmpty ?? false)
                                  ? DashboardBanner1(
                                  items: _bannerItems(snapshot.data!))
                                  : const SizedBox(),
                              (snapshot.data?.topCat.isNotEmpty ?? false)
                                  ? DashboardCategories(
                                analytics: widget.analytics,
                                observer: widget.observer,
                                topCategoryList: snapshot.data!.topCat,
                              )
                                  : const SizedBox(),
                              const SizedBox(height: 10,),
                              (snapshot.data?.dealproduct.isNotEmpty ?? false)
                                  ?
                              //     DashboardBundleProducts(
                              //       analytics: widget.analytics,
                              //       observer: widget.observer,
                              //       title: AppLocalizations.of(context)!.tle_bundle_offers,
                              //       categoryName: '${AppLocalizations.of(context)!.tle_bundle_offers} ${AppLocalizations.of(context)!.tle_products}',
                              //       dealProducts: snapshot.data!.dealproduct,
                              //       screenId: 1,
                              //     ) : const SizedBox(),
                              // (snapshot.data?.catProdList.isNotEmpty ?? false) ?
                              DashboardProductListByCategory(
                                analytics: widget.analytics,
                                observer: widget.observer,
                                productListByCategory:
                                snapshot.data!.catProdList,
                              )
                                  : const SizedBox.shrink(),
                              // (snapshot.data?.ProductList.isNotEmpty ?? false)
                              // ?
                              //     DashboardBundleProducts(
                              //         analytics: widget.analytics,
                              //         observer: widget.observer,
                              //         title:
                              //             AppLocalizations.of(context)!.lbl_whats_new,
                              //         categoryName:
                              //             '${AppLocalizations.of(context)!.lbl_whats_new} ${AppLocalizations.of(context)!.tle_products}',
                              //         dealProducts:
                              //             snapshot.data!.whatsnewProductList,
                              //         screenId: 3,
                              //       )
                              //     : const SizedBox(),
                              (snapshot.data?.secondBanner.isNotEmpty ?? false)
                                  ? DashboardBanner2(
                                  margin: const EdgeInsets.only(top: 10),
                                  items: _secondBannerItems(snapshot.data!))
                                  : const SizedBox(),

                              (snapshot.data?.spotLightProductList.isNotEmpty ??
                                  false)
                                  ? DashboardBundleProducts(
                                analytics: widget.analytics,
                                observer: widget.observer,
                                title:
                                "${AppLocalizations.of(context)!.lbl_in_spotlight} ",
                                categoryName:
                                '${AppLocalizations.of(context)!.lbl_in_spotlight} ',
                                dealProducts:
                                snapshot.data!.spotLightProductList,
                                screenId: 4,
                              )
                                  : const SizedBox(),
                              (snapshot.data?.bestsellerProductList.isNotEmpty ??
                                  false)
                                  ? DashboardBundleProducts(
                                analytics: widget.analytics,
                                observer: widget.observer,
                                title: AppLocalizations.of(context)!
                                    .lbl_best_seller,
                                categoryName:
                                '${AppLocalizations.of(context)!.lbl_best_seller} ${AppLocalizations.of(context)!.tle_products}',
                                dealProducts:
                                snapshot.data!.bestsellerProductList,
                                screenId: 3,
                              )
                                  : const SizedBox(),

                              (snapshot.data?.recentSellingProductList.isNotEmpty ??
                                  false)
                                  ? NewlyProductGrid(
                                analytics: widget.analytics,
                                observer: widget.observer,
                                title:
                                "${AppLocalizations.of(context)!.lbl_recent_selling} ",
                                categoryName:
                                '${AppLocalizations.of(context)!.lbl_recent_selling} ',
                                dealProducts:
                                snapshot.data!.recentSellingProductList,
                                screenId: 5,
                              )
                                  : const SizedBox(),
                              (snapshot.data?.topselling.isNotEmpty ?? false)
                                  ? DashboardTopSellingProductList(
                                analytics: widget.analytics,
                                observer: widget.observer,
                                topSellingProducts: snapshot.data!.topselling,
                              )
                                  : const SizedBox(),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(global.locationMessage!),
                          ),
                        );
                      } else {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(global.locationMessage!),
                          ),
                        );
                      }
                    } else {
                      return const Text("This shouldn't be seen ever");
                    }
                  },
                ),
              ),
            ),
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    menuAnimation = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _init();
  }

  List<Widget> _bannerItems(HomeScreenData homeScreenData) {
    List<Widget> list = [];
    for (int i = 0; i < homeScreenData.banner.length; i++) {
      list.add(InkWell(
        onTap: () {
          Get.to(() => ProductListScreen(
            analytics: widget.analytics,
            observer: widget.observer,
            categoryId: homeScreenData.banner[i].catId,
            screenId: 0,
            categoryName: homeScreenData.banner[i].title,
          ));
        },
        child: CachedNetworkImage(
          imageUrl:
          global.appInfo!.imageUrl! + homeScreenData.banner[i].bannerImage!,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: const DecorationImage(
                  image: AssetImage('assets/images/icon.png'),
                  fit: BoxFit.cover),
            ),
          ),
        ),
      ));
    }
    return list;
  }

  Future<HomeScreenData?> getHomeScreenData() async {
    try {
      // debugPrint('Near by store id: ${1}');
      // debugPrint('Current user id: ${9}');

      String apiUrl = '${global.baseUrl}oneapi';
      debugPrint("API Call: $apiUrl");

      Map<String, String> body = {
        'store_id': "${global.nearStoreModel?.id}",
        'user_id': "${global.currentUser?.id}",
      };

      debugPrint("Request Body: $body");

      final response = await http.post(
        Uri.parse(apiUrl),
        body: body,
      );

      debugPrint("API Response Status: ${response.statusCode}");
      debugPrint("API Response Data: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == '1') {
          return HomeScreenData.fromJson(responseData);
        } else {
          debugPrint("API Error: ${response.statusCode} - ${responseData}");
          return null;
        }
      } else {
        debugPrint("HTTP Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Exception - getHomeScreenData(): $e");
      return null;
    }
  }

  _init() async {
    try {
      if (global.lat == null && global.lng == null) {
        await getCurrentPosition();
      }

      _homeDataFuture = getHomeScreenData();

      if (global.currentUser?.id != null) {
        cartController.getCartList();
      }
      setState(() {});
    } catch (e) {
      debugPrint("Exception - dashboard_screen.dart - _init():$e");
    }
  }

  _onRefresh() async {
    try {
      await _init();
    } catch (e) {
      debugPrint("Exception - dashboard_screen.dart - _onRefresh():$e");
    }
  }

  List<Widget> _secondBannerItems(HomeScreenData homeScreenData) {
    return homeScreenData.secondBanner.map((banner) {
      return InkWell(
        onTap: () {
          Get.to(() => ProductDescriptionScreen(
            analytics: widget.analytics,
            observer: widget.observer,
            productId: banner.varientId ?? 0,
            screenId: 0,
          ) );
        },
        child: CachedNetworkImage(
          imageUrl: global.appInfo!.imageUrl! + banner.bannerImage!,
          imageBuilder: (context, imageProvider) => Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover, // ✅ Ensures the image fills the full container
              ),
            ),
          ),
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: const DecorationImage(
                  image: AssetImage('assets/images/icon.png'), fit: BoxFit.cover),
            ),
          ),
        ),
      );
    }).toList();
  }


  void callNumberStore(storeNumber) async {
    await launchUrlString('tel:$storeNumber');
  }
}
