import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/addtocartmessagestatus.dart';
import 'package:user/models/businessLayer/api_helper.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/category_product_model.dart';
import 'package:user/screens/login_screen.dart';
import 'package:user/screens/product_description_screen.dart';
import 'package:user/theme/style.dart';
import 'package:user/widgets/add_product_details.dart';
import 'package:user/widgets/tag_container.dart';
import 'package:user/widgets/toastfile.dart';

class PopularProductsMenuItem extends StatefulWidget {
  final int? callId;
  final Product product;
  final dynamic analytics;
  final dynamic observer;
  const PopularProductsMenuItem(
      {super.key,
        required this.product,
        this.analytics,
        this.observer,
        this.callId});

  @override
  State<PopularProductsMenuItem> createState() =>
      _PopularProductsMenuItemState();
}

class ProductsMenu extends StatefulWidget {
  final dynamic analytics;
  final dynamic observer;
  final int? callId;
  // final List<Product> dealProducts;
  final List<Product>? categoryProductList;

  const ProductsMenu(
      {super.key,
        this.analytics,
        this.observer,
        this.categoryProductList,
        // required this.dealProducts,
        this.callId});

  @override
  State<ProductsMenu> createState() => _ProductsMenuState();
}

class _PopularProductsMenuItemState extends State<PopularProductsMenuItem> {
  APIHelper apiHelper = APIHelper();
  final CartController cartController = Get.put(CartController());
  int? _qty;

  _PopularProductsMenuItemState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final  product = widget.product;

