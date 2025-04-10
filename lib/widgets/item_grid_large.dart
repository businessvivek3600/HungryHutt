import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/widgets/gradient_heading_row.dart';
import 'package:user/widgets/tag_container.dart';
import '../controllers/cart_controller.dart';
import '../models/category_product_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'add_product_details.dart';
import 'cart_quantity_widget.dart';

class NewlyProductGrid extends StatefulWidget {
  const NewlyProductGrid({
    super.key,
    required this.analytics,
    required this.observer,
    required this.title,
    required this.categoryName,
    required this.dealProducts,
    required this.screenId,
  });
  final dynamic analytics;
  final dynamic observer;
  final String title;
  final String categoryName;
  final List<Product> dealProducts;
  final int screenId;

  @override
  State<NewlyProductGrid> createState() => _NewlyProductGridState();
}

class _NewlyProductGridState extends State<NewlyProductGrid> {
  final CartController cartController = Get.find<CartController>();
  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double childAspectRatio = screenWidth < 600 ? 0.65 : 0.68;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildGradientHeadingRow(context, widget.title),
          GetBuilder<CartController>(
              builder: (cartController) {
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 8,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: widget.dealProducts.length,
                itemBuilder: (context, index) {
                  final product = widget.dealProducts[index];
                  for (var variant in product.varient) {
                    final cartItem = cartController.cartItemsList?.cartList.firstWhereOrNull(
                          (item) => item.varientId == variant.varientId,
                    );
                    variant.cartQty = cartItem?.cartQty ?? 0;
                  }

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: ColorFiltered(
                                  colorFilter: product.stock == 0
                                      ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                                      : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                                  child: Image.network(
                                    global.appInfo!.imageUrl! + product.productImage!,
                                    fit: BoxFit.cover,
                                    height: MediaQuery.of(context).size.height * 0.14,
                                    width: MediaQuery.of(context).size.width * 0.45,
                                  ),
                                ),
                              ),
                              if (product.stock == 0)
                                Positioned.fill(
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Text(
                                      "Currently Unavailable",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // if (product['bestseller'] == true)
                          const SizedBox(
                            height: 5,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3.0),
                                        color: Colors.transparent,
                                        border: Border.all(
                                            color: Colors.green, width: 2),
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    buildBadge("Bestseller", Colors.green.shade800),
                                    const SizedBox(width: 5),
                                    buildBadge("New", Colors.orange),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                // if (product['new'] == true)

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product
                                          .productName!, // Assuming 'name' key exists
                                      style: const TextStyle(
                                          fontSize: 14,
                                          wordSpacing: 1,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const Text(
                                      "Customisable",
                                      style: TextStyle(
                                        color: Colors.black26,
                                        fontSize: 8,
                                      ),
                                    ),
                                    Text(
                                      "${global.appInfo!.currencySign} ${product.price}", // Assuming 'price' key exists
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: (product.varient != null &&
                                      product.varient.isNotEmpty &&
                                      (product.varient.first.cartQty ?? 0) > 0)
                                      ? StatefulBuilder(
                                    builder: (context, setStateInner) {
                                      return Container(
                                        height: MediaQuery.of(context).size.height * 0.032,
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black26),
                                          borderRadius: BorderRadius.circular(6.0),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                         // mainAxisSize: MainAxisSize.max,
                                         // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                final newQty = product.varient.first.cartQty! - 1;

                                                if (newQty <= 0) {
                                                  final isDeleted = await cartController.delFromCart(
                                                    varientId: product.varient.first.varientId!,
                                                  );

                                                  if (isDeleted) {
                                                    product.varient.first.cartQty = 0;
                                                    setState(() {});
                                                  }
                                                } else {
                                                  await cartController.addToCart(
                                                    product,
                                                    newQty,
                                                    true,
                                                    varient: product.varient.first,
                                                  );
                                                  product.varient.first.cartQty = newQty;
                                                  setState(() {});
                                                }
                                              },
                                              child: Icon(
                                                MdiIcons.minus,
                                                size: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            Text(
                                              "${product.varient.first.cartQty}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            InkWell(
                                              onTap: () async {

                                                final newQty = product.varient.first.cartQty! + 1;

                                                final isSuccess = await cartController.addToCart(
                                                  product,
                                                  newQty,
                                                  false,
                                                  varient: product.varient.first,
                                                );

                                                if (isSuccess?.isSuccess == true) {
                                                  product.varient.first.cartQty = newQty;
                                                  setState(() {});
                                                }
                                              },
                                              child: Icon(
                                                MdiIcons.plus,
                                                size: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                      : IgnorePointer(
                                    ignoring: product.stock == 0,
                                    child: Opacity(
                                      opacity: product.stock == 0 ? 0.4 : 1.0,
                                      child: GestureDetector(

                                          onTap: () async {
                                            if (product.stock == 0) return;

                                            final variant = product.varient.first;
                                            final hasAddons = variant.addonCategories != null &&
                                                variant.addonCategories!.isNotEmpty &&
                                                variant.addonCategories!.any((category) =>
                                                category.addons != null && category.addons!.isNotEmpty);

                                            if (product.varient.length == 1 && !hasAddons) {
                                              // Directly add to cart
                                              final response = await cartController.addToCart(
                                                product,
                                                1,
                                                false,
                                                varient: variant,
                                                selectedAddons: [],
                                              );

                                              if (response != null && response.isSuccess == true) {
                                                setState(() {
                                                  product.varient.first.cartQty = 1; // ✅ UI switch
                                                });
                                                Get.snackbar("Success", "Product added to cart!",
                                                    backgroundColor: Colors.green, colorText: Colors.white);
                                              } else {
                                                Get.snackbar("Error", response?.message ?? "Failed to add product",
                                                    backgroundColor: Colors.red, colorText: Colors.white);
                                              }
                                            } else {
                                              // Open bottom sheet if variants/addons present
                                              showProductBottomSheet(context, product);
                                            }

                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: const Color(0xffe54740),
                                              width: 0.5,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Add",
                                                  style: TextStyle(
                                                    color: Color(0xffe54740),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(
                                                  Icons.add,
                                                  color: Color(0xffe54740),
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                )
              ,

                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          ),
        ],
      ),
    );
  }
}
