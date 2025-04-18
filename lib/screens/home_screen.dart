import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/controllers/home_controller.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/screens/app_drawer_wrapper_screen.dart';
import 'package:user/screens/cart_screen.dart';
import 'package:user/screens/login_screen.dart';
import 'package:user/screens/order_history_screen.dart';
import 'package:user/screens/search_screen.dart';
import 'package:user/screens/user_profile_screen.dart';
import 'package:user/widgets/my_bottom_navigation_bar.dart';

class HomeScreen extends BaseRoute {
  final int? screenId;
  const HomeScreen(
      {super.key,
      super.analytics,
      super.observer,
      super.routeName = 'HomeScreen',
      this.screenId});
  @override
  BaseRouteState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseRouteState<HomeScreen> {
  final CartController cartController = Get.put(CartController());
  final HomeController homeController = Get.put(HomeController());

  _HomeScreenState();

  @override
  Widget build(BuildContext context) {
    final List<Widget> homeScreenItems = [
      AppDrawerWrapperScreen(
        analytics: widget.analytics,
        observer: widget.observer,
      ),
      Container(),
      OrderHistoryScreen(
          analytics: widget.analytics, observer: widget.observer),
      UserProfileScreen(analytics: widget.analytics, observer: widget.observer),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic object) async {
        exitAppDialog();
      },
      child: GetBuilder<HomeController>(
        builder: (controller) {
          return Scaffold(
            body: IndexedStack(
              index: controller.tabIndex,
              children: homeScreenItems,
            ),
            bottomNavigationBar: MyBottomNavigationBar(
              onTap: (value) {
                if (value == 1)
                  return Get.to(() => SearchScreen(
                      analytics: widget.analytics, observer: widget.observer));
                if (value == 2 || value == 3 || value == 4) {
                  if (global.currentUser?.id == null) {
                    return Get.to(() => LoginScreen(
                        analytics: widget.analytics,
                        observer: widget.observer));
                  }
                }
                controller.changeTabIndex(value);
              },
            ), 
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFF68a039),
              child: const Icon(
                Icons.add_shopping_cart_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                if (global.currentUser?.id == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(
                          analytics: widget.analytics,
                          observer: widget.observer),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartScreen(
                          analytics: widget.analytics,
                          observer: widget.observer),
                    ),
                  );
                }
              },
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    debugPrint('uID ${global.currentUser!.id}');
    if (widget.screenId == 1) {
      homeController.changeTabIndex(4);
    } else if (widget.screenId == 2) {
      homeController.changeTabIndex(3);
    } else {
      homeController.changeTabIndex(0);
    }
    global.isNavigate = false;
  }
}
