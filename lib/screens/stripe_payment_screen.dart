import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/card_model.dart';

import '../constants/app_constant.dart';

class StripeService {
  static String paymentApiUrl = '${global.stripeBaseApi}/payment_intents';
  static String createCustomerUrl = '${global.stripeBaseApi}/customers';

  static Map<String, String> headers = {'Authorization': 'Bearer ${AppConst.stripeSecretKey}', 'Content-Type': 'application/x-www-form-urlencoded'};

  static Future<Map<String, dynamic>?> confirmPaymentIntent(String? paymentIntentId, String? paymentMethodId, {String? customerId}) async {
    try {
      if (paymentIntentId == null || paymentMethodId == null) {
        debugPrint("Error: paymentIntentId or paymentMethodId is null");
        return null;
      }

      Map<String, dynamic> body = {'payment_method': paymentMethodId};

      var response = await http.post(
        Uri.parse('${global.stripeBaseApi}/payment_intents/$paymentIntentId/confirm'),
        body: body,
        headers: StripeService.headers,
      );

      Map<String, dynamic> responseData = jsonDecode(response.body);

      debugPrint("Stripe Confirm Payment Response: $responseData");

      return responseData;
    } catch (err) {
      debugPrint('Exception - stripe_payment_screen.dart - confirmPaymentIntent(): ${err.toString()}');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> createCustomer({String? source, String? email}) async {
    try {
      Map<String, dynamic> body = {'email': email};
      var response = await http.post(Uri.parse(StripeService.createCustomerUrl), body: body, headers: StripeService.headers);
      return jsonDecode(response.body);
    } catch (err) {
      debugPrint('Exception - stripe_payment_screen.dart - createCustomer():${err.toString()}');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> createPaymentIntent(int? amount, String? currency, {String? customerId}) async {
    try {
      Map<String, dynamic> body = {'amount': amount.toString(), 'currency': global.appInfo!.paymentCurrency, 'customer': customerId};
      var response = await http.post(Uri.parse(StripeService.paymentApiUrl), body: body, headers: StripeService.headers);
      return jsonDecode(response.body);
    } catch (err) {
      debugPrint('Exception - stripe_payment_screen.dart - createPaymentIntent(): ${err.toString()}');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> createPaymentMethod(CardModel card) async {
    try {
      Map<String, dynamic> body = {'type': "card", 'card[number]': card.number!.replaceAll(' ', ''), 'card[exp_month]': '${card.expiryMonth}', 'card[exp_year]': '${card.expiryYear}', "card[cvc]": card.cvv};
      var response = await http.post(Uri.parse('${global.stripeBaseApi}/payment_methods'), body: body, headers: StripeService.headers);
      return jsonDecode(response.body);
    } catch (err) {
      debugPrint('Exception - stripe_payment_screen.dart - createPaymentMethod():${err.toString()}');
    }
    return null;
  }

  static getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return StripeTransactionResponse(message: message, success: false);
  }
}

class StripeTransactionResponse {
  String? message;
  bool? success;
  StripeTransactionResponse({this.message, this.success});
}
