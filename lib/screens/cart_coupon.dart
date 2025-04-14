import 'dart:io';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import '../controllers/cart_controller.dart';
import '../controllers/coupon_controller.dart';
import '../models/businessLayer/base_route.dart';
import '../models/coupons_model.dart';

class CouponPage extends BaseRoute {
  final int? screenId;
  final String? cartId;
  final CartController? cartController;
  final ConfettiController? confettiController;
  const CouponPage({
    super.key,
    super.analytics,
    super.observer,
    super.routeName = 'CouponsScreen',
    this.screenId,
    this.cartId,
    this.cartController,
    required this.confettiController,
  });

  @override
  BaseRouteState<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends BaseRouteState<CouponPage> {
  final CouponController couponController = Get.put(CouponController());
  GlobalKey<ScaffoldState>? _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _getCouponsList();
      await couponController.loadSavedCoupon();
    } catch (e) {
      debugPrint("Exception - coupons_screen.dart - _init():$e");
    }
  }

  Future<void> _getCouponsList() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getStoreCoupons().then((result) async {
          if (result != null && result.status == "1") {
            print("✅ Coupon API Response Data: ${result.data}");
            await couponController.setCouponList(result.data!);
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - coupons_screen.dart - _getCouponsList():$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.9;
    return Container(
      color: Colors.grey.shade100,
      height: MediaQuery.of(context).size.height * 1,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
              ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text("APPLY COUPON",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                 Text("Your cart: ${global.appInfo!.currencySign}${widget.cartController!.cartItemsList!.totalPrice}",
                    style: const TextStyle(fontSize: 14, color: Colors.black)),
                const SizedBox(height: 8),
                _buildCouponInputField(),
                const SizedBox(height: 16),
              Container(
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0xFF68a039).withOpacity(0.6),
                    const Color(0xFF68a039).withOpacity(0.3),
                    Colors.black26.withOpacity(0.2),
                    Colors.black12,
                    Colors.transparent,
                  ])
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 30,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Offers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
                const SizedBox(height: 8),
                Obx(() {
                  if (!couponController.isDataLoaded.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (couponController.couponList.isEmpty) {
                    return const Text("No coupons available");
                  }
                  return ListView.builder(
                    itemCount: couponController.couponList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final coupon = couponController.couponList[index];
                      return cartCoupon(cardWidth, coupon);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildCouponInputField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Enter Coupon Code",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text("APPLY",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }

  Widget cartCoupon(double cardWidth, Coupon coupon) {
    final isAvailable = coupon.available ?? true;

    return SizedBox(
      width: cardWidth,
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.5, // Dim unavailable cards
        child: Card(
          color: isAvailable ? Colors.white : Colors.grey[200], // Grayed background
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LEFT COUPON CODE TICKET STRIP
                Stack(
                  children: [
                    Container(width: 50),
                    ClipPath(
                      clipper: TicketClipper(),
                      child: Container(
                        width: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isAvailable ? const Color(0xFF68a039) : Colors.grey,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: RotatedBox(
                          quarterTurns: -1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              coupon.couponCode?.toUpperCase() ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // COUPON BODY
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          coupon.couponName?.toUpperCase() ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        RichText(
                          text: TextSpan(
                            text: coupon.type == "amount"
                                ? "${global.appInfo!.currencySign}${coupon.amount}"
                                : "${coupon.amount}%",
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                            children: [
                              const TextSpan(
                                text: ' Flat off ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (coupon.maxDiscount != 0)
                                TextSpan(text: "up to ${coupon.maxDiscount.toString()}")
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (!isAvailable && coupon.statusMessage != null)
                          Text(
                            coupon.statusMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        Divider(color: Colors.grey.shade300, thickness: 1),
                        Text(
                          coupon.couponDescription?.toUpperCase() ?? "",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),

                // APPLY/REMOVE BUTTON
                Container(
                  color: Colors.white,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, right: 12),
                      child: GestureDetector(
                        onTap: isAvailable
                            ? () async {
                          if (couponController.selectedCouponCode.value == coupon.couponCode) {
                            await couponController.removeSelectedCoupon();
                            Get.back();
                          } else {
                            await couponController.saveSelectedCoupon(coupon);
                            Get.back();
                            showCouponAppliedDialog(coupon);
                          }
                        }
                            : null,
                        child: Obx(() {
                          bool isSelected = couponController.selectedCouponCode.value == coupon.couponCode;
                          return Text(
                            isSelected ? "REMOVE" : isAvailable ? "APPLY" : "",
                            style: TextStyle(
                              color: isSelected ? Colors.orange : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void showCouponAppliedDialog(Coupon coupon) {
    if (widget.confettiController != null) {
      widget.confettiController!.play();
    }
    var amount = coupon.type == "amount"
        ? "${global.appInfo!.currencySign}${coupon.amount}"
        : "${coupon.amount}%";
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            if (widget.confettiController != null)
              ConfettiWidget(
                confettiController: widget.confettiController!,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                emissionFrequency: 0.01,
                numberOfParticles: 200,
                gravity: 0.3,
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.discount_rounded, color: Colors.green, size: 48),
                  const SizedBox(height: 10),
                  Text("'${coupon.couponName}' applied",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  const SizedBox(height: 16),
                  Text("$amount savings with this coupon",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text("Use $amount and save every time you order",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 20),
                  const Text("YAY!",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  shadowColor: Colors.black,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child:
                    const Icon(Icons.close, color: Colors.grey, size: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 10.0;
    Path path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    Path cutouts = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, size.height * 0.25), radius: radius))
      ..addOval(Rect.fromCircle(center: Offset(0, size.height * 0.50), radius: radius))
      ..addOval(Rect.fromCircle(center: Offset(0, size.height * 0.75), radius: radius));
    return Path.combine(PathOperation.difference, path, cutouts);
  }

  @override
  bool shouldReclip(TicketClipper oldClipper) => false;
}

