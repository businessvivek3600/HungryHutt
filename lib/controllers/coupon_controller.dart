import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coupons_model.dart';

class CouponController extends GetxController {
  var couponList = <Coupon>[].obs;
  var selectedCouponCode = RxnString();
  var selectedCoupon = Rxn<Coupon>(); // 👈 Add this
  var isDataLoaded = false.obs;

  Future<void> setCouponList(List<Coupon> coupons) async {
    couponList.value = coupons;
    isDataLoaded.value = true;
    update();
  }

  Future<void> saveSelectedCoupon(Coupon coupon) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(coupon.toJson());
    await prefs.setString('selected_coupon', jsonString);
    selectedCouponCode.value = coupon.couponCode;
    selectedCoupon.value = coupon; // 👈 Set the actual coupon
    update();
  }

  Future<void> removeSelectedCoupon() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_coupon');
    selectedCouponCode.value = null;
    selectedCoupon.value = null; // 👈 Clear the coupon
    update();
  }

  Future<void> loadSavedCoupon() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('selected_coupon');
    if (jsonString != null) {
      try {
        final jsonMap = jsonDecode(jsonString);
        Coupon savedCoupon = Coupon.fromJson(jsonMap);
        selectedCouponCode.value = savedCoupon.couponCode;
        selectedCoupon.value = savedCoupon; // 👈 Restore the coupon
      } catch (e) {
        print("Error decoding saved coupon: $e");
      }
    }
  }

  void refreshCoupons() {
    isDataLoaded.value = false;
    couponList.clear();
    selectedCouponCode.value = null;
    selectedCoupon.value = null;
    update();
  }
}

