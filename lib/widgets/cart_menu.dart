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

  _CartMenuItemState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      constraints: BoxConstraints(maxHeight: screenHeight * 0.08),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ Veg/Non-Veg Icon + Product Name
              Row(
                children: [
                  Container(
                    height: screenHeight * 0.015,
                    width: screenHeight * 0.015,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(color: Colors.grey, width: 1.0),
                    ),
                    child: Icon(
                      Icons.circle,
                      color: Colors.green,
                      size: screenHeight * 0.01,
                    ),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: screenWidth * 0.42,
                    child: Text(
                      widget.product!.productName ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: screenWidth * 0.038,
                      ),
                    ),
                  ),
                ],
              ),

              // ✅ Add Product Button
              Container(
                height: screenHeight * 0.035,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(6.0),
                  color: Colors.white,
                ),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔽 Decrease Quantity Button
                    InkWell(
                      onTap: () async {
                        showOnlyLoaderDialog();
                        _qty = (widget.product!.cartQty ?? 0) > 1
                            ? widget.product!.cartQty! - 1
                            : 0;
                        ATCMS? isSuccess =
                            await widget.cartController!.addToCart(
                          widget.product,
                          _qty,
                          true,
                          varientId: widget.product!.varientId,
                          callId: 0,
                        );
                        if (context.mounted) Navigator.of(context).pop();
                        showToast(isSuccess!.message!);
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(
                          widget.product!.cartQty == 1
                              ? Icons.remove
                              : MdiIcons.minus,
                          size: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    // 🔽 Quantity Display
                    Text(
                      "${widget.product!.cartQty}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15, // ✅ Aur chhoti font
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 5),
                    // 🔽 Increase Quantity Button
                    InkWell(
                      onTap: () async {
                        showOnlyLoaderDialog();
                        _qty = (widget.product!.cartQty ?? 0) + 1;
                        ATCMS? isSuccess =
                            await widget.cartController!.addToCart(
                          widget.product,
                          _qty,
                          false,
                          varientId: widget.product!.varientId,
                          callId: 0,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          showToast(isSuccess?.message ?? "Error");
                        }
                        if (mounted) setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(
                          MdiIcons.plus,
                          size: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ✅ Price Display
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${global.appInfo!.currencySign}${widget.product!.price}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
        ],
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
}

class _CartMenuState extends State<CartMenu> {
  _CartMenuState();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    // double screenWidget = MediaQuery.of(context).size.width;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.45,
      ),
      child: ListView.separated(
        separatorBuilder: (context, index) => Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
            child: Divider(color: Colors.grey[300], thickness: 0.8)),
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
