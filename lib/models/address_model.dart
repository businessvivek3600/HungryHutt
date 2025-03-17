import 'package:flutter/foundation.dart';

class Address {
  int? addressId;
  String? type;
  int? userId;
  String? receiverName;
  String? receiverPhone;
  String? city;
  String? society;
  int? cityId;
  String? fullAddress;
  int? societyId;
  String? houseNo;
  String? landmark;
  String? state;
  String? pincode;
  String? lat;
  String? lng;
  int? selectStatus;
  DateTime? addedAt;
  DateTime? updatedAt;
  double? distancee;
  bool isSelected = false;
  Address();
  Address.fromJson(Map<String, dynamic> json) {
    try {
      addressId = json["address_id"] != null ? int.parse(json["address_id"].toString()) : null;
      type = json["type"];
      userId = json["user_id"] != null ? int.parse(json["user_id"].toString()) : null;
      receiverName = json["receiver_name"];
      receiverPhone = json["receiver_phone"];
      city = json["city"];
      society = json["society"];
      cityId = json["city_id"] != null ? int.parse(json["city_id"].toString()) : null;
      fullAddress = json["full_address"];
      societyId = json["society_id"] != null ? int.parse(json["society_id"].toString()) : null;
      houseNo = json["house_no"];
      landmark = json["landmark"];
      state = json["state"];
      pincode = json["pincode"];
      lat = json["lat"];
      lng = json["lng"];
      selectStatus = json["select_status"] != null ? int.parse(json["select_status"].toString()) : null;
      distancee = json["distancee"] != null ? double.parse(json["distancee"].toString()) : null;
      addedAt = json["added_at"] != null ? DateTime.parse(json["added_at"]) : null;
      updatedAt = json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null;
    } catch (e) {
      debugPrint("Exception - address_model.dart - Address.fromJson():$e");
    }
  }
  Map<String, dynamic> toJson() {
    return {
      "address_id": addressId,
      "type": type,
      "user_id": userId,
      "receiver_name": receiverName,
      "receiver_phone": receiverPhone,
      "city": city,
      "society": society,
      "city_id": cityId,
      "full_address": fullAddress,
      "society_id": societyId,
      "house_no": houseNo,
      "landmark": landmark,
      "state": state,
      "pincode": pincode,
      "lat": lat,
      "lng": lng,
      "select_status": selectStatus,
      "added_at": addedAt?.toIso8601String(), // Convert DateTime to String
      "updated_at": updatedAt?.toIso8601String(), // Convert DateTime to String
    };
  }
}
