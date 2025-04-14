import 'dart:convert';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/address_model.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/coupons_model.dart';
import 'package:user/screens/add_address_screen.dart';
import 'package:user/screens/checkout_screen.dart';
import 'package:user/controllers/home_controller.dart';
import 'package:user/utils/navigation_utils.dart';
import 'package:user/widgets/address_info_card.dart';
import 'package:user/screens/cart_coupon.dart';
import 'package:user/widgets/cart_menu.dart';
import 'package:user/widgets/cart_screen_bottom_sheet.dart';
import 'package:user/widgets/toastfile.dart';

import '../controllers/coupon_controller.dart';
import '../models/order_model.dart';
import '../widgets/tip_controller.dart';
import 'payment_screen.dart';

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
  final CouponController couponController =  Get.put(CouponController());
  final HomeController homeController = Get.find();
  late ConfettiController _confettiController;
  bool _isDataLoaded = false;
  var isExpanded = true;
  var isTip = false;
  dynamic  distance;
  GlobalKey<ScaffoldState>? _scaffoldKey;
  Address? _selectedAddress;
  List<Address> _addressList = [];
  Coupon? selectedCoupon;

  Future<void> _fetchAddresses() async {
    var addressList = await apiHelper.getAddressList();
    if (addressList != null && addressList.isNotEmpty) {
      setState(() {
        _addressList = addressList;
        _selectedAddress = _addressList.first;
      });
    }
    setState(() {});
  }
  Order? orderDetails;

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
  int? selectedTip;
  TextEditingController tipController = TextEditingController();
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double screenWidth = MediaQuery.of(context).size.width;
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
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                    child: Column(children: [
                      // ✅ Top Section: Back Button, Title, & Cart Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Back Button with Same Size as Location Icon
                          IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: const Icon(Icons.arrow_back_ios_outlined,
                                size: 20),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            AppLocalizations.of(context)!.txt_cart,
                            style: textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),

                      // ✅ Bottom Section: Address Selection
                      if (cartController.cartItemsList != null &&
                          cartController
                              .cartItemsList!.cartList.isNotEmpty &&_selectedAddress?.fullAddress != null && _selectedAddress!.fullAddress!.trim().isNotEmpty)
                        Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Address Icon & Text in a Row
                            GestureDetector(
                              onTap: () {
                                selectAddressBottomSheet(context);
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                   getAddressIcon(_selectedAddress?.type),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      _selectedAddress?.fullAddress?.trim().isNotEmpty == true
                                          ? _selectedAddress!.fullAddress! :
                                          "No Address Selected",
                                      style: textTheme.titleMedium,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap:
                                          true, // Allow text to wrap to the next line
                                      maxLines: null, // No limit on lines
                                    ),
                                  ),


                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ]),
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
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 6,
                                                      spreadRadius: 1,
                                                    ),
                                                  ]),
                                              child: Column(
                                                children: [
                                                  /// Cart Items
                                                  CartMenu(
                                                      cartController:
                                                          cartController),

                                                  /// Bottom Instruction Container
                                                  cartProductInstruction(),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            //  Square-Shaped Food Cards ListView
                                            // cartProductCard(),
                                            // const SizedBox(height: 7),
                                            savingCard(),
                                            isTip ?  TipContainer() : const SizedBox(),
                                            const SizedBox(height: 10),
                                            billingCard(context),
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
                          ))),
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
                              title:_selectedAddress?.fullAddress != null && _selectedAddress!.fullAddress!.trim().isNotEmpty ? "Checkout" :"Select Delivery Address" ,
                              cartController: cartController,
                              onButtonPressed: () {
                                if (_selectedAddress?.fullAddress != null && _selectedAddress!.fullAddress!.trim().isNotEmpty) {
                                  _makeOrder();
                               }
                                else {
                                 selectAddressBottomSheet(context);
                                }
                              },
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
  Icon getAddressIcon(String? addressType) {
    print("Address Type: $addressType");
    switch (addressType) {
      case 'Home':
        return const Icon(Icons.home, size: 25,);
      case 'Work':
        return const Icon(Icons.work, size: 25, );
      case 'Other':
        return const Icon(Icons.location_on, size: 25, );
      default:
        return const Icon(Icons.location_on, size: 25); // Default icon
    }
  }
  Row cartProductInstruction() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                // Add functionality here
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              icon: Icon(Icons.note_alt,
                  color: Colors.grey[700], size: 16),
              label: TextField(
                focusNode: FocusNode()
                ,
                decoration: const InputDecoration(

                  hintText: "Special Instruction",
                  hintStyle:
                      TextStyle(fontSize: 12), // Placeholder text
                  border: InputBorder.none, // Removes underline
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              homeController.navigateToHome();
              Get.back();
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child:const Center(child: Text("+ Add More ITems",style: TextStyle(fontSize: 14),)),
            ),
          ),
        ),
      ],
    );
  }

  Padding billingCard(BuildContext context) {
    final selectedCoupon = Get.find<CouponController>().selectedCoupon.value;

    final double subtotal = cartController.cartItemsList!.totalPrice ?? 0;
    final double restaurantCharge = cartController.cartItemsList!.restorantCharge ?? 0;
    final double deliveryCharge = cartController.cartItemsList!.deliveryCharge ?? 0;
    final double mrpDiscount = cartController.cartItemsList!.discountonmrp ?? 0;

    double couponDiscount = 0;
    if (selectedCoupon != null) {
      if (selectedCoupon.type == "amount") {
        couponDiscount = selectedCoupon.amount?.toDouble() ?? 0;
      } else if (selectedCoupon.type == "percent") {
        couponDiscount = subtotal * (selectedCoupon.amount! / 100);
      }
    }

    final double totalSaving = mrpDiscount + couponDiscount;

    /// ✅ Calculate the final total payable amount
    final double finalPayable = subtotal + restaurantCharge + deliveryCharge - couponDiscount;
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row (To Pay + Total)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.receipt_long, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text(
                              "To Pay",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                    "${global.appInfo!.currencySign}${finalPayable.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        /// total Checkout Amount---Here
                        Text(
                          "${global.appInfo!.currencySign}${totalSaving} saved on the total!",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      icon: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey[700],
                        size: 25,
                      ),
                    ),
                  ],
                ),

                // Expanded Breakdown Section
                if (isExpanded) ...[
                  const Divider(),
                  _buildRow(
                    "SubTotal",
                    "",
                    richValue: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${global.appInfo!.currencySign}${cartController.cartItemsList!.totalMrp!.toStringAsFixed(2)} ",
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: "${global.appInfo!.currencySign}${cartController.cartItemsList!.totalPrice!.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _buildRow("Total Items", cartController.cartItemsList!.totalItems.toString()),
                  _buildRow("Extra discount for you", "-${global.appInfo!.currencySign}${cartController.cartItemsList!.discountonmrp!.toStringAsFixed(2)}", color: Colors.green),
                  if (selectedCoupon != null)
                    _buildRow(
                      selectedCoupon.type == "amount"
                          ? "Coupon Discount"
                          : "${selectedCoupon.amount}% Coupon Discount",
                      selectedCoupon.type == "amount"
                          ? "-${global.appInfo!.currencySign}${selectedCoupon.amount}"
                          : "-${global.appInfo!.currencySign}${(cartController.cartItemsList!.totalPrice! * (selectedCoupon.amount! / 100)).toStringAsFixed(2)}",
                      color: Colors.green,
                    ),
                  ///Delivery Tip Section
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text(
                  //       "Delivery Tip",
                  //       style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  //     ),
                  //     selectedTip == null
                  //         ? InkWell(
                  //       onTap: () {
                  //         setState(() {
                  //           isTip = !isTip;
                  //         });
                  //       },
                  //       child: const Text(
                  //         "Add tip",
                  //         style: TextStyle(
                  //             color: Colors.orange, fontWeight: FontWeight.bold),
                  //       ),
                  //     )
                  //         : Text(
                  //       "${global.appInfo!.currencySign}${selectedTip.toString()}",
                  //       style: const TextStyle(
                  //           color: Colors.orange, fontWeight: FontWeight.bold),
                  //     ),
                  //   ],
                  // ),

                  // _buildRow("Platform Fee", "${global.appInfo!.currencySign}9.00"),
                  _buildRow(
                    "Restaurant Charges",
                    "${global.appInfo!.currencySign}${(cartController.cartItemsList?.restorantCharge ?? 0).toStringAsFixed(2)}",
                  ),
                  _buildRow("Delivery Fee ${distance != null ? "| ${distance!.toStringAsFixed(1)} KM" : ""}", "${global.appInfo!.currencySign}${(cartController.cartItemsList?.deliveryCharge ?? 0).toStringAsFixed(2)}"),
                  // ✅ Coupon Discount (if applied)


                  const Divider(),
                  /// total Checkout Amount---Here
                  _buildRow(
                    "To Pay",
                    "${global.appInfo!.currencySign}${finalPayable.toStringAsFixed(2)}",
                    bold: true,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRow(String label, String value,
      {Color color = Colors.black, bool bold = false, Widget? richValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 13, fontWeight: bold ? FontWeight.bold : FontWeight.w500),
          ),
          richValue ??
              Text(
                value,
                style: TextStyle(
                    color: color,
                    fontWeight: bold ? FontWeight.bold : FontWeight.w500),
              ),
        ],
      ),
    );
  }


  Widget savingCard() {
     // Make sure it's initialized before use

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SAVINGS CORNER",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            _buildListTile(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  builder: (context) => Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: CouponPage(
                      confettiController: _confettiController,
                      analytics: widget.analytics,
                      observer: widget.observer,
                      cartController: cartController,
                    ),
                  ),
                );
              },
              icon: MdiIcons.tagTextOutline,
              iconColor: Colors.orange,
              title: "Apply Coupon",
              trailing: const Icon(Icons.chevron_right, color: Colors.black54),
            ),

            Obx(() {
              final selectedCoupon = couponController.selectedCoupon.value;

              if (selectedCoupon == null) {
                return const SizedBox();
              }

              final isAmount = selectedCoupon.type == "amount";
              final discountValue = isAmount
                  ? "${global.appInfo!.currencySign}${selectedCoupon.amount.toString()}"
                  : "${selectedCoupon.amount.toString()}%";

              final maxDiscountText = selectedCoupon.maxDiscount != 0
                  ? " up to ${selectedCoupon.maxDiscount}"
                  : "";

              return Column(
                children: [
                  const Divider(),
                  _buildListTile(
                    icon: MdiIcons.ticketPercent,
                    iconColor: Colors.orange,
                    title: "$discountValue Flat off$maxDiscountText",
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.green, size: 18),
                        SizedBox(width: 4),
                        Text(
                          "Applied",
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }


  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
    );
  }

  SizedBox cartProductCard() {
    return SizedBox(
      height: 190,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Title
              Text(
                "COMPLETE YOUR MEAL",
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.grey),
              ),
              const SizedBox(height: 5),

              // ✅ Horizontal Scrollable Product List
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Number of products
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 90,
                      height: 90,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // ✅ Product Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRYhwMKoZ6vVlMlqNWhLZRG8utuQRMuQUWeVA&s",
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 5),

                                // ✅ Product Name (2 lines max)
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    "Triple Chocolate Brownie",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    maxLines: 2,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // ✅ Price
                                Text(
                                  "${global.appInfo!.currencySign}119",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),

                            // ✅ Floating Add Button (Top-Right of Image)
                            Positioned(
                              top: -2,
                              right: -1,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: Colors.green.shade400, width: 1),
                                  color: Colors.white,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    // Your add button logic
                                  },
                                  child: const Icon(Icons.add,
                                      size: 16, color: Color(0xFF68a039)),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Future<dynamic> selectAddressBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        Address? selectedAddress = _selectedAddress; // Store local selection

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Row with Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Choose a delivery address",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Selected Address Card
                  if (_selectedAddress?.fullAddress != null && _selectedAddress!.fullAddress!.trim().isNotEmpty)
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: _addressList.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: _addressList.length,
                              itemBuilder: (BuildContext ctx, int index) {
                                Address address = _addressList[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: AddressInfoCard(
                                    analytics: widget.analytics,
                                    observer: widget.observer,
                                    key: UniqueKey(),
                                    address: address,
                                    isSelected: selectedAddress == address,
                                    value: address,
                                    groupValue: selectedAddress,
                                    onChanged: (value) {
                                      setModalState(() {
                                        selectedAddress = value!;
                                      });

                                      // Update the main state when the user selects an address
                                      _selectAddressForCheckout(
                                        selectedAddressId: value?.addressId ?? 0,
                                        addressSelected: value,
                                      );

                                      setState(() {
                                        _selectedAddress = value;
                                      });

                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
                            )
                          : const Divider(color: Colors.grey),
                    ),
                  ),

                  // Add Address Button
                  GestureDetector(
                    onTap: () {
                      Get.to(() => AddAddressScreen(
                                Address(),
                                analytics: widget.analytics,
                                observer: widget.observer,
                                screenId: 0,
                              ))!
                          .then((value) {
                        setState(() {
                          _fetchAddresses();
                        });
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black),
                          ),
                          child: const Icon(Icons.add, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Add new Address",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  ///Tip Container-----


  /// Tip Container----
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _fetchAddresses();
   couponController.loadSavedCoupon();
    if (global.nearStoreModel!.storeOpeningTime != null &&
        global.nearStoreModel!.storeOpeningTime != '' &&
        global.nearStoreModel!.storeClosingTime != null &&
        global.nearStoreModel!.storeClosingTime != '') {
      // _openingTime = DateFormat('yyyy-MM-dd hh:mm a')
      //     .parse(global.nearStoreModel!.storeOpeningTime!.toUpperCase());
      // _closingTime = DateFormat('yyyy-MM-dd hh:mm a')
      //     .parse(global.nearStoreModel!.storeClosingTime!.toUpperCase());
    }

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
              backgroundColor: const Color(0xFF68a039),
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

  _selectAddressForCheckout(
      {int? selectedAddressId, Address? addressSelected, int? index}) async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        showOnlyLoaderDialog();
        await apiHelper
            .selectAddressForCheckout(selectedAddressId)
            .then((result) async {
          hideLoader();
          if (result != null) {
            if (result.status == "1") {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Theme
                    .of(context)
                    .colorScheme.primary,
                content: Text(
                  result.message,
                  textAlign: TextAlign.center,
                ),
                duration: const Duration(seconds: 1),
              ));
              setState(() {
                cartController.cartItemsList!.deliveryCharge =
                    double.tryParse(result.data['delivery_charge'].toString()) ?? 0.0;
                distance = double.tryParse(result.data['distance'].toString());

              });
              setState(() {
                _selectedAddress = addressSelected;
                global.userProfileController.addressList[index!].isSelected =
                    !global.userProfileController.addressList[index].isSelected;
              });
            } else {
              showToast(result.message);
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint(
          "Exception - checkout_screen.dart - _selectAddressForCheckout():$e");
    }
  }
  _makeOrder() async {
    try {
      if (_selectedAddress == null ||
          (_selectedAddress != null && _selectedAddress?.addressId == null)) {
        showToast(AppLocalizations.of(context)!.txt_select_deluvery_address);
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   backgroundColor: Theme
        //       .of(context)
        //       .colorScheme.primary,
        //   content: Text(
        //     '${AppLocalizations
        //         .of(context)
        //         .txt_select_deluvery_address}',
        //     textAlign: TextAlign.center,
        //   ),
        //   duration: Duration(seconds: 2),
        // ));
      }
      // else if (_selectedDate == null &&
      //     _membershipStatus?.status != 'running') {
      //   // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   //   backgroundColor: Theme
      //   //       .of(context)
      //   //       .colorScheme.primary,
      //   //   content: Text(
      //   //     '${AppLocalizations
      //   //         .of(context)
      //   //         .txt_select_date}',
      //   //     textAlign: TextAlign.center,
      //   //   ),
      //   //   duration: Duration(seconds: 2),
      //   // ));
      //   showToast(AppLocalizations.of(context)!.txt_select_date);
      // } else if (_selectedTimeSlot?.timeslot == null &&
      //     _membershipStatus?.status != 'running') {
      //   // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   //   backgroundColor: Theme
      //   //       .of(context)
      //   //       .colorScheme.primary,
      //   //   content: Text(
      //   //     '${AppLocalizations
      //   //         .of(context)
      //   //         .txt_select_time_slot}',
      //   //     textAlign: TextAlign.center,
      //   //   ),
      //   //   duration: Duration(seconds: 2),
      //   // ));
      //   showToast(AppLocalizations.of(context)!.txt_select_time_slot);
      // }
      else {
        // debugPrint(_selectedTimeSlot.timeslot);
        showOnlyLoaderDialog();
        bool isConnected = await br.checkConnectivity();
        if (isConnected) {
          await apiHelper
              .makeOrder(
            couponCode: couponController.selectedCoupon.value?.couponCode,
          )
              .then((result) async {
            if (result != null) {
              if (result.status == "1") {
                print("make Order REsult data -----${result.data}");
                orderDetails = result.data;
                hideLoader();
                Get.to(() => PaymentGatewayScreen(
                    analytics: widget.analytics,
                    observer: widget.observer,
                    screenId: 1,
                    totalAmount: orderDetails!.remPrice,
                    cartController: cartController,
                    order: orderDetails));
              } else {
                hideLoader();
                showToast(result.message);
                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //   backgroundColor: Theme
                //       .of(context)
                //       .colorScheme.primary,
                //   content: Text(
                //     result.message,
                //     textAlign: TextAlign.center,
                //   ),
                //   duration: Duration(seconds: 2),
                // ));
              }
            }
          });
        } else {
          showNetworkErrorSnackBar(_scaffoldKey);
        }
      }
    } catch (e) {
      debugPrint("Exception - checkout_screen.dart - _makeOrder():$e");
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
