import 'package:flutter/foundation.dart';

class Coupon {
  int? couponId;
  String? couponName;
  String? couponImage;
  String? couponCode;
  String? couponDescription;
  DateTime? startDate;
  DateTime? endDate;
  int? cartValue;
  int? amount;
  String? type;
  int? usesRestriction;
  int? userUses;
  int? storeId;
  int? maxDiscount;

  Coupon();

  Coupon.fromJson(Map<String, dynamic> json) {
    try {
      couponId = json["coupon_id"] != null ? int.parse(json["coupon_id"].toString()) : null;
      couponName = json["coupon_name"];
      couponImage = json["coupon_image"];
      couponCode = json["coupon_code"];
      couponDescription = json["coupon_description"];
      cartValue = json["cart_value"] != null ? int.parse(json["cart_value"].toString()) : null;
      amount = json["amount"] != null ? int.parse(json["amount"].toString()) : null;
      maxDiscount = json["max_discount"] != null ? int.parse(json["max_discount"].toString()) : null;
      type = json["type"];
      usesRestriction = json["uses_restriction"] != null ? int.parse(json["uses_restriction"].toString()) : null;
      userUses = json["user_uses"] != null ? int.parse(json["user_uses"].toString()) : 0;
      storeId = json["store_id"] != null ? int.parse(json["store_id"].toString()) : null;
      startDate = json["start_date"] != null ? DateTime.parse(json["start_date"]) : null;
      endDate = json["end_date"] != null ? DateTime.parse(json["end_date"]) : null;
    } catch (e) {
      debugPrint("Exception - coupons_model.dart - Coupon.fromJson():$e");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "coupon_id": couponId,
      "coupon_name": couponName,
      "coupon_image": couponImage,
      "coupon_code": couponCode,
      "coupon_description": couponDescription,
      "cart_value": cartValue,
      "amount": amount,
      "max_discount": maxDiscount,
      "type": type,
      "uses_restriction": usesRestriction,
      "user_uses": userUses,
      "store_id": storeId,
      "start_date": startDate?.toIso8601String(),
      "end_date": endDate?.toIso8601String(),
    };
  }
}
