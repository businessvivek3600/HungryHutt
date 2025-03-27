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
import 'package:user/widgets/toastfile.dart';

import 'add_product_details.dart';

class BundleOffersMenu extends StatefulWidget {
  final dynamic analytics;
  final dynamic observer;
  final List<Product>? categoryProductList;
  final Function(int)? onSelected;

  const BundleOffersMenu(
      {super.key,
      this.onSelected,
      this.categoryProductList,
      this.analytics,
      this.observer});

  @override
  State<BundleOffersMenu> createState() => _BundleOffersMenuState();
}

class BundleOffersMenuItem extends StatefulWidget {
  final Product product;

  final dynamic analytics;
  final dynamic observer;
  const BundleOffersMenuItem(
      {super.key, required this.product, this.analytics, this.observer});

  @override
  State<BundleOffersMenuItem> createState() => _BundleOffersMenuItemState();
}

class _BundleOffersMenuItemState extends State<BundleOffersMenuItem> {
  final CartController cartController = Get.put(CartController());

  int? _qty;
  _BundleOffersMenuItemState();
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.6,
      child: GetBuilder<CartController>(
        init: cartController,
        builder: (value) => GestureDetector(
          onTap: () {
            showProductBottomSheet(context,widget.product);
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
            elevation: 2,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    global.appInfo!.imageUrl! + widget.product.productImage!,
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                ),
                borderRadius: BorderRadius.circular(14.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Text(
                  //   widget.product.productName!,
                  //   overflow: TextOverflow.ellipsis,
                  //   maxLines: 1,
                  //   style: textTheme.bodyLarge!.copyWith(
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 16,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  // const SizedBox(height: 5),
                  //
                  // Text(
                  //   widget.product.description ?? '',
                  //   maxLines: 2,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: textTheme.bodySmall!.copyWith(
                  //     fontSize: 12,
                  //     color: Colors.white, // ✅ Set text color to white
                  //   ),
                  // ),
                  //
                  // const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${global.appInfo!.currencySign} ${widget.product.price}",
                        style: textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white, // ✅ Set text color to white
                        ),
                      ),
                      // widget.product.price != widget.product.mrp
                      //     ? Text(
                      //   "${global.appInfo!.currencySign}${widget.product.mrp}",
                      //   style: textTheme.labelSmall!.copyWith(
                      //     decoration: TextDecoration.lineThrough,
                      //     fontSize: 12,
                      //     color: Colors.redAccent,
                      //   ),
                      // )
                      //     : const SizedBox(),
                      GestureDetector(
                        onTap: () {
                          showProductBottomSheet(context,widget.product);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white, // White background
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            border: Border.all(color: const Color(0xffe54740), width: 0.5), // Green border
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12, // Shadow color
                                blurRadius: 2, // Slight shadow effect
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Add", style: TextStyle(color: Color(0xffe54740), fontSize: 12,fontWeight: FontWeight.w600)),
                              SizedBox(width: 4), // Space between text and icon
                              Icon(Icons.add, color: Color(0xffe54740), size: 16),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
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

  _showVarientModalBottomSheet(TextTheme textTheme, CartController value) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return GetBuilder<CartController>(
            init: cartController,
            builder: (value) => SizedBox(
              height: 200,
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
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: widget.product.varient.length,
                    itemBuilder: (BuildContext context, int i) {
                      return ListTile(
                        title: ReadMoreText(
                          '${widget.product.varient[i].description}',
                          trimLines: 2,
                          trimMode: TrimMode.Line,
                          trimCollapsedText:
                              AppLocalizations.of(context)!.txt_show_more,
                          trimExpandedText:
                              AppLocalizations.of(context)!.txt_show_less,
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
                            '${widget.product.varient[i].quantity} ${widget.product.varient[i].unit} / ${global.appInfo!.currencySign} ${widget.product.varient[i].price}  ',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontSize: 15)),
                        trailing: widget.product.varient[i].cartQty == null ||
                                widget.product.varient[i].cartQty == 0
                            ? InkWell(
                                onTap: () async {
                                  if (global.currentUser!.id == null) {
                                    Get.to(LoginScreen(
                                      analytics: widget.analytics,
                                      observer: widget.observer,
                                    ));
                                  } else {
                                    _qty = 1;
                                    showOnlyLoaderDialog();
                                    ATCMS? isSuccess;
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
                                      .primaryContainer,
                                  child: Icon(
                                    Icons.add,
                                    size: 17.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        if (widget.product.varient[i].cartQty !=
                                                null &&
                                            widget.product.varient[i].cartQty ==
                                                1) {
                                          _qty = 0;
                                        } else {
                                          _qty = widget
                                                  .product.varient[i].cartQty! -
                                              1;
                                        }

                                        showOnlyLoaderDialog();
                                        ATCMS? isSuccess;
                                        isSuccess = await value.addToCart(
                                            widget.product, _qty, true,
                                            varient: widget.product.varient[i]);

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
                                          child: widget.product.varient[i]
                                                      .cartQty ==
                                                  1
                                              ? Icon(
                                                  Icons.delete,
                                                  size: 17.0,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                                )
                                              : Icon(
                                                  MdiIcons.minus,
                                                  size: 17.0,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer,
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
                                              .primary,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(
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
                                                .primary,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        _qty =
                                            widget.product.varient[i].cartQty! +
                                                1;

                                        showOnlyLoaderDialog();
                                        ATCMS? isSuccess;
                                        isSuccess = await value.addToCart(
                                            widget.product, _qty, false,
                                            varient: widget.product.varient[i]);
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
                  )
                ],
              ),
            ),
          );
        });
  }
}

class _BundleOffersMenuState extends State<BundleOffersMenu> {
  APIHelper apiHelper = APIHelper();

  _BundleOffersMenuState();

  Future<bool> addRemoveWishList(int? varientId) async {
    bool isAddedSuccesFully = false;
    try {
      showOnlyLoaderDialog();
      await apiHelper.addRemoveWishList(varientId).then((result) async {
        if (result != null) {
          if (!mounted) return;
          if (result.status == "1" || result.status == "2") {
            isAddedSuccesFully = true;
            Navigator.pop(context);
          } else {
            isAddedSuccesFully = false;
            Navigator.pop(context);

            showSnackBar(
                snackBarMessage:
                    '${AppLocalizations.of(context)!.txt_please_try_again_after_sometime} ');
          }
        }
      });
      return isAddedSuccesFully;
    } catch (e) {
      debugPrint(
          "Exception - bundle_offers_menu.dart - addRemoveWishList():$e");
      return isAddedSuccesFully;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: MediaQuery.of(context).size.width * 1 / 2 / 1,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.categoryProductList!.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => Get.to(() => ProductDescriptionScreen(
                  analytics: widget.analytics,
                  observer: widget.observer,
                  productId: widget.categoryProductList![index].productId)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    BundleOffersMenuItem(
                      product: widget.categoryProductList![index],
                      analytics: widget.analytics,
                      observer: widget.observer,
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: widget.categoryProductList![index].discount !=
                                    null &&
                                widget.categoryProductList![index].discount! > 0
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(5.0),

                                    color: Colors.transparent,
                                    border: Border.all(color: Colors.green, width: 2),),
                                  padding: const EdgeInsets.all(2),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.categoryProductList![index].productName!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                            : const SizedBox(
                                height: 16,
                                width: 60,
                              ),
                      ),
                    ),
                // Positioned(
                //   right: 0,
                //   top: 0,
                //       child: Container(
                //         height: 16,
                //         width: 60,
                //         decoration: BoxDecoration(
                //           color: Theme.of(context)
                //               .colorScheme
                //               .primaryContainer,
                //           borderRadius: const BorderRadius.only(
                //             topLeft: Radius.circular(4),
                //             bottomRight: Radius.circular(4),
                //           ),
                //         ),
                //         child: Text(
                //           "${widget.categoryProductList![index].discount} % OFF",
                //           textAlign: TextAlign.center,
                //           style: Theme.of(context)
                //               .primaryTextTheme
                //               .bodySmall!
                //               .copyWith(
                //             color: Theme.of(context)
                //                 .colorScheme
                //                 .onPrimaryContainer,
                //           ),
                //         ),
                //       ),
                //     ),
                    // Positioned(
                    //   right: 0,
                    //   top: 0,
                    //   child: IconButton(
                    //     icon: widget.categoryProductList![index].isFavourite
                    //         ? Icon(
                    //             MdiIcons.heart,
                    //             size: 20,
                    //             color: Colors.red,
                    //           )
                    //         : Icon(
                    //             MdiIcons.heartOutline,
                    //             size: 20,
                    //             color: Colors.red,
                    //           ),
                    //     onPressed: () async {
                    //       if (global.currentUser!.id == null) {
                    //         Future.delayed(Duration.zero, () {
                    //           if (!context.mounted) return;
                    //           Navigator.of(context).push(
                    //             MaterialPageRoute(
                    //                 builder: (context) => LoginScreen(
                    //                       analytics: widget.analytics,
                    //                       observer: widget.observer,
                    //                     )),
                    //           );
                    //         });
                    //       } else {
                    //         bool isAdded = await addRemoveWishList(
                    //           widget.categoryProductList![index].varientId,
                    //         );
                    //         if (isAdded) {
                    //           widget.categoryProductList![index].isFavourite =
                    //               !widget
                    //                   .categoryProductList![index].isFavourite;
                    //         }
                    //
                    //         setState(() {});
                    //       }
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          }),
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
