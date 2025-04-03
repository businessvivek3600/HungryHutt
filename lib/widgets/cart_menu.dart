import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/addtocartmessagestatus.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/category_product_model.dart';
import 'package:user/widgets/toastfile.dart';

class CartMenu extends StatefulWidget {
  final CartController? cartController;
  const CartMenu({super.key, this.cartController});

  @override
  State<CartMenu> createState() => _CartMenuState();
}

class CartMenuItem extends StatefulWidget {
  final Product? product;
  final CartController? cartController;
  const CartMenuItem({
    super.key,
    this.product,
    this.cartController,
  });

  @override
  State<CartMenuItem> createState() => _CartMenuItemState();
}

class _CartMenuItemState extends State<CartMenuItem> {
  int? _qty;
  final bool isVeg = true;
  @override
  void initState() {
    super.initState();
    _qty = widget.product?.cartQty ?? 1;
  }
  _CartMenuItemState();

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Veg/Non-Veg Icon + Product Name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: screenHeight * 0.015,
                      width: screenHeight * 0.015,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.green, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: screenHeight * 0.01,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 3),
                    SizedBox(
                      width: screenWidth * 0.42,
                      child: Text(
                        widget.product!.productName ?? '',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: screenWidth * 0.038,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // ✅ Quantity Adjuster
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: screenHeight * 0.032,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(6.0),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🔽 Decrease Quantity Button
                          InkWell(
                            onTap: _qty! > 1 ? _decreaseQuantity : null,
                            child: Icon(
                              _qty == 1 ? Icons.remove : MdiIcons.minus,
                              size: 15,
                              color: _qty == 1 ? Colors.grey : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 5),
                          // 🔽 Quantity Display
                          Text(
                            "$_qty",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 5),
                          // 🔽 Increase Quantity Button
                          InkWell(
                            onTap: _increaseQuantity,
                            child: Icon(
                              MdiIcons.plus,
                              size: 15,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // ✅ Price Display
                Text(
                  "${global.appInfo!.currencySign}${widget.product!.price! * (_qty ?? 1)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _decreaseQuantity() async {
    if (_qty! > 1) {
      setState(() => _qty = _qty! - 1);

      try {
        ATCMS? isSuccess = await widget.cartController!.addToCart(
          widget.product,
          _qty,
          true,
          varientId: widget.product!.varientId,
          callId: 0,
        );
        if (context.mounted) {
          showToast(isSuccess?.message ?? "Error");
        }
      } catch (e) {
        showToast("Something went wrong");
      }
    }
  }

  Future<void> _increaseQuantity() async {
    setState(() => _qty = _qty! + 1);

    try {
      ATCMS? isSuccess = await widget.cartController!.addToCart(
        widget.product,
        _qty,
        false,
        varientId: widget.product!.varientId,
        callId: 0,
      );
      if (context.mounted) {
        showToast(isSuccess?.message ?? "Error");
      }
    } catch (e) {
      showToast("Something went wrong");
    }
  }


  showOnlyLoaderDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _CartMenuState extends State<CartMenu> {
_CartMenuState();

@override
Widget build(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  // double screenWidget = MediaQuery.of(context).size.width;
  return ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: screenHeight,
      minHeight: 0,
    ),
    child: ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.cartController!.cartItemsList!.cartList.length,
      itemBuilder: (context, index) {
        return GetBuilder<CartController>(
          init: widget.cartController,
          builder: (value) => Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              showOnlyLoaderDialog();
              ATCMS? isSuccess = await widget.cartController!.addToCart(
                  widget.cartController!.cartItemsList!.cartList[index],
                  0,
                  true,
                  varientId: widget.cartController!.cartItemsList!
                      .cartList[index].varientId,
                  callId: 0);
              if (context.mounted) Navigator.of(context).pop();
              showToast(isSuccess!.message!);
              setState(() {});
            },
            background: Container(color: Colors.red),
            child: CartMenuItem(
              product: widget.cartController!.cartItemsList!.cartList[index],
              cartController: widget.cartController,
            ),
          ),
        );
      },
    ),
  );
}

showOnlyLoaderDialog() {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Center(child: CircularProgressIndicator()),
      );
    },
  );
}

Widget _backgroundContainer(BuildContext context, double screenHeight) {
  return Column(
    children: [
      const SizedBox(height: 8),
      Wrap(
        children: [
          Container(
            height: 80 * screenHeight / 830,
            color: Theme.of(context).colorScheme.error,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 32),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}
}
