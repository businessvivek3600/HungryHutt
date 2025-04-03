import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/address_model.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/screens/add_address_screen.dart';
import 'package:user/screens/checkout_screen.dart';
import 'package:user/controllers/home_controller.dart';
import 'package:user/utils/navigation_utils.dart';
import 'package:user/widgets/address_info_card.dart';
import 'package:user/widgets/cart_menu.dart';
import 'package:user/widgets/cart_screen_bottom_sheet.dart';
import 'package:user/widgets/toastfile.dart';

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
  var isExpanded = false;
  GlobalKey<ScaffoldState>? _scaffoldKey;
  Address? _selectedAddress = Address();
  List<Address> _addressList = [];
  bool _isLoading = true;

  Future<void> _fetchAddresses() async {
    var addressList = await apiHelper.getAddressList();
    if (addressList != null && addressList.isNotEmpty) {
      setState(() {
        _addressList = addressList;
        _selectedAddress = _addressList.first;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.9;
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
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Address Icon & Text in a Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.location_on, size: 25),
                                  ],
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    _selectedAddress?.fullAddress ??
                                        "No Address Selected",
                                    style: textTheme.titleMedium,
                                    softWrap:
                                        true, // Allow text to wrap to the next line
                                    maxLines: null, // No limit on lines
                                  ),
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    selectAddressBottomSheet(context);
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
                          ],
                        ),
                      ),
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

                                                  /// Bottom Text
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            OutlinedButton.icon(
                                                          onPressed: () {
                                                            // Add functionality here
                                                          },
                                                          style: OutlinedButton
                                                              .styleFrom(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        0),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                            ),
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300),
                                                          ),
                                                          icon: Icon(
                                                              Icons
                                                                  .edit_note_rounded,
                                                              color: Colors
                                                                  .grey[700],
                                                              size: 25),
                                                          label: TextField(
                                                            focusNode:
                                                                FocusNode(),
                                                            decoration:
                                                                const InputDecoration(
                                                              hintText:
                                                                  "Special Instruction",
                                                              hintStyle: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500), // Placeholder text
                                                              border: InputBorder
                                                                  .none, // Removes underline
                                                              contentPadding:
                                                                  EdgeInsets.all(
                                                                      8), // Adjust padding
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .green[100],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: const Icon(
                                                              Icons
                                                                  .add_alert_rounded,
                                                              color:
                                                                  Colors.green,
                                                              size: 25),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            //  Square-Shaped Food Cards ListView
                                            cartProductCard(),
                                            const SizedBox(height: 7),
                                            cartCoupon(cardWidth),

                                            const SizedBox(height: 5),
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

  Padding billingCard(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                                        "\u{20B9}${cartController.cartItemsList!.totalMrp!.toStringAsFixed(2)} ",
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "\u{20B9}${cartController.cartItemsList!.totalPrice!.toStringAsFixed(2)}",
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
                        Text(
                          "\u{20B9}${cartController.cartItemsList!.discountonmrp!.toStringAsFixed(2)} saved on the total!",
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        icon: Icon( isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey[700], size: 25)),
                  ],
                ),
                ///-----Hide or show this data on tap drop down
                 if (isExpanded) ...[
                const Divider(),
                _buildRow(
                    "Total Items",
                    cartController.cartItemsList!.totalItems!
                        .toStringAsFixed(2)),
                _buildRow("Delivery Fee | 5.9 kms", "\u{20AC}57.00"),
                _buildRow("Extra discount for you", "-\u{20AC}20.00",
                    color: Colors.green),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Delivery Tip",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                    Text("Add tip",
                        style: TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold)),
                  ],
                ),
                _buildRow("Platform Fee", "\u{20AC}9.00"),
                _buildRow("GST and Restaurant Charges",
                    "\u{20AC}${cartController.cartItemsList!.totalTax!.toStringAsFixed(2)}"),
                const Divider(),
                _buildRow("To Pay",
                    "\u{20AC}${cartController.cartItemsList!.totalPrice!.toStringAsFixed(2)}",
                    bold: true),
              ],
           ] ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {Color color = Colors.black, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }

  SizedBox cartCoupon(double cardWidth) {
    return SizedBox(
      width: cardWidth,
      // height: 100,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Discount icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.percent,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              // Offer details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'LPN75',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get Flat Discount of Rs.75 on Minimum Billing of Rs.399',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Row(
                      children: [
                        Text(
                          'View more offers',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Apply',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
                                  "₹ 119",
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
                                      size: 16, color: Colors.green),
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
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
                          _fetchAddresses(); // Refresh address list after adding
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

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
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
              showToast(result.message);
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



