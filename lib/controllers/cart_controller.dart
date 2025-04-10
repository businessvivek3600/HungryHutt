import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:user/models/addtocartmessagestatus.dart';
import 'package:user/models/businessLayer/api_helper.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/cart_model.dart';
import 'package:user/models/category_product_model.dart';
import 'package:user/models/variant_model.dart';

import '../models/coupons_model.dart';

class CartController extends GetxController {
  Cart? cartItemsList;
  APIHelper apiHelper = APIHelper();
  var isDataLoaded = false.obs;
  var isReorderDataLoaded = false.obs;
  var isReOrderSuccess = false.obs;
  var selectedCoupon = Rxn<Coupon>();

  Future<ATCMS?> addToCart(Product? product, int? cartQty, bool isDel, {Variant? varient, int? varientId, int? callId, List<String>? selectedAddons,}) async {
    try {
      bool isSuccess = false;
      String message = '--';
      int? vId;
      if (varient != null) {
        vId = varient.varientId;
      } else {
        vId = varientId;
      }

      await apiHelper.addToCart(qty: cartQty, varientId: vId, addons: selectedAddons).then((result) {
        if (result != null) {
          if (result.status == '1') {
            message = '${result.message}';
            cartItemsList = result.data;

            isSuccess = true;
            if (callId == 0) {
              // show cart screen
              if (isDel) {
                if (product!.cartQty != null && product.cartQty == 1) {
                  product.cartQty = 0;

                  // cartItemsList.cartList.remove(product);


                  global.cartCount -= 1;
                } else {
                  if (product.cartQty != null) {
                    product.cartQty = product.cartQty! - 1;
                  }
                }
              } else {
                if (product!.cartQty == null || product.cartQty == 0) {
                  product.cartQty = 1;

                  global.cartCount += 1;
                } else {
                  if (product.cartQty != null) {
                    product.cartQty = product.cartQty! + 1;
                  }
                }
              }
            } else {
              if (product!.varientId == varient!.varientId) {
                if (isDel) {
                  if (product.cartQty != null && product.cartQty == 1) {
                    product.cartQty = 0;
                    varient.cartQty = 0;
                    global.cartCount -= 1;
                  } else {
                    if (product.cartQty != null && varient.cartQty != null) {
                      product.cartQty = product.cartQty! - 1;
                      varient.cartQty = varient.cartQty! - 1;
                    }
                  }
                } else {
                  if (product.cartQty == null || product.cartQty == 0) {
                    product.cartQty = 1;
                    varient.cartQty = 1;
                    global.cartCount += 1;
                  } else {
                    if (product.cartQty != null && varient.cartQty != null) {
                      product.cartQty = product.cartQty! + 1;
                      varient.cartQty = varient.cartQty! + 1;
                    }
                  }
                }
              } else {
                if (isDel) {
                  if (varient.cartQty != null && varient.cartQty == 1) {
                    varient.cartQty = 0;
                    global.cartCount -= 1;
                  } else {
                    if (varient.cartQty != null) {
                      varient.cartQty =  varient.cartQty! - 1;
                    }
                  }
                } else {
                  if (varient.cartQty == null || varient.cartQty == 0) {
                    varient.cartQty = 1;
                    global.cartCount += 1;
                  } else {
                    if (varient.cartQty != null) {
                      varient.cartQty = varient.cartQty! + 1;
                    }
                  }
                }
              }
            }
          }
          else{
            message = '${result.message}';
          }
        } else {
          isSuccess = false;
          cartItemsList = null;
          message = 'Something went wrong please try after some time';
        }
      });

      update();
      return ATCMS(isSuccess: isSuccess, message: message);
    } catch (e) {
      debugPrint("Exception -  cart_controller.dart - addToCart():$e");
      return null;
    }
  }
  void updateSelectedCoupon(Coupon coupon) {
    selectedCoupon.value = coupon;
    update();
  }

  getCartList() async {
    try {
      isDataLoaded(false);
      cartItemsList = Cart();

      await apiHelper.showCart().then((result) async {
        if (result != null) {
          if (result.status == "1") {
            cartItemsList = result.data;
            global.cartCount = cartItemsList!.cartList.length;
          } else {
            cartItemsList!.cartList = [];
            global.cartCount = 0;
          }
        }
      });
      isDataLoaded(true);
      update();
    } catch (e) {
      debugPrint("Exception -  cart_controller.dart - getCartList():$e");
    }
  }
  Future<bool> delFromCart({required int varientId}) async {
    try {
      final result = await apiHelper.delFromCart(varientId: varientId);

      if (result != null && result.status == '1') {
        // Remove the item from the local cart list
        cartItemsList?.cartList.removeWhere((item) => item.varientId == varientId);

        // Update global cart count
        global.cartCount = cartItemsList?.cartList.length ?? 0;

        update(); // Notify listeners
        return true;
      } else {
        debugPrint("Failed to remove from cart: ${result?.message}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception - CartController - delFromCart(): $e");
      return false;
    }
  }

}
