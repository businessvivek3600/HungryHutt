import 'package:flutter/foundation.dart';
import 'package:user/models/image_model.dart';
import 'package:user/models/tags_model.dart';
import 'package:user/models/variant_model.dart';

class Product {
  int? pId;
  int? varientId;
  int? stock;
  int? storeId;
  int? storeOrderId;
  double? mrp;
  double? price;
  int? minOrdQty;
  int? maxOrdQty;
  int? productId;
  int? quantity;
  String? unit;
  int? baseMrp;
  int? basePrice;
  String? description;
  String? varientImage;
  String? ean;
  int? approved;
  int? addedBy;
  int? catId;
  String? productName;
  String? productImage;
  String? type;
  int? hide;
  int? count;
  List<ImageModel> images = [];
  List<TagsModel> tags = [];
  List<Variant> varient = [];
  int? qty;
  int? totalMrp;
  String? orderCartId;
  String? orderDate;
  int? storeApproval;
  double? txPer;
  int? priceWithoutTax;
  double? txPrice;
  String? txName;
  bool isFavourite = false;
  int? cartQty;
  int? countrating;
  int? rating;
  int? ratingCount;
  int? userRating;
  bool isSelected = false;
  int? discount;
  int? maxprice;
  int? isNonVeg;
  String? ratingDescription;

  Product();
  Product.fromJson(Map<String, dynamic> json) {
    try {
      pId = json['p_id'] != null ? int.parse(json['p_id'].toString()) : null;
      varientId = json['varient_id'] != null ? int.parse(json['varient_id'].toString()) : null;
      stock = json['stock'] != null ? int.parse(json['stock'].toString()) : null;
      storeId = json['store_id'] != null ? int.parse(json['store_id'].toString()) : null;
      storeOrderId = json['store_order_id'] != null ? int.parse(json['store_order_id'].toString()) : null;
      mrp = json['mrp'] != null ? double.parse('${json['mrp']}') : null;
      price = json['price'] != null ? double.parse('${json['price']}'): null;
      minOrdQty = json['min_ord_qty'] != null ? int.parse(json['min_ord_qty'].toString()) : null;
      minOrdQty = json['vegNonVeg'] != null ? int.parse(json['vegNonVeg'].toString()) : null;
      maxOrdQty = json['max_ord_qty'] != null ? int.parse(json['max_ord_qty'].toString()) : null;
      productId = json['product_id'] != null ? int.parse(json['product_id'].toString()) : null;
      quantity = json['quantity'] != null ? int.parse(json['quantity'].toString()) : null;
      unit = json['unit'] ?? '';
      baseMrp = json['base_mrp'] != null ? double.parse(json['base_mrp'].toString()).round() : null;
      basePrice = json['base_price'] != null ? double.parse(json['base_price'].toString()).round() : null;
      description = json['description'] ?? '';
      varientImage = json['varient_image'] ?? '';
      ean = json['ean'] ?? '';
      approved = json['approved'] != null ? int.parse(json['approved'].toString()) : null;
      addedBy = json['added_by'] != null ? int.parse(json['added_by'].toString()) : null;
      catId = json['cat_id'] != null ? int.parse(json['cat_id'].toString()) : null;
      productName = json['product_name'] ?? '';
      productImage = json['product_image'] ?? '';
      type = json['type'] ?? '';
      hide = json['hide'] != null ? int.parse(json['hide'].toString()) : null;
      count = json['count'] != null ? int.parse(json['count'].toString()) : null;
      qty = json['qty'] != null ? int.parse(json['qty'].toString()) : null;
      totalMrp = json['total_mrp'] != null ? double.parse(json['total_mrp'].toString()).round() : null;
      orderCartId = json['order_cart_id'];
      orderDate = json['order_date'] ?? '';
      storeApproval = json['store_approval'] != null ? int.parse(json['store_approval'].toString()) : null;
      txPer = json['tx_per'] != null ? double.parse(json['tx_per'].toString()) : null;
      priceWithoutTax = json['price_without_tax'] != null ? double.parse(json['price_without_tax'].toString()).round() : null;
      txPrice = json['tx_price'] != null ? double.parse(json['tx_price'].toString()) : null;
      txName = json['tx_name'];
      isFavourite = json['isFavourite'] != null && json['isFavourite'] == 'false' ? false : true;
      cartQty = json['cart_qty'] != null ? int.parse(json['cart_qty'].toString()) : null;
      countrating = json['countrating'] != null ? int.parse(json['countrating'].toString()) : null;
      rating = json['avgrating'] != null ? double.parse(json['avgrating'].toString()).round() : 0;
       userRating = json['rating'] != null ? double.parse(json['rating'].toString()).round() : 0;
      ratingCount = json['countrating'] != null ? int.parse(json['countrating'].toString()) : 0;
      ratingDescription = json['rating_description'] ?? '';
      maxprice = json['maxprice'] != null ? int.parse(json['maxprice'].toString()) : null;
      discount = json['discountper'] != null ? double.parse(json['discountper'].toString()).round() : null;
      images = json['images'] != null ? List<ImageModel>.from(json['images'].map((x) => ImageModel.fromJson(x))) : [];
      tags = json['tags'] != null ? List<TagsModel>.from(json['tags'].map((x) => TagsModel.fromJson(x))) : [];
      varient = json['varients'] != null ? List<Variant>.from(json['varients'].map((x) => Variant.fromJson(x))) : [];
    } catch (e) {
      debugPrint("Exception - category_product_model.dart - Product.fromJson():$e");
    }
  }
}
