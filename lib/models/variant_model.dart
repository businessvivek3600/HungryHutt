import 'package:flutter/foundation.dart';

class Variant {
  int? storeId;
  int? stock;
  int? varientId;
  String? description;
  int? price;
  int? mrp;
  String? varientImage;
  String? unit;
  int? quantity;
  int? dealPrice;
  String? validFrom;
  String? validTo;
  int? cartQty;
  bool isFavourite = false;
  double? avgrating;
  int? countrating;
  double? discountper;
  List<AddonCategory>? addonCategories;

  Variant();

  Variant.fromJson(Map<String, dynamic> json) {
    try {
      storeId = json['store_id'] != null ? int.parse(json['store_id'].toString()) : null;
      stock = json['stock'] != null ? int.parse(json['stock'].toString()) : null;
      varientId = json['varient_id'] != null ? int.parse(json['varient_id'].toString()) : null;
      description = json['description'];
      price = json['price'] != null ? double.parse(json['price'].toString()).round() : null;
      mrp = json['mrp'] != null ? double.parse(json['mrp'].toString()).round() : null;
      varientImage = json['varient_image'];
      unit = json['unit'];
      quantity = json['quantity'] != null ? int.parse(json['quantity'].toString()) : null;
      dealPrice = json['deal_price'] != null ? double.parse(json['deal_price'].toString()).round() : null;
      validFrom = json['valid_from'];
      validTo = json['valid_to'];
      cartQty = json['cart_qty'] != null ? int.parse(json['cart_qty'].toString()) : null;
      isFavourite = json['isFavourite'] != null && json['isFavourite'] == 'false' ? false : true;
      avgrating = json['avgrating'] != null ? double.parse(json['avgrating'].toString()) : null;
      countrating = json['countrating'] != null ? int.parse(json['countrating'].toString()) : null;
      discountper = json['discountper'] != null ? double.parse(json['discountper'].toString()) : null;

      // Parsing Addon Categories
      if (json['addonCategories'] != null) {
        addonCategories = (json['addonCategories'] as List)
            .map((e) => AddonCategory.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint("Exception - variant_model.dart - Variant.fromJson(): $e");
    }
  }
}

class AddonCategory {
  int? id;
  String? name;
  int? multipleType;
  List<Addon>? addons;

  AddonCategory();

  AddonCategory.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'] != null ? int.parse(json['id'].toString()) : null;
      name = json['name'];
      multipleType = json['multiple_type'] != null ? int.parse(json['multiple_type'].toString()) : null;

      if (json['addons'] != null) {
        addons = (json['addons'] as List).map((e) => Addon.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Exception - variant_model.dart - AddonCategory.fromJson(): $e");
    }
  }
}

class Addon {
  int? id;
  int? catId;
  String? name;
  int? vegNonveg;
  int? price;
  int? addedBy;
  int? status;

  Addon();

  Addon.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'] != null ? int.parse(json['id'].toString()) : null;
      catId = json['cat_id'] != null ? int.parse(json['cat_id'].toString()) : null;
      name = json['name'];
      vegNonveg = json['veg_nonveg'] != null ? int.parse(json['veg_nonveg'].toString()) : null;
      price = json['price'] != null ? int.parse(json['price'].toString()) : null;
      addedBy = json['added_by'] != null ? int.parse(json['added_by'].toString()) : null;
      status = json['status'] != null ? int.parse(json['status'].toString()) : null;
    } catch (e) {
      debugPrint("Exception - variant_model.dart - Addon.fromJson(): $e");
    }
  }
}
