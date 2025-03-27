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
    return SizedBox(
      height: 100 * screenHeight / 830.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ Prevents overflow
          children: [
            // 🔽 Row with Product Name and Add Product Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ Veg / Non-Veg Icon + Product Name
                Row(
                  children: [
                    // 🔽 Veg / Non-Veg Icon
                    Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: isVeg ? Colors.white : Colors.red,
                        border: Border.all(color: Colors.grey, width: 1.0),
                      ),
                      child: Icon(
                        isVeg ? Icons.circle : Icons.close,
                        color: Colors.green,
                        size: 10,
                      ),
                    ),

                    const SizedBox(width: 10.0),

                    // 🔽 Product Name (Single Line)
                    SizedBox(
                      width: 200, // Adjust width as needed
                      child: Text(
                        widget.product!.productName!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                // ✅ Add Product Button
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white, // ✅ White Background
                  ),
                  child: Row(
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
                          if (isSuccess!.isSuccess != null && context.mounted) {
                            Navigator.of(context).pop();
                          }
                          showToast(isSuccess.message!);
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(
                              widget.product!.cartQty != null &&
                                      widget.product!.cartQty == 1
                                  ? Icons.remove
                                  : MdiIcons.minus,
                              size: 17.0,
                              color: Colors.black),
                        ),
                      ),

                      // 🔽 Quantity Display
                      Text(
                        "${widget.product!.cartQty}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      // 🔽 Increase Quantity Button
                      InkWell(
                        onTap: () async {
                          if (!mounted)
                            return; // Prevent execution if widget is unmounted

                          showOnlyLoaderDialog(); // Show Loader
                          _qty = (widget.product!.cartQty ?? 0) + 1;

                          try {
                            ATCMS? isSuccess =
                                await widget.cartController!.addToCart(
                              widget.product,
                              _qty,
                              false,
                              varientId: widget.product!.varientId,
                              callId: 0,
                            );

                            if (context.mounted) {
                              Navigator.of(context)
                                  .pop(); // Close Loader if still mounted
                            }

                            // print(
                            //     "Response from addToCart: ${isSuccess?.message}");

                            if (isSuccess != null) {
                              if (context.mounted) {
                                showToast(isSuccess.message!); // Show Toast
                              }
                            } else {
                              if (context.mounted) {
                                showToast("Failed to add product to cart");
                              }
                            }

                            if (mounted) {
                              setState(
                                  () {}); // Update UI only if widget is still active
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.of(context)
                                  .pop(); // Ensure loader closes even if an error occurs
                              showToast("Something went wrong");
                            }
                            print("Error in addToCart: $e");
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(
                            MdiIcons.plus,
                            size: 17,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6), // ✅ Space between Button & Price

            // ✅ Price Display Below Add Product Button
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${global.appInfo!.currencySign} ${widget.product!.price}",
                style: textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
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
    return ListView.separated(
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
        child: Divider(
          color: Colors.grey[300],
          thickness: 1,
        ),
      ),
      shrinkWrap: true,
      itemCount: widget.cartController!.cartItemsList!.cartList.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return GetBuilder<CartController>(
          init: widget.cartController,
          builder: (value) => Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              showOnlyLoaderDialog();
              ATCMS? isSuccess;
              isSuccess = await widget.cartController!.addToCart(
                  widget.cartController!.cartItemsList!.cartList[index],
                  0,
                  true,
                  varientId: widget
                      .cartController!.cartItemsList!.cartList[index].varientId,
                  callId: 0);
              if (isSuccess!.isSuccess != null && context.mounted) {
                Navigator.of(context).pop();
              }
              showToast(isSuccess.message!);
              setState(() {});
            },
            background: _backgroundContainer(context, screenHeight),
            child: CartMenuItem(
              product: widget.cartController!.cartItemsList!.cartList[index],
              cartController: widget.cartController,
            ),
          ),
        );
      },
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