    return SizedBox(
      height: 160,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side (Text & Labels)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        buildBadge("Bestseller", Colors.green.shade800),
                        const SizedBox(width: 5),
                        buildBadge("New", Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.product.productName!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "₹ ${widget.product.price}",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.product.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 10),
                    // Add Button
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              // Right Side (Product Image)
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xffF7F7F7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: global.appInfo!.imageUrl! + widget.product.productImage!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error, size: 50),
                        imageBuilder: (context, imageProvider) {
                          final isOutOfStock = widget.product.stock! <= 0;

                          return ColorFiltered(
                            colorFilter: isOutOfStock
                                ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                                : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Visibility(
                                visible: isOutOfStock,
                                child: Container(
                                  color: Colors.black87.withOpacity(0.6),
                                  alignment: Alignment.center,
                                  child: Transform.rotate(
                                    angle: 12,
                                    child: Text(
                                      "Currently Unavailable",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,

                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [


                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: (product.varient.any((v) => (v.cartQty ?? 0) > 0))
                                ? StatefulBuilder(
                              builder: (context, setStateInner) {
                                final selectedVariant = product.varient.firstWhereOrNull((v) => (v.cartQty ?? 0) > 0) ?? product.varient.first;
                                return Container(
                                  height: MediaQuery.of(context).size.height * 0.032,
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(6.0),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          final newQty = (selectedVariant.cartQty ?? 1) - 1;
                                          if (newQty <= 0) {
                                            final isDeleted = await cartController.delFromCart(
                                              varientId: selectedVariant.varientId!,
                                            );
                                            if (isDeleted) {
                                              selectedVariant.cartQty = 0;
                                              setState(() {});
                                            }
                                          } else {
                                            await cartController.addToCart(
                                              product,
                                              newQty,
                                              true,
                                              varient: selectedVariant,
                                            );
                                            selectedVariant.cartQty = newQty;
                                            setState(() {});
                                          }
                                        },
                                        child: Icon(MdiIcons.minus, size: 20, color: Colors.black),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${selectedVariant.cartQty}",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      InkWell(
                                        onTap: () async {
                                          final newQty = (selectedVariant.cartQty ?? 0) + 1;
                                          final isSuccess = await cartController.addToCart(
                                            product,
                                            newQty,
                                            false,
                                            varient: selectedVariant,
                                          );
                                          if (isSuccess?.isSuccess == true) {
                                            selectedVariant.cartQty = newQty;
                                            setState(() {});
                                          }
                                        },
                                        child: Icon(MdiIcons.plus, size: 20, color: Colors.black),
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
                                        variant.addonCategories!.any((cat) => cat.addons != null && cat.addons!.isNotEmpty);

                                    if (product.varient.length == 1 && !hasAddons) {
                                      final response = await cartController.addToCart(
                                        product,
                                        1,
                                        false,
                                        varient: variant,
                                        selectedAddons: [],
                                      );
                                      if (response != null && response.isSuccess == true) {
                                        setState(() {
                                          product.varient.first.cartQty = 1;
                                        });
                                        Get.snackbar("Success", "Product added to cart!",
                                            backgroundColor: Colors.green, colorText: Colors.white);
                                      } else {
                                        Get.snackbar("Error", response?.message ?? "Failed to add product",
                                            backgroundColor: Colors.red, colorText: Colors.white);
                                      }
                                    } else {
                                      showProductBottomSheet(context, product);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
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
                                          Icon(Icons.add, color: Color(0xffe54740), size: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )

                        ],
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future<bool> addRemoveWishList(int? varientId, Product? product) async {
    bool isAddedSuccesFully = false;
    try {
      await apiHelper.addRemoveWishList(varientId).then((result) async {
        if (result != null) {
          if (result.status == "1" || result.status == "2") {
            isAddedSuccesFully = true;

            widget.product.isFavourite = !widget.product.isFavourite;

            if (result.status == "2") {
              if (widget.callId == 0) {
                // product
                // categoryProductList.removeWhere((e) => e.varientId == varientId);
              }
            }

            setState(() {});
          } else {
            isAddedSuccesFully = false;

            setState(() {});
            if (!mounted) return;
            showSnackBar(
                snackBarMessage: AppLocalizations.of(context)!
                    .txt_please_try_again_after_sometime);
          }
        }
      });
      return isAddedSuccesFully;
    } catch (e) {
      debugPrint("Exception - products_menu.dart - addRemoveWishList():$e");
      return isAddedSuccesFully;
    }
  }

  void showSnackBar({required String snackBarMessage}) {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text(
    //     snackBarMessage,
    //     textAlign: TextAlign.center,
    //   ),
    //   duration: Duration(seconds: 2),
    // ));
    showToast(snackBarMessage);
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

  // _showVarientModalBottomSheet(TextTheme textTheme, CartController value) {
  //   return showModalBottomSheet(
  //       context: context,
  //       isScrollControlled: false,
  //       builder: (BuildContext context) {
  //         return GetBuilder<CartController>(
  //           init: cartController,
  //           builder: (value) => StatefulBuilder(
  //               builder: (BuildContext context, StateSetter setState) {
  //                 return SizedBox(
  //                   height: 300,
  //                   child: Column(
  //                     children: [
  //                       Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Text(
  //                           widget.product.productName!,
  //                           style: Theme.of(context).textTheme.titleMedium,
  //                         ),
  //                       ),
  //                       const Divider(),
  //                       Expanded(
  //                         child: ListView.separated(
  //                           shrinkWrap: true,
  //                           itemCount: widget.product.varient.length,
  //                           itemBuilder: (BuildContext context, int i) {
  //                             return ListTile(
  //                               title: ReadMoreText(
  //                                 '${widget.product.varient[i].description}',
  //                                 trimLines: 2,
  //                                 trimMode: TrimMode.Line,
  //                                 trimCollapsedText: 'Show more',
  //                                 trimExpandedText: 'Show less',
  //                                 style: Theme.of(context)
  //                                     .textTheme
  //                                     .bodyLarge!
  //                                     .copyWith(fontSize: 16),
  //                                 lessStyle: Theme.of(context)
  //                                     .textTheme
  //                                     .bodyLarge!
  //                                     .copyWith(fontSize: 16),
  //                                 moreStyle: Theme.of(context)
  //                                     .textTheme
  //                                     .bodyLarge!
  //                                     .copyWith(fontSize: 16),
  //                               ),
  //                               subtitle: Text(
  //                                   '${widget.product.varient[i].quantity} ${widget.product.varient[i].unit} / ${global.appInfo!.currencySign} ${widget.product.varient[i].price}',
  //                                   style: Theme.of(context)
  //                                       .textTheme
  //                                       .titleSmall!
  //                                       .copyWith(fontSize: 15)),
  //                               trailing: widget.product.varient[i].cartQty ==
  //                                   null ||
  //                                   widget.product.varient[i].cartQty == 0
  //                                   ? InkWell(
  //                                 onTap: () async {
  //                                   if (global.currentUser!.id == null) {
  //                                     Get.to(LoginScreen(
  //                                       analytics: widget.analytics,
  //                                       observer: widget.observer,
  //                                     ));
  //                                   } else {
  //                                     showOnlyLoaderDialog();
  //                                     ATCMS? isSuccess;
  //                                     _qty = 1;
  //                                     isSuccess = await value.addToCart(
  //                                         widget.product, _qty, false,
  //                                         varient: widget.product.varient[i]);
  //                                     if (isSuccess!.isSuccess != null &&
  //                                         context.mounted) {
  //                                       Navigator.of(context).pop();
  //                                     }
  //                                     showToast(isSuccess.message!);
  //                                     setState(() {});
  //                                   }
  //                                 },
  //                                 child: Container(
  //                                   height: 23,
  //                                   width: 23,
  //                                   alignment: Alignment.center,
  //                                   color: Theme.of(context)
  //                                       .colorScheme
  //                                       .secondaryContainer,
  //                                   child: Icon(
  //                                     Icons.add,
  //                                     size: 17.0,
  //                                     color: Theme.of(context)
  //                                         .colorScheme
  //                                         .onSecondaryContainer,
  //                                   ),
  //                                 ),
  //                               )
  //                                   : Padding(
  //                                 padding: const EdgeInsets.only(
  //                                     top: 5, bottom: 5),
  //                                 child: Row(
  //                                   mainAxisSize: MainAxisSize.min,
  //                                   children: [
  //                                     InkWell(
  //                                       onTap: () async {
  //                                         if (widget.product.varient[i]
  //                                             .cartQty !=
  //                                             null &&
  //                                             widget.product.varient[i]
  //                                                 .cartQty ==
  //                                                 1) {
  //                                           _qty = 0;
  //                                         } else {
  //                                           _qty = widget.product.varient[i]
  //                                               .cartQty! -
  //                                               1;
  //                                         }
  //                                         showOnlyLoaderDialog();
  //                                         ATCMS? isSuccess;
  //                                         isSuccess = await value.addToCart(
  //                                             widget.product, _qty, true,
  //                                             varient:
  //                                             widget.product.varient[i]);
  //                                         if (isSuccess!.isSuccess != null &&
  //                                             context.mounted) {
  //                                           Navigator.of(context).pop();
  //                                         }
  //                                         showToast(isSuccess.message!);
  //                                         setState(() {});
  //                                       },
  //                                       child: Container(
  //                                           height: 23,
  //                                           width: 23,
  //                                           alignment: Alignment.center,
  //                                           color: Theme.of(context)
  //                                               .colorScheme
  //                                               .tertiaryContainer,
  //                                           child: widget.product.varient[i]
  //                                               .cartQty ==
  //                                               1
  //                                               ? Icon(
  //                                             Icons.delete,
  //                                             size: 17.0,
  //                                             color: Theme.of(context)
  //                                                 .colorScheme
  //                                                 .onTertiaryContainer,
  //                                           )
  //                                               : Icon(
  //                                             MdiIcons.minus,
  //                                             size: 17.0,
  //                                             color: Theme.of(context)
  //                                                 .colorScheme
  //                                                 .onTertiaryContainer,
  //                                           )),
  //                                     ),
  //                                     const SizedBox(
  //                                       width: 5,
  //                                     ),
  //                                     Container(
  //                                       height: 23,
  //                                       width: 23,
  //                                       decoration: BoxDecoration(
  //                                         border: Border.all(
  //                                           width: 1.0,
  //                                           color: Theme.of(context)
  //                                               .colorScheme
  //                                               .surfaceContainerHighest,
  //                                         ),
  //                                         borderRadius: const BorderRadius
  //                                             .all(Radius.circular(
  //                                             5.0) //                 <--- border radius here
  //                                         ),
  //                                       ),
  //                                       child: Center(
  //                                         child: Text(
  //                                           "${widget.product.varient[i].cartQty}",
  //                                           textAlign: TextAlign.center,
  //                                           style: TextStyle(
  //                                             color: Theme.of(context)
  //                                                 .colorScheme
  //                                                 .onSurfaceVariant,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                     const SizedBox(
  //                                       width: 5,
  //                                     ),
  //                                     InkWell(
  //                                       onTap: () async {
  //                                         _qty = widget.product.varient[i]
  //                                             .cartQty! +
  //                                             1;
  //
  //                                         showOnlyLoaderDialog();
  //                                         ATCMS? isSuccess;
  //                                         isSuccess = await value.addToCart(
  //                                             widget.product, _qty, false,
  //                                             varient:
  //                                             widget.product.varient[i]);
  //                                         if (isSuccess!.isSuccess != null &&
  //                                             context.mounted) {
  //                                           Navigator.of(context).pop();
  //                                         }
  //                                         showToast(isSuccess.message!);
  //                                         setState(() {});
  //                                       },
  //                                       child: Container(
  //                                           height: 23,
  //                                           width: 23,
  //                                           alignment: Alignment.center,
  //                                           color: Theme.of(context)
  //                                               .colorScheme
  //                                               .primaryContainer,
  //                                           child: Icon(
  //                                             MdiIcons.plus,
  //                                             size: 17,
  //                                             color: Theme.of(context)
  //                                                 .colorScheme
  //                                                 .onPrimaryContainer,
  //                                           )),
  //                                     )
  //                                   ],
  //                                 ),
  //                               ),
  //                             );
  //                           },
  //                           separatorBuilder: (BuildContext context, int i) {
  //                             return const Divider();
  //                           },
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 );
  //               }),
  //         );
  //       });
  // }
}

class _ProductsMenuState extends State<ProductsMenu> {
  APIHelper apiHelper = APIHelper();

  _ProductsMenuState();

  Future<bool> addRemoveWishList(int varientId, int index) async {
    bool isAddedSuccesFully = false;
    try {
      await apiHelper.addRemoveWishList(varientId).then((result) async {
        if (result != null) {
          if (result.status == "1" || result.status == "2") {
            isAddedSuccesFully = true;

            widget.categoryProductList![index].isFavourite =
            !widget.categoryProductList![index].isFavourite;

            if (result.status == "2") {
              if (widget.callId == 0) {
                widget.categoryProductList!
                    .removeWhere((e) => e.varientId == varientId);
              }
            }

            setState(() {});
          } else {
            isAddedSuccesFully = false;

            setState(() {});
            if (!mounted) return;
            showSnackBar(
                snackBarMessage: AppLocalizations.of(context)!
                    .txt_please_try_again_after_sometime);
          }
        }
      });
      return isAddedSuccesFully;
    } catch (e) {
      debugPrint("Exception - products_menu.dart - addRemoveWishList():$e");
      return isAddedSuccesFully;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.categoryProductList!.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () => Get.to(() => ProductDescriptionScreen(
                analytics: widget.analytics,
                observer: widget.observer,
                productId: widget.categoryProductList![index].productId)),
            child: PopularProductsMenuItem(
              key: Key('${widget.categoryProductList!.length}'),
              product: widget.categoryProductList![index],
              analytics: widget.analytics,
              observer: widget.observer,
              callId: widget.callId,
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

  void showSnackBar({required String snackBarMessage}) {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text(
    //     snackBarMessage,
    //     textAlign: TextAlign.center,
    //   ),
    //   duration: Duration(seconds: 2),
    // ));
    showToast(snackBarMessage);
  }
}
