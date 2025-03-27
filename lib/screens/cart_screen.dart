import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/screens/checkout_screen.dart';
import 'package:user/controllers/home_controller.dart';
import 'package:user/utils/navigation_utils.dart';
import 'package:user/widgets/cart_menu.dart';
import 'package:user/widgets/cart_screen_bottom_sheet.dart';

class CartScreen extends BaseRoute {
  const CartScreen(
      {super.key,
      super.analytics,
      super.observer,
      super.routeName = 'CartScreen'});

  @override
  BaseRouteState createState() => _CartScreenState();
}

class _CartScreenState extends BaseRouteState {
  final CartController cartController = Get.put(CartController());
  final HomeController homeController = Get.find();
  bool _isDataLoaded = false;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: false,
      child: GetBuilder<CartController>(
        init: cartController,
        builder: (value) => Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // ✅ AppBar Replacement with a Card
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        // ✅ Top Section: Back Button, Title, & Cart Count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: const Icon(Icons.keyboard_arrow_left),
                            ),
                            Text(
                              AppLocalizations.of(context)!.txt_cart,
                              style: textTheme.titleLarge,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            ),
                            if (global.nearStoreModel != null)
                              Text(
                                "${global.cartCount} ${AppLocalizations.of(context)!.lbl_items}",
                                style: textTheme.titleMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                          ],
                        ),

                        // ✅ Bottom Section: Address Selection
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Address Icon & Text
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.black, size: 25),
                                  const SizedBox(width: 7),
                                  Text(
                                    "No Address Selected",
                                    style: textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),

                              // "Select" Button
                              GestureDetector(
                                onTap: () {
                                  // Handle address selection
                                },
                                child: Text(
                                  "Select",
                                  style: textTheme.titleMedium!.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ Cart Body
                Expanded(
                  child: global.nearStoreModel != null
                      ? _isDataLoaded
                          ? cartController.cartItemsList != null &&
                                  cartController
                                      .cartItemsList!.cartList.isNotEmpty
                              ? RefreshIndicator(
                                  triggerMode:
                                      RefreshIndicatorTriggerMode.anywhere,
                                  onRefresh: () async {
                                    await _onRefresh();
                                  },
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          //  Cart Menu
                                          CartMenu(
                                              cartController: cartController),

                                          SizedBox(
                                            height: 15,
                                          ),
                                          //  Square-Shaped Food Cards ListView
                                          SizedBox(
                                            height: 110,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: 5,
                                              itemBuilder: (context, index) {
                                                double screenWidth =
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width;
                                                double cardWidth = screenWidth *
                                                    0.8; // ✅ Adaptive width

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  child: Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    elevation: 2,
                                                    child: Container(
                                                      width:
                                                          cardWidth, // ✅ Dynamically adjusted width
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          // ✅ Image (Fixed size)
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child:
                                                                Image.network(
                                                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRYhwMKoZ6vVlMlqNWhLZRG8utuQRMuQUWeVA&s",
                                                              width:
                                                                  70, // ✅ Adjusted width
                                                              height:
                                                                  70, // ✅ Adjusted height
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),

                                                          // ✅ Text Section
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .radio_button_checked_outlined,
                                                                    color: Colors
                                                                        .green,
                                                                    size: 13),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        "Triple Chocolate Brownie",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .titleSmall!
                                                                            .copyWith(fontWeight: FontWeight.bold),
                                                                        overflow:
                                                                            TextOverflow.ellipsis, // ✅ Prevents overflow
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      "₹ 119",
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .titleSmall!
                                                                          .copyWith(
                                                                              fontWeight: FontWeight.w600),
                                                                    ),
                                                                    // ✅ Add Button
                                                                    OutlinedButton
                                                                        .icon(
                                                                      onPressed:
                                                                          () {},
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .add,
                                                                          size:
                                                                              15,
                                                                          color:
                                                                              Colors.green), // ✅ Add Icon
                                                                      label:
                                                                          const Text(
                                                                        "Add",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.green),
                                                                      ),
                                                                      style: OutlinedButton
                                                                          .styleFrom(
                                                                        side: const BorderSide(
                                                                            color:
                                                                                Colors.green),
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                6,
                                                                            vertical:
                                                                                4),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        ),
                                                                        textStyle: Theme.of(context)
                                                                            .textTheme
                                                                            .bodySmall,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
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
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : _emptyCartWidget()
                          : _shimmer()
                      : Center(
                          child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(global.locationMessage!),
                        )),
                ),
              ],
            ),
          ),

          // ✅ Bottom Navigation Bar
          bottomNavigationBar: global.nearStoreModel != null
              ? _isDataLoaded
                  ? cartController.cartItemsList != null &&
                          cartController.cartItemsList!.cartList.isNotEmpty
                      ? GetBuilder<CartController>(
                          init: cartController,
                          builder: (value) => SafeArea(
                            child: CartScreenBottomSheet(
                              cartController: cartController,
                              onButtonPressed: () => Navigator.of(context).push(
                                NavigationUtils.createAnimatedRoute(
                                  1.0,
                                  CheckoutScreen(
                                    cartController: cartController,
                                    analytics: widget.analytics,
                                    observer: widget.observer,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox()
                  : _shimmer1()
              : const SizedBox(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCartList();
    debugPrint('TOKEN:${global.appDeviceId}');
  }

  _emptyCartWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Image.asset("assets/images/empty_cart.png", fit: BoxFit.contain),
          const SizedBox(height: 18),
          FilledButton(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size.fromWidth(350.0),
              minimumSize: const Size.fromHeight(55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              homeController.navigateToHome();
              Get.back();
            },
            child: Text(AppLocalizations.of(context)!.lbl_let_shop),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  _getCartList() async {
    try {
      await cartController.getCartList();
      _isDataLoaded = cartController.isDataLoaded.value;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - _getCartList(): $e");
    }
  }

  _onRefresh() async {
    try {
      _isDataLoaded = false;
      setState(() {});
      await _getCartList();
    } catch (e) {
      debugPrint("Exception - _onRefresh(): $e");
    }
  }

  _shimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 4,
        itemBuilder: (_, __) => const Card(),
      ),
    );
  }

  _shimmer1() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(3, (_) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Card(elevation: 0, child: SizedBox(height: 40, width: 100)),
          );
        }),
      ),
    );
  }
}
