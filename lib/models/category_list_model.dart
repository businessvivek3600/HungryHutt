import 'package:flutter/foundation.dart';
import 'package:user/models/subcategory_model.dart';

class CategoryList {
  String? title;
  int? catId;
  String? image;
  int? storeId;
  String? description;
  int? delRange;
  int? id;
  int? count;
  int? stfrom;
  bool? isSelected = false;
  List<SubCategory> subcategory = [];

  CategoryList({this.isSelected});
  CategoryList.fromJson(Map<String, dynamic> json) {
    try {
      title = json['title'] ?? '';
      catId = json['cat_id'] != null ? int.parse(json['cat_id'].toString()) : null;
      image = json['image'] ?? '';
      delRange = json['del_range'] != null ? int.parse(json['del_range'].toString()) : null;
      id = json['id'] != null ? int.parse(json['id'].toString()) : null;
      count = json['count'] != null ? int.parse(json['count'].toString()) : null;
      stfrom = json['stfrom'] != null ? int.parse(json['stfrom'].toString()) : null;
      storeId = json['store_id'] != null ? int.parse(json['store_id'].toString()) : null;
      description = json['description'] ?? '';
      subcategory = json['subcategory'] != null ? List<SubCategory>.from(json['subcategory'].map((x) => SubCategory.fromJson(x))) : [];
    } catch (e) {
      debugPrint("Exception - category_list_model.dart - CategoryList.fromJson():$e");
    }
  }
}
