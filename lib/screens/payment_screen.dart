import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:http/http.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/inputFormaters/card_month_input_formatter.dart';
import 'package:user/inputFormaters/card_number_input_formatter.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/card_model.dart';
import 'package:user/models/membership_model.dart';
import 'package:user/models/order_model.dart';
import 'package:user/screens/coupons_screen.dart';
import 'package:user/screens/home_screen.dart';
import 'package:user/screens/order_confirmation_screen.dart';
import 'package:user/screens/stripe_payment_screen.dart';


import 'package:user/utils/navigation_utils.dart';

import '../constants/app_constant.dart';
import '../controllers/home_controller.dart';
import '../widgets/common_payment_card.dart';
import '../widgets/product_shimmer.dart';

class PaymentGatewayScreen extends BaseRoute {
  final int? screenId;
  double? totalAmount;
  final MembershipModel? membershipModel;
  final Order? order;
  final CartController? cartController;

  PaymentGatewayScreen(
      {super.key,
      super.analytics,
      super.observer,
      super.routeName = 'PaymentGatewayScreen',
      this.screenId,
      this.totalAmount,
      this.membershipModel,
      this.order,
      this.cartController});
  @override
  BaseRouteState createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends BaseRouteState<PaymentGatewayScreen> {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  Map<String, dynamic>? paymentIntent;
  String? customerId;
  late Razorpay _razorpay;
  bool _isDataLoaded = false;
  var payPlugin = PaystackPlugin();
  final TextEditingController _cCardNumber = TextEditingController();
  final TextEditingController _cExpiry = TextEditingController();
  final TextEditingController _cCvv = TextEditingController();
  final TextEditingController _cName = TextEditingController();
  final HomeController homeController = Get.find();
  int? _month;
  int? _year;
  String? number;
  CardType? cardType;
  int _isWallet = 0;
  final _formKey = GlobalKey<FormState>();
  final bool _autovalidate = false;
  bool isLoading = false;

  _PaymentGatewayScreenState() : super();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle subHeadingStyle = textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic object) async {
        exitAppDialog();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF68a039),
          automaticallyImplyLeading: false,
          title: Text(
            AppLocalizations.of(context)!.lbl_payment_method,
            style: textTheme.titleLarge!.copyWith(color: Colors.white),
          ),
          actions: [
            InkWell(
                onTap: () {
                  homeController.navigateToHome();
                  Get.back();
                },
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ))
          ],
        ),
        body: _isDataLoaded
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding:
                          const EdgeInsets.only(left: 10, right: 10),
                      title: Text(
                        AppLocalizations.of(context)!.txt_pay_on_delivery,
                        style: subHeadingStyle,
                      ),
                    ),
                    commonPaymentCard(
                      imageUrl: 'assets/images/COD0.png',
                      title: 'Pay on Delivery (Cash/UPI)',
                      subtitle: 'Pay cash or ask for QR code',
                      onTap: () async {
                        if (widget.screenId == 1 && widget.order != null) {
                          showOnlyLoaderDialog();
                          await _orderCheckOut('success', 'COD', null, null);
                        }
                        setState(() {});
                      },
                    ),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.only(left: 10, right: 10),
                      title: Text(
                        "Credit/Debit Card",
                        style: subHeadingStyle,
                      ),
                    ),
                    commonPaymentCard(
                      imageUrl: 'assets/images/card.png',
                      title: 'Add New Card',
                      subtitle: 'Save and Pay via Cards',
                      onTap: () async {
                        if (global.paymentGateway?.razorpay?.razorpayStatus ==
                            'Yes') {
                          showOnlyLoaderDialog();
                          createOrderId();
                        } else if (global
                                .paymentGateway!.stripe?.stripeStatus ==
                            'Yes') {
                          // _cardDialog();
                         await makePayment();
                        } else if (global
                                .paymentGateway!.paystack?.paystackStatus ==
                            'Yes') {
                          _cardDialog(paymentCallId: 1);
                        } else {}
                      },
                    ),
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context)!.lbl_other_methods,
                        style: subHeadingStyle,
                      ),
                    ),

                    commonPaymentCard(
                      imageUrl: 'assets/images/payWallet.png',
                      title: 'Wallets',
                      subtitle: 'Pay with your wallet',
                      onTap: () async {
                        await _handlePaymentMethod(
                          method: 'COD',
                          walletStatus: 0,
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            NavigationUtils.createAnimatedRoute(
                              1.0,
                              CouponsScreen(
                                analytics: widget.analytics,
                                observer: widget.observer,
                                screenId: 1,
                                screenIdO: widget.screenId,
                                cartId: widget.order!.cartid,
                                cartController: widget.cartController,
                              ),
                            ),
                          ),
                          icon: Icon(
                            Icons.local_offer_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.txt_apply_coupon_code,
                            style: textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: widget.screenId! > 1 ? 0 : 50,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.txt_items_in_cart,
                            style: textTheme.bodyLarge,
                          ),
                          Text(
                            "${widget.cartController!.cartItemsList!.totalItems}",
                            style: textTheme.titleSmall,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.txt_total_price,
                            style: textTheme.bodyLarge,
                          ),
                          Text(
                            "${global.appInfo!.currencySign} ${widget.order!.totalProductsMrp!.toStringAsFixed(2)}",
                            style: textTheme.titleSmall,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.txt_discount_price,
                            style: textTheme.bodyLarge,
                          ),
                          Text(
                            "${global.appInfo!.currencySign} ${widget.order!.discountonmrp!.toStringAsFixed(2)}",
                            style: textTheme.titleSmall,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Discounted Price",
                            style: textTheme.bodyLarge,
                          ),
                          Text(
                            "${global.appInfo!.currencySign} ${widget.order!.priceWithoutDelivery!.toStringAsFixed(2)}",
                            style: textTheme.titleSmall,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.txt_coupon_discount,
                            style: textTheme.bodyLarge,
                          ),
                          Text(
                            widget.order!.couponDiscount != null &&
                                    widget.order!.couponDiscount! > 0
                                ? "- ${global.appInfo!.currencySign} ${widget.order!.couponDiscount!.toStringAsFixed(2)}"
                                : '- ${global.appInfo!.currencySign}0',
                            style: textTheme.titleSmall,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.txt_delivery_charges,
                            style: textTheme.bodyLarge,
                          ),
                          Text(
                            "${global.appInfo!.currencySign} ${widget.order!.deliveryCharge!.toStringAsFixed(2)}",
                            style: textTheme.titleSmall,
                          )
                        ],
                      ),
                    ),
                    widget.screenId! > 1
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.txt_tax,
                                  style: textTheme.bodyLarge,
                                ),
                                Text(
                                  "${global.appInfo!.currencySign} ${widget.order!.totalTaxPrice!.toStringAsFixed(2)}",
                                  style: textTheme.titleSmall,
                                )
                              ],
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 8, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.screenId == 3
                                ? AppLocalizations.of(context)!
                                    .lbl_wallet_recharge
                                : widget.screenId == 2
                                    ? AppLocalizations.of(context)!
                                        .tle_subscription
                                    : AppLocalizations.of(context)!
                                        .lbl_total_amount,
                            style: textTheme.bodyLarge,
                          ),
                          Text(
                            "${global.appInfo!.currencySign} ${widget.totalAmount}",
                            style: textTheme.titleSmall,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              )
            : productShimmer(),
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFF68a039),
          child: SizedBox(
              height: 60,
              width: double.infinity,
              child: ListTile(
                title: RichText(
                  text: TextSpan(
                    style: Theme.of(context).primaryTextTheme.headlineSmall,
                    children: [
                      TextSpan(
                          text: AppLocalizations.of(context)!.lbl_total_amount),
                      TextSpan(
                        text:
                            ' ${global.appInfo!.currencySign} ${widget.totalAmount}',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }

  Future<void> _handlePaymentMethod({
    required String method,
    required int walletStatus,
    bool isFromRadio = false,
  }) async {
    _isWallet = walletStatus;

    if (_isWallet == 1) {
      final walletBalance =
          global.userProfileController.currentUser?.wallet ?? 0;
      if (walletBalance >= widget.totalAmount!) {
        if (widget.screenId == 2 && widget.membershipModel != null) {
          showOnlyLoaderDialog();
          await _buyMemberShip(method, method, null);
        } else if (widget.screenId == 1 && widget.order != null) {
          showOnlyLoaderDialog();
          await _orderCheckOut('success', method, null, null);
        }
      } else {
        widget.totalAmount = widget.totalAmount! - walletBalance;
      }
    } else {
      widget.totalAmount = widget.order!.remPrice;
    }

    if (!isFromRadio) setState(() {});
  }



  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  void createOrderId() async {
    var trasnId = 'order_trn_${DateTime.now().millisecond}';
    var authn =
        'Basic ${base64Encode(utf8.encode('${global.paymentGateway!.razorpay!.razorpayKey}:${global.paymentGateway!.razorpay!.razorpaySecret}'))}';
    Map<String, String> headers = {
      'Authorization': authn,
      'Content-Type': 'application/json'
    };

    var body = {
      'amount': _amountInPaise(widget.totalAmount!),
      'currency': 'INR',
      'receipt': trasnId,
      'payment_capture': true,
    };

    //
    Client()
        .post(global.orderApiRazorpay, body: jsonEncode(body), headers: headers)
        .then((value) {
      // debugPrint('orderid data - ${value.body}');
      var jsData = jsonDecode(value.body);
      Timer(const Duration(seconds: 1), () async {
        openCheckout(jsData['id']);
      });
    }).catchError((e) {
      debugPrint(e);
      hideLoader();
    });
  }

  void openCheckout(dynamic orderId) async {
    Map<String, Object?> options;

    options = {
      'key': global.paymentGateway!.razorpay!.razorpayKey,
      'amount': _amountInPaise(widget.totalAmount!),
      'name': "${global.currentUser!.name}",
      'prefill': {
        'contact': global.currentUser!.userPhone,
        'email': global.currentUser!.email
      },
      'currency': 'INR'
    };

    try {
      hideLoader();
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void payStack(String? key) async {
    try {
      payPlugin
          .initialize(
              publicKey: global.paymentGateway!.paystack!.paystackPublicKey!)
          .then((value) {
        _startAfreshCharge(widget.totalAmount!.toInt() * 100);
      }).catchError((e) {
        debugPrint(
            "Exception - internal error - paymentGatewaysScreen.dart - payStatck(): $e");
      });
    } catch (e) {
      debugPrint("Exception - paymentGatewaysScreen.dart - payStatck(): $e");
    }
  }

  // _orderCheckOut(String paymentStatus, String paymentMethod, String? paymentId,
  //     String? paymentGateway) async {
  //   try {
  //     bool isConnected = await br.checkConnectivity();
  //     if (isConnected) {
  //       await apiHelper
  //           .checkout(
  //               cartId: widget.order!.cartid,
  //               paymentStatus: paymentStatus,
  //               paymentMethod: paymentMethod,
  //               wallet: _isWallet == 1 ? 'yes' : 'no',
  //               paymentId: paymentId,
  //               paymentGateway: paymentGateway)
  //           .then((result) async {
  //         if (result != null) {
  //           if (result.status == "1") {
  //             _getAppInfo();
  //             // if (_isWallet == 1) {
  //             //   if (global.userProfileController.currentUser.wallet >= totalAmount) {
  //             //     global.userProfileController.currentUser.wallet = global.userProfileController.currentUser.wallet - totalAmount;
  //             //   } else {
  //             //     global.userProfileController.currentUser.wallet = 0;
  //             //   }
  //             // }
  //             // hideLoader();
  //             // Get.to(() => OrderConfirmationScreen(
  //             //       a: widget.analytics,
  //             //       o: widget.observer,
  //             //       order: order,
  //             //       screenId: 1,
  //             //     ));
  //           } else {
  //             hideLoader();
  //             showSnackBar(
  //                 key: _scaffoldKey, snackBarMessage: '${result.message}');
  //           }
  //         } else {
  //           hideLoader();
  //           showSnackBar(
  //               key: _scaffoldKey,
  //               snackBarMessage:
  //                   'Something went wrong. Please try again later.');
  //         }
  //       });
  //     } else {
  //       showNetworkErrorSnackBar(_scaffoldKey);
  //     }
  //   } catch (e) {
  //     debugPrint("Exception - paymentGatewayScreen.dart - _orderCheckOut():$e");
  //   }
  // }
  _orderCheckOut(String paymentStatus, String paymentMethod, String? paymentId,
      String? paymentGateway) async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        print("checkout hit");
        await apiHelper
            .checkout(
                cartId: widget.order!.cartid,
                paymentStatus: paymentStatus,
                paymentMethod: paymentMethod,
                wallet: _isWallet == 1 ? 'yes' : 'no',
                paymentId: paymentId,
                paymentGateway: paymentGateway)
            .then((result) async {
          if (result != null) {
            if (result.status == "1") {
              // Defer state-modifying actions until after the build phase
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _getAppInfo();
                // Additional state-modifying actions can be placed here
              });
            } else {
              hideLoader();
              showSnackBar(
                  key: _scaffoldKey, snackBarMessage: '${result.message}');
            }
          } else {
            hideLoader();
            showSnackBar(
                key: _scaffoldKey,
                snackBarMessage:
                    'Something went wrong. Please try again later.');
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - paymentGatewayScreen.dart - _orderCheckOut():$e");
    }
  }

  _getAppInfo() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        print("get app info ");
        await apiHelper.getAppInfo().then((result) async {
          if (result != null) {
            if (result.status == "1") {
              global.appInfo = result.data;
              global.userProfileController.currentUser!.wallet =
                  global.appInfo!.userwallet;
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Exception - splash_screen.dart - _getAppInfo():$e");
    } finally {
      hideLoader();
      Get.to(() => OrderConfirmationScreen(
            analytics: widget.analytics,
            observer: widget.observer,
            order: widget.order,
            screenId: 1,
          ));
    }
  }

  stripe({int? amount, required CardModel card, String? currency}) async {
    try {
      // ✅ Step 1: Create Customer
      Map<String, dynamic>? customers =
          await StripeService.createCustomer(email: global.currentUser!.email);
      debugPrint("Customer Created: $customers");

      if (customers == null || !customers.containsKey("id")) {
        debugPrint("Error: Customer ID is null");
        return;
      }

      // ✅ Step 2: Create Payment Method
      var paymentMethodsObject = await StripeService.createPaymentMethod(card);
      debugPrint("Payment Method Created: $paymentMethodsObject");

      if (paymentMethodsObject == null ||
          !paymentMethodsObject.containsKey("id")) {
        debugPrint("Error: Payment Method ID is null");
        return;
      }

      // ✅ Step 3: Create Payment Intent
      var paymentIntent = await StripeService.createPaymentIntent(
          amount, currency,
          customerId: customers["id"]);
      debugPrint("Payment Intent Created: $paymentIntent");

      if (paymentIntent == null || !paymentIntent.containsKey("id")) {
        debugPrint("Error: Payment Intent ID is null");
        return;
      }

      // ✅ Step 4: Confirm Payment Intent
      var response = await StripeService.confirmPaymentIntent(
          paymentIntent["id"], paymentMethodsObject["id"]);
      debugPrint("Payment Confirmed: $response");

      if (response?["status"] == 'succeeded') {
        debugPrint("✅ Payment Successful: ${response?["id"]}");
        if (widget.screenId == 2 && widget.membershipModel != null) {
          await _buyMemberShip('success', 'stripe', '${response?["id"]}');
        } else if (widget.screenId == 1 && widget.order != null) {
          await _orderCheckOut(
              'success', 'stripe', '${response?["id"]}', 'stripe');
        } else if (widget.screenId == 3) {
          await _rechargeWallet('success', 'stripe', '${response?["id"]}');
        }
      } else {
        debugPrint("❌ Payment Failed: $response");
        bool isConnected = await br.checkConnectivity();
        if (isConnected) {
          if (widget.screenId == 2 && widget.membershipModel != null) {
            await _buyMemberShip('failed', 'stripe', null);
          } else if (widget.screenId == 1 && widget.order != null) {
            await _orderCheckOut('failed', 'stripe', null, 'stripe');
          } else if (widget.screenId == 3) {
            await _rechargeWallet('failed', 'stripe', null);
          }
          _tryAgainDialog(stripe);
          setState(() {});
        } else {
          showNetworkErrorSnackBar(_scaffoldKey);
        }
      }
    } on PlatformException catch (err) {
      debugPrint('Platform Exception: ${err.toString()}');
    } catch (err) {
      debugPrint('Exception: ${err.toString()}');
      if (!mounted) return;
      return StripeTransactionResponse(
          message:
              '${AppLocalizations.of(context)!.lbl_transaction_failed}: ${err.toString()}',
          success: false);
    }
  }

  String _amountInPaise(double amount) {
    try {
      double x = amount * 100;
      return x.toString();
    } catch (e) {
      debugPrint(
          "Exception - paymentGatewaysScreen.dart - _amountInPaise():$e");
      return '0';
    }
  }

  _buyMemberShip(
      String buyStatus, String paymentGateway, String? transactionId) async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        print("buy membership is connected");
        await apiHelper
            .buyMembership(buyStatus, paymentGateway, transactionId,
                widget.membershipModel!.planId)
            .then((result) async {
          if (result != null) {
            if (result.status == "1") {
              if (_isWallet == 1) {
                if (global.userProfileController.currentUser!.wallet! >=
                    widget.totalAmount!) {
                  global.userProfileController.currentUser!.wallet =
                      global.userProfileController.currentUser!.wallet! -
                          widget.totalAmount!;
                } else {
                  global.userProfileController.currentUser!.wallet = 0;
                }
              }
              await global.userProfileController.getMyProfile();
              hideLoader();
              Get.to(() => OrderConfirmationScreen(
                    analytics: widget.analytics,
                    observer: widget.observer,
                    order: widget.order,
                    screenId: 2,
                  ));
            } else if (result.status == '5') {
              await global.userProfileController.getMyProfile();
              hideLoader();
              Get.to(() => OrderConfirmationScreen(
                    analytics: widget.analytics,
                    observer: widget.observer,
                    order: widget.order,
                    screenId: 2,
                    status: 5,
                  ));
            } else {
              hideLoader();
              showSnackBar(
                  key: _scaffoldKey, snackBarMessage: '${result.message}');
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - paymentGatewayScreen.dart - _buyMemberShip():$e");
    }
  }

  _rechargeWallet(
      String rechargeStatus, String paymentGateway, String? paymentId) async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        print("recharge wallet is connected");
        await apiHelper
            .rechargeWallet(
                rechargeStatus, widget.totalAmount!, paymentId, paymentGateway)
            .then((result) async {
          if (result != null) {
            if (result.status == "1") {
              global.userProfileController.currentUser!.wallet =
                  global.userProfileController.currentUser!.wallet! +
                      widget.totalAmount!;
              hideLoader();
              Get.to(() => OrderConfirmationScreen(
                    analytics: widget.analytics,
                    observer: widget.observer,
                    order: widget.order,
                    screenId: 3,
                  ));
            } else {
              hideLoader();
              showSnackBar(
                  key: _scaffoldKey, snackBarMessage: '${result.message}');
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint(
          "Exception - paymentGatewayScreen.dart - _rechargeWallet():$e");
    }
  }

  _cardDialog({int? paymentCallId}) {
    showModalBottomSheet(
        context: context,
        useSafeArea: true,
        isScrollControlled:
            true, // Ensures the bottom sheet resizes properly when the keyboard appears
        backgroundColor:
            Colors.white, // Makes the bottom sheet background transparent
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20.0),
                  ),
                ),
                child: Padding(
                    padding: MediaQuery.of(context)
                        .viewInsets, // Adjusts for the keyboard
                    child: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Title
                                  Text(
                                    AppLocalizations.of(context)!
                                        .lbl_card_Details,
                                    style: Theme.of(context)
                                        .appBarTheme
                                        .titleTextStyle,
                                  ),
                                  const SizedBox(height: 15),
                                  Form(
                                    key: _formKey,
                                    autovalidateMode: _autovalidate
                                        ? AutovalidateMode.always
                                        : AutovalidateMode.disabled,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 15, top: 15),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                            controller: _cCardNumber,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9]')),
                                              LengthLimitingTextInputFormatter(
                                                  16),
                                              CardNumberInputFormatter(),
                                            ],
                                            textInputAction:
                                                TextInputAction.next,
                                            decoration: InputDecoration(
                                              fillColor: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 10,
                                                      left: 5,
                                                      right: 5),
                                              hintText:
                                                  AppLocalizations.of(context)!
                                                      .lbl_card_number,
                                              prefixIcon: const Icon(
                                                Icons.credit_card,
                                              ),
                                            ),
                                            textCapitalization:
                                                TextCapitalization.none,
                                            keyboardType: TextInputType.number,
                                            onSaved: (String? value) {
                                              number =
                                                  br.getCleanedNumber(value!);
                                            },
                                            // ignore: missing_return
                                            validator: (input) {
                                              if (input!.isEmpty) {
                                                return AppLocalizations.of(
                                                        context)!
                                                    .txt_enter_your_card_number;
                                              }

                                              input =
                                                  br.getCleanedNumber(input);

                                              if (input.length < 8) {
                                                return AppLocalizations.of(
                                                        context)!
                                                    .txt_enter_valid_card_number;
                                              }

                                              int sum = 0;
                                              int length = input.length;
                                              for (var i = 0; i < length; i++) {
                                                // get digits in reverse order
                                                int digit = int.parse(
                                                    input[length - i - 1]);

                                                // every 2nd number multiply with 2
                                                if (i % 2 == 1) {
                                                  digit *= 2;
                                                }
                                                sum += digit > 9
                                                    ? (digit - 9)
                                                    : digit;
                                              }

                                              if (sum % 10 == 0) {
                                                return null;
                                              }

                                              return AppLocalizations.of(
                                                      context)!
                                                  .txt_enter_valid_card_number;
                                            },
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(
                                                            RegExp(r'[0-9]')),
                                                    LengthLimitingTextInputFormatter(
                                                        4),
                                                    CardMonthInputFormatter(),
                                                  ],
                                                  controller: _cExpiry,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  decoration: InputDecoration(
                                                    fillColor: Theme.of(context)
                                                        .scaffoldBackgroundColor,
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            left: 5,
                                                            right: 5),
                                                    prefixIcon: const Icon(
                                                      Icons.date_range,
                                                    ),
                                                    hintText:
                                                        "Valid Through (MM/YY)",
                                                  ),
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onFieldSubmitted: (value) {
                                                    List<int> expiryDate =
                                                        br.getExpiryDate(value);
                                                    _month = expiryDate[0];
                                                    _year = expiryDate[1];
                                                  },
                                                  onEditingComplete: () {
                                                    List<int> expiryDate =
                                                        br.getExpiryDate(
                                                            _cExpiry.text);
                                                    _month = expiryDate[0];
                                                    _year = expiryDate[1];
                                                  },
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return AppLocalizations
                                                              .of(context)!
                                                          .txt_enter_your_expiry_date;
                                                    }

                                                    int year;
                                                    int month;
                                                    // The value contains a forward slash if the month and year has been
                                                    // entered.
                                                    if (value.contains(
                                                        RegExp(r'(/)'))) {
                                                      var split = value.split(
                                                          RegExp(r'(/)'));
                                                      // The value before the slash is the month while the value to right of
                                                      // it is the year.
                                                      month =
                                                          int.parse(split[0]);
                                                      year =
                                                          int.parse(split[1]);
                                                    } else {
                                                      // Only the month was entered
                                                      month = int.parse(
                                                          value.substring(0,
                                                              (value.length)));
                                                      year =
                                                          -1; // Lets use an invalid year intentionally
                                                    }

                                                    if ((month < 1) ||
                                                        (month > 12)) {
                                                      // A valid month is between 1 (January) and 12 (December)
                                                      return AppLocalizations
                                                              .of(context)!
                                                          .txt_expiry_month_is_invalid;
                                                    }

                                                    var fourDigitsYear =
                                                        br.convertYearTo4Digits(
                                                            year);
                                                    if ((fourDigitsYear < 1) ||
                                                        (fourDigitsYear >
                                                            2099)) {
                                                      // We are assuming a valid should be between 1 and 2099.
                                                      // Note that, it's valid doesn't mean that it has not expired.
                                                      return AppLocalizations
                                                              .of(context)!
                                                          .txt_expiry_year_is_invalid;
                                                    }

                                                    if (!br.hasDateExpired(
                                                        month, year)) {
                                                      return AppLocalizations
                                                              .of(context)!
                                                          .txt_card_has_expired;
                                                    }

                                                    if (_month == null &&
                                                        _year == null) {
                                                      _month = month;
                                                      _year = year;
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                child: TextFormField(
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(
                                                            RegExp(r'[0-9]')),
                                                    LengthLimitingTextInputFormatter(
                                                        3),
                                                  ],
                                                  controller: _cCvv,
                                                  obscureText: true,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  decoration: InputDecoration(
                                                    fillColor: Theme.of(context)
                                                        .scaffoldBackgroundColor,
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            left: 5,
                                                            right: 5),
                                                    prefixIcon: Icon(
                                                      MdiIcons.creditCard,
                                                    ),
                                                    hintText:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .lbl_cvv,
                                                  ),
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return AppLocalizations
                                                              .of(context)!
                                                          .lbl_enter_cvv;
                                                    } else if (value.length <
                                                            3 ||
                                                        value.length > 4) {
                                                      return AppLocalizations
                                                              .of(context)!
                                                          .txt_cvv_is_invalid;
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          TextFormField(
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                            controller: _cName,
                                            textInputAction:
                                                TextInputAction.next,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp('[a-zA-Z ]')),
                                            ],
                                            decoration: InputDecoration(
                                              fillColor: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 10,
                                                      left: 5,
                                                      right: 5),
                                              prefixIcon: const Icon(
                                                Icons.person,
                                              ),
                                              hintText:
                                                  AppLocalizations.of(context)!
                                                      .txt_card_holder_name,
                                            ),
                                            textCapitalization:
                                                TextCapitalization.words,
                                            keyboardType: TextInputType.text,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return null;
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            setState(() {});
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .btn_close)),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: ElevatedButton(
                                            onPressed: () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                Navigator.of(context).pop();

                                                _save(paymentCallId);
                                              }
                                            },
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .lbl_pay)),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 40,
                                  ),
                                ])))));
          });
        });
  }

  _chargeCard(Charge charge) async {
    try {
      payPlugin.chargeCard(context, charge: charge).then((value) async {
        if (value.status && value.message == "Success") {
          bool isConnected = await br.checkConnectivity();
          if (isConnected) {
            if (widget.screenId == 2 && widget.membershipModel != null) {
              await _buyMemberShip('success', 'paystack', null);
            } else if (widget.screenId == 1 && widget.order != null) {
              await _orderCheckOut('success', 'paystack', null, 'paystack');
            } else if (widget.screenId == 3) {
              await _rechargeWallet('sucess', 'paystack', null);
            }

            setState(() {});
          } else {
            showNetworkErrorSnackBar(_scaffoldKey);
          }
        } else {
          bool isConnected = await br.checkConnectivity();
          if (isConnected) {
            if (widget.screenId == 2 && widget.membershipModel != null) {
              await _buyMemberShip('failed', 'paystack', null);
            } else if (widget.screenId == 1 && widget.order != null) {
              await _orderCheckOut('failed', 'paystack', null, 'paystack');
            } else if (widget.screenId == 3) {
              await _rechargeWallet('failed', 'paystack', null);
            }
            _tryAgainDialog(payStack);
            setState(() {});
          } else {
            showNetworkErrorSnackBar(_scaffoldKey);
          }
        }
      }).catchError((e) {
        debugPrint(
            "Exception - inner error - paymentGatewaysScreen.dart - paystack - _chargeCard(): $e");
      });
    } catch (e) {
      debugPrint("Exception - paymentGatewaysScreen.dart - _chargeCard(): $e");
    }
  }

  PaymentCard _getCardFromUI() {
    return PaymentCard(
      number: _cCardNumber.text,
      cvc: _cCvv.text,
      expiryMonth: _month,
      expiryYear: _year,
    );
  }

  Future _getPaymentGateways() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        print("getPaymentGateways is connected");
        await apiHelper.getPaymentGateways().then((result) async {
          debugPrint("API Response: $result");
          if (result != null) {
            if (result.status == "1") {
              global.paymentGateway = result.data;
            } else {
              showSnackBar(
                  key: _scaffoldKey,
                  snackBarMessage: result.message.toString());
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint(
          "Exception - paymentGatewaysScreen.dart.dart - _getPaymentGateways():$e");
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    try {
      debugPrint("_handlePaymentError ${response.code} ${response.message}");
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        showOnlyLoaderDialog();

        showOnlyLoaderDialog();
        if (widget.screenId == 2 && widget.membershipModel != null) {
          await _buyMemberShip('failed', 'razorpay', null);
        } else if (widget.screenId == 1 && widget.order != null) {
          await _orderCheckOut('failed', 'razorpay', null, 'razorpay');
        } else if (widget.screenId == 3) {
          await _rechargeWallet('failed', 'razorpay', null);
        }

        hideLoader();
        _tryAgainDialog(openCheckout);
        setState(() {});
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
      if (!mounted) return;
      showSnackBar(
          key: _scaffoldKey,
          snackBarMessage:
              AppLocalizations.of(context)!.lbl_transaction_failed);
    } catch (e) {
      debugPrint(
          "Exception - paymentGatewaysScreen.dart -  _handlePaymentError$e");
    }
  }

  _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      debugPrint(
          "response   -  _handlePaymentSuccess   ${response.orderId} ${response.paymentId}");
      if (response.paymentId != null) {
        showOnlyLoaderDialog();

        if (widget.screenId == 2 && widget.membershipModel != null) {
          await _buyMemberShip('success', 'razorpay', '${response.paymentId}');
        } else if (widget.screenId == 1 && widget.order != null) {
          await _orderCheckOut(
              'success', 'razorpay', '${response.paymentId}', 'razorpay');
        } else if (widget.screenId == 3) {
          await _rechargeWallet('success', 'razorpay', '${response.paymentId}');
        }
      }
    } catch (e) {
      debugPrint(
          "Exception - paymentGetwaysScreen.dart- _handlePaymentSuccess():$e");
    }
  }

  _init() async {
    try {
      await _getPaymentGateways();
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      if (widget.totalAmount != null) {
        if (widget.screenId == 2 && widget.membershipModel != null) {
          widget.totalAmount = widget.membershipModel!.price;
        }
      }
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - paymentGatewaysScreen.dart.dart - _init():$e");
    }
  }



  Future<void> _save(int? callId) async {
    try {
      // Log the input parameter
      debugPrint('Called _save with callId: $callId');

      // Log the current state of text controllers
      debugPrint('Card Number: ${_cCardNumber.text.trim()}');
      debugPrint('Expiry Date: ${_cExpiry.text.trim()}');
      debugPrint('CVV: ${_cCvv.text.trim()}');
      debugPrint('Cardholder Name: ${_cName.text.trim()}');

      if (_cCardNumber.text.trim().isNotEmpty &&
          _cExpiry.text.trim().isNotEmpty &&
          _cCvv.text.trim().isNotEmpty &&
          _cName.text.trim().isNotEmpty) {
        if (_formKey.currentState!.validate()) {
          bool isConnected = await br.checkConnectivity();
          debugPrint('Network connectivity status: $isConnected');

          if (isConnected) {
            showOnlyLoaderDialog();
            CardModel stripeCard = CardModel(
              number: _cCardNumber.text,
              name: _cName.text.trim(),
              expiryMonth: _month,
              expiryYear: _year,
              cvv: _cCvv.text,
            );

            // Log the card details being used (excluding sensitive information)
            debugPrint(
                'Processing payment with card ending in: ${_cCardNumber.text.trim().substring(_cCardNumber.text.trim().length - 4)}');

            if (callId == 1) {
              debugPrint('Using PayStack for payment processing.');
              payStack(global.paymentGateway!.paystack!.paystackSeckeyKey);
            } else {
              debugPrint('Using Stripe for payment processing.');
              await stripe(
                card: stripeCard,
                amount: widget.totalAmount!.toInt() * 100,
                currency: '${global.appInfo!.paymentCurrency}',
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Exception in _save(): $e");
    }
  }

  _startAfreshCharge(int price) async {
    try {
      Charge charge = Charge()
        ..amount = price
        ..email = '${global.currentUser!.email}'
        ..currency = '${global.appInfo!.paymentCurrency}'
        ..card = _getCardFromUI()
        ..reference = _getReference();

      _chargeCard(charge);
    } catch (e) {
      debugPrint(
          "Exception - paymentGatewaysScreen.dart - _startAfreshCharge(): $e");
    }
  }

  _tryAgainDialog(Function onClickAction) {
    try {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return Theme(
              data: ThemeData(dialogBackgroundColor: Colors.white),
              child: CupertinoAlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.lbl_transaction_failed,
                ),
                content: Text(
                  AppLocalizations.of(context)!.txt_please_try_again,
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(
                      AppLocalizations.of(context)!.lbl_cancel,
                      style: const TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(AppLocalizations.of(context)!.lbl_try_again),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      showOnlyLoaderDialog();
                      onClickAction();

                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          });
    } catch (e) {
      debugPrint(
          'Exception - paymentGatewaysScreen.dart - _tryAgainDialog(): $e');
    }
  }
  ///Stripe Payment_________

  Future<void> makePayment() async {
    try {
      log('checkout hit');

      // 1. Create Customer
      customerId = await createCustomer(global.currentUser!.email.toString());
      if (customerId == null) {
        log('❌ Failed to create customer');
        return;
      }

      // 2. Create Payment Intent
      int amountInCents = (widget.totalAmount! * 100).round();
      paymentIntent = await createPaymentIntent(
        amountInCents.toString(),
        '${global.appInfo!.paymentCurrency}',
        customerId!,
      );

      if (paymentIntent == null) {
        log('❌ Failed to create payment intent');
        return;
      }

      final paymentIntentId = paymentIntent!['id'];

      // 3. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: global.currentUser!.name,
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          customerId: customerId,
          customerEphemeralKeySecret: paymentIntent!['ephemeralKey'],
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'UK',
            currencyCode: 'EUR',
            testEnv: true,
          ),
        ),
      );

      // 4. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();
      log('✅ Payment completed successfully. PaymentIntent ID: $paymentIntentId');
///-------------NOTES --YAHA PER ERROR HAI------
      // 5. Fetch updated PaymentIntent details
      final updatedIntent = await getPaymentIntentDetails(paymentIntentId);

      if (updatedIntent != null && updatedIntent['status'] == 'succeeded') {
        log("✅ Payment Status: ${updatedIntent["status"]}");
        log("✅ PaymentMethod: ${updatedIntent["payment_method"]}");

        final paymentId = updatedIntent["id"];

        // Handle different flows
        if (widget.screenId == 2 && widget.membershipModel != null) {
          await _buyMemberShip('success', 'stripe', paymentId);
        } else if (widget.screenId == 1 && widget.order != null) {
          await _orderCheckOut('success', 'stripe', paymentId, 'stripe');
        } else if (widget.screenId == 3) {
          await _rechargeWallet('success', 'stripe', paymentId);
        }
      } else {
        log("❌ Payment failed or not succeeded.");
        await _handleFailureFlow();
      }
    } catch (e) {
      log('❌ Stripe Error: $e');
      await _handleFailureFlow();
    }
  }

  Future<void> _handleFailureFlow() async {
    bool isConnected = await br.checkConnectivity();
    if (isConnected) {
      if (widget.screenId == 2 && widget.membershipModel != null) {
        await _buyMemberShip('failed', 'stripe', null);
      } else if (widget.screenId == 1 && widget.order != null) {
        await _orderCheckOut('failed', 'stripe', null, 'stripe');
      } else if (widget.screenId == 3) {
        await _rechargeWallet('failed', 'stripe', null);
      }
      _tryAgainDialog(stripe);
      setState(() {});
    } else {
      showNetworkErrorSnackBar(_scaffoldKey);
    }
  }



  Future<String?> createCustomer(String email) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        body: {'email': email},
        headers: {
          'Authorization': 'Bearer ${AppConst.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        final customer = jsonDecode(response.body);
        return customer['id'];
      } else {
        log('Failed to create customer: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error creating customer: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(
      String amount, String currency, String customerId) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: {
          'amount': amount.toString(),
          'currency': currency,
          'customer': customerId,
          'payment_method_types[]': 'card',
        },
        headers: {
          'Authorization': 'Bearer ${AppConst.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        final paymentIntent = jsonDecode(response.body);
        // Create an ephemeral key for the customer
        final ephemeralKey = await createEphemeralKey(customerId);
        if (ephemeralKey != null) {
          paymentIntent['ephemeralKey'] = ephemeralKey;
          return paymentIntent;
        } else {
          log('Failed to create ephemeral key');
          return null;
        }
      } else {
        log('Failed to create payment intent: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error creating payment intent: $e');
      return null;
    }
  }

  Future<String?> createEphemeralKey(String customerId) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/ephemeral_keys'),
        body: {'customer': customerId},
        headers: {
          'Authorization': 'Bearer ${AppConst.stripeSecretKey}',
          'Stripe-Version': '2020-08-27',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        final ephemeralKey = jsonDecode(response.body);
        return ephemeralKey['secret'];
      } else {
        log('Failed to create ephemeral key: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error creating ephemeral key: $e');
      return null;
    }
  }
  Future<Map<String, dynamic>?> getPaymentIntentDetails(String intentId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.stripe.com/v1/payment_intents/$intentId'),
        headers: {
          'Authorization': 'Bearer ${AppConst.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        log('❌ Failed to fetch PaymentIntent: ${response.body}');
        return null;
      }
    } catch (e) {
      log('❌ Error fetching PaymentIntent: $e');
      return null;
    }
  }

}
