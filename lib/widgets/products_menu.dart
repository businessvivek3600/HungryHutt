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
                        imageUrl: global.appInfo!.imageUrl! +
                            widget.product.productImage!,
                        fit: BoxFit
                            .cover, // Ensure image fills the entire container
                        placeholder: (context, url) => const Center(
                            child:
                                CircularProgressIndicator()), // Optional loading indicator
                        errorWidget: (context, url, error) => const Icon(
                            Icons.error,
                            size: 50), // Optional error placeholder
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit:
                                  BoxFit.cover, // Change to cover for full fill
                            ),
                          ),
                          child: Visibility(
                            visible: widget.product.stock! <=
                                0, // Show only when out of stock
                            child: Container(
                              color: Colors.white.withOpacity(0.6),
                              alignment: Alignment.center,
                              child: Transform.rotate(
                                angle: 12,
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .txt_out_of_stock,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: GestureDetector(
                        onTap: () {
                          showProductBottomSheet(context, widget.product);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white, // White background
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                            border: Border.all(
                                color: const Color(0xffe54740),
                                width: 0.5), // Green border
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12, // Shadow color
                                blurRadius: 2, // Slight shadow effect
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add,
                                    color: Color(0xffe54740), size: 16),
                                SizedBox(width: 4),
                                Text("Add",
                                    style: TextStyle(
                                        color: Color(0xffe54740),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                // Space between text and icon
                              ],
                            ),
                          ),
                        ),
                      )),
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

  _showVarientModalBottomSheet(TextTheme textTheme, CartController value) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: false,
        builder: (BuildContext context) {
          return GetBuilder<CartController>(
            init: cartController,
            builder: (value) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                height: 300,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.product.productName!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: widget.product.varient.length,
                        itemBuilder: (BuildContext context, int i) {
                          return ListTile(
                            title: ReadMoreText(
                              '${widget.product.varient[i].description}',
                              trimLines: 2,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'Show more',
                              trimExpandedText: 'Show less',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 16),
                              lessStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 16),
                              moreStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 16),
                            ),
                            subtitle: Text(
                                '${widget.product.varient[i].quantity} ${widget.product.varient[i].unit} / ${global.appInfo!.currencySign} ${widget.product.varient[i].price}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(fontSize: 15)),
                            trailing: widget.product.varient[i].cartQty ==
                                        null ||
                                    widget.product.varient[i].cartQty == 0
                                ? InkWell(
                                    onTap: () async {
                                      if (global.currentUser!.id == null) {
                                        Get.to(LoginScreen(
                                          analytics: widget.analytics,
                                          observer: widget.observer,
                                        ));
                                      } else {
                                        showOnlyLoaderDialog();
                                        ATCMS? isSuccess;
                                        _qty = 1;
                                        isSuccess = await value.addToCart(
                                            widget.product, _qty, false,
                                            varient: widget.product.varient[i]);
                                        if (isSuccess!.isSuccess != null &&
                                            context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                        showToast(isSuccess.message!);
                                        setState(() {});
                                      }
                                    },
                                    child: Container(
                                      height: 23,
                                      width: 23,
                                      alignment: Alignment.center,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      child: Icon(
                                        Icons.add,
                                        size: 17.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            if (widget.product.varient[i]
                                                        .cartQty !=
                                                    null &&
                                                widget.product.varient[i]
                                                        .cartQty ==
                                                    1) {
                                              _qty = 0;
                                            } else {
                                              _qty = widget.product.varient[i]
                                                      .cartQty! -
                                                  1;
                                            }
                                            showOnlyLoaderDialog();
                                            ATCMS? isSuccess;
                                            isSuccess = await value.addToCart(
                                                widget.product, _qty, true,
                                                varient:
                                                    widget.product.varient[i]);
                                            if (isSuccess!.isSuccess != null &&
                                                context.mounted) {
                                              Navigator.of(context).pop();
                                            }
                                            showToast(isSuccess.message!);
                                            setState(() {});
                                          },
                                          child: Container(
                                              height: 23,
                                              width: 23,
                                              alignment: Alignment.center,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiaryContainer,
                                              child: widget.product.varient[i]
                                                          .cartQty ==
                                                      1
                                                  ? Icon(
                                                      Icons.delete,
                                                      size: 17.0,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onTertiaryContainer,
                                                    )
                                                  : Icon(
                                                      MdiIcons.minus,
                                                      size: 17.0,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onTertiaryContainer,
                                                    )),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          height: 23,
                                          width: 23,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1.0,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                            ),
                                            borderRadius: const BorderRadius
                                                .all(Radius.circular(
                                                    5.0) //                 <--- border radius here
                                                ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${widget.product.varient[i].cartQty}",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            _qty = widget.product.varient[i]
                                                    .cartQty! +
                                                1;

                                            showOnlyLoaderDialog();
                                            ATCMS? isSuccess;
                                            isSuccess = await value.addToCart(
                                                widget.product, _qty, false,
                                                varient:
                                                    widget.product.varient[i]);
                                            if (isSuccess!.isSuccess != null &&
                                                context.mounted) {
                                              Navigator.of(context).pop();
                                            }
                                            showToast(isSuccess.message!);
                                            setState(() {});
                                          },
                                          child: Container(
                                              height: 23,
                                              width: 23,
                                              alignment: Alignment.center,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              child: Icon(
                                                MdiIcons.plus,
                                                size: 17,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int i) {
                          return const Divider();
                        },
                      ),
                    )
                  ],
                ),
              );
            }),
          );
        });
  }
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
