import 'package:flutter/foundation.dart';
import 'package:user/models/category_product_model.dart';

class Cart {
  String? status;
  String? message;
  double? totalPrice;
  double? totalMrp;
  int? totalItems;
  double? totalTax;
  double? avgTax;
  double? discountonmrp;
  double? restorantCharge;
  double? deliveryCharge;
  List<Product> cartList = [];

  Cart();
  Cart.fromJson(Map<String, dynamic> json) {
    try {
      totalPrice = json['total_price'] != null ? double.parse('${json['total_price']}') : null;
      totalMrp = json['total_mrp'] != null ? double.parse('${json['total_mrp']}') : null;
      totalItems = json['total_items'] != null ? int.parse('${json['total_items']}') : null;
      totalTax = json['total_tax'] != null ? double.parse('${json['total_tax']}') : null;
      avgTax = json['avg_tax'] != null ? double.parse('${json['avg_tax']}') : null;
      discountonmrp = json['discountonmrp'] != null ? double.parse('${json['discountonmrp']}') : null;
      deliveryCharge = json['delivery_charge'] != null ? double.parse('${json['delivery_charge']}') : null; // ✅ NEW
      restorantCharge = json['restorant_charge'] != null ? double.parse('${json['restorant_charge']}') : null; // ✅ Add this
      cartList = json['data'] != null ? List<Product>.from(json['data'].map((x) => Product.fromJson(x))) : [];
    } catch (e) {
      debugPrint("Exception - cart_model.dart - Cart.fromJson():$e");
    }
  }
}
