import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:flutter/material.dart';
import 'package:user/models/category_product_model.dart';
import 'package:user/widgets/gradient_heading_row.dart';

import '../constants/statc_food_variant.dart';
import '../controllers/cart_controller.dart';
import '../models/addtocartmessagestatus.dart';

class ProductBottomSheet extends StatefulWidget {
  final Product product;

  const ProductBottomSheet({super.key, required this.product});

  @override
  _ProductBottomSheetState createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ProductBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> showAppBarNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    double triggerOffset = 300; // Adjust based on when the title disappears
    if (_scrollController.offset >= triggerOffset &&
        !showAppBarNotifier.value) {
      showAppBarNotifier.value = true;
    } else if (_scrollController.offset < triggerOffset &&
        showAppBarNotifier.value) {
      showAppBarNotifier.value = false;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    showAppBarNotifier.dispose();
    super.dispose();
  }

  int selectedVariant = 1;
  bool _isExpanded = false;
  final siteUrl = "https://hungryhutt.com/";
  Future<void> _shareProduct() async {
    try {
      // Construct the image URL
      String imageUrl =
          global.appInfo!.imageUrl! + widget.product.productImage!;

      // Download the image from the URL
      final http.Response response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Convert response body to Uint8List
        Uint8List byteList = response.bodyBytes;

        // Get the temporary directory
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/product.png');

        // Write image to file
        await file.writeAsBytes(byteList);

        // Convert file to XFile
        final XFile xFile = XFile(file.path);

        // Product details as text
        String productText = """
        Checkout ${widget.product.productName} by Hungry Hutt:$siteUrl
         """;

        // Share image and text
        await Share.shareXFiles([xFile], text: productText);
      } else {
        print("Failed to download image: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sharing product: $e");
    }
  }

  final CartController cartController = Get.find<CartController>();
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DraggableScrollableSheet(
          initialChildSize: 0.86,
          minChildSize: 0.86,
          maxChildSize: 0.86,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ValueListenableBuilder<bool>(
                valueListenable: showAppBarNotifier,
                builder: (context, showAppBar, child) {
                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      if (showAppBar)
                        SliverAppBar(
                          backgroundColor: Colors.white,
                          pinned: true,
                          elevation: 8,
                          expandedHeight: 60,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                global.appInfo!.imageUrl! +
                                    widget.product.productImage!,
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ),
                          title: Text(
                            widget.product.productName!,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.share_outlined,
                                  color: Colors.black),
                              onPressed: _shareProduct,
                            ),
                          ],
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Product InfoCard
                              Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                      child: Image.network(
                                        global.appInfo!.imageUrl! +
                                            widget.product.productImage!,
                                        fit: BoxFit.cover,
                                        height: 250,
                                        width: double.infinity,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              _buildBadge("Bestseller",
                                                  Colors.green.shade800),
                                              const SizedBox(width: 5),
                                              _buildBadge("New", Colors.orange),
                                            ],
                                          ),
                                          const SizedBox(height: 5),

                                          /// **👀 This is the Title Row That Triggers the SliverAppBar**
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                widget.product.productName!,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.share_outlined,
                                                    color:
                                                        Colors.black),
                                                onPressed: _shareProduct,
                                              ),
                                            ],
                                          ),

                                          Text("Customisable",
                                              style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 10)),
                                          Text(
                                            "${global.appInfo!.currencySign} ${widget.product.price}",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(height: 10),
                                          _buildExpandableText(
                                              widget.product.description!),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),

                              /// Other UI Elements
                              const SizedBox(height: 20),
                              buildGradientHeadingRow(
                                  context, "CHOOSE A VARIANT"),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1.5,
                                ),
                                itemCount: variantOptions.length,
                                itemBuilder: (context, index) {
                                  return radioVarientButton(
                                    variantOptions[index]["title"]!,
                                    variantOptions[index]["price"]!,
                                    index,
                                    selectedVariant,
                                    (val) {
                                      setState(() {
                                        selectedVariant = val!;
                                      });
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildUpgradeOptions(),
                              const SizedBox(height: 20),
                              _buildToppings(
                                  "Toppings-veg[Regular]", vegPizzaToppings, 4),
                              const SizedBox(height: 20),
                              _buildToppings("Toppings-Non-veg[Regular]",
                                  nonVegPizzaToppings, 3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),

        /// Close Button
        Positioned(
          top: 10,
          left: MediaQuery.of(context).size.width / 2 - 25,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.close, color: Colors.black),
            ),
          ),
        ),

        /// Bottom Action Button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -1),
                  blurRadius: 6,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {

                ATCMS? response = await cartController.addToCart(
                  widget.product, // Product to add
                  1, // Quantity
                  false, // isDel (false because we are adding, not deleting)
                );

                if (response != null && response.isSuccess == true) {
                  Get.snackbar("Success", "Product added to cart!",
                      backgroundColor: Colors.green, colorText: Colors.white);
                } else {
                  Get.snackbar(
                      "Error", response?.message ?? "Failed to add product",
                      backgroundColor: Colors.red, colorText: Colors.white);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Add",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widgets
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(3)),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildExpandableText(String description) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              maxLines: _isExpanded ? null : 4,
              overflow:
                  _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded ? "Show Less" : "Show More",
                style: const TextStyle(
                    color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUpgradeOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upgrade Your Base - Regular",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Text("you can choose up to 1 option(s)",
            style: TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 10),
        checkBoxRowVarient("Double Cheese", "₹410", true),
        const SizedBox(height: 5),
        checkBoxRowVarient("Ultra Thin Crust Pizza - Regular", "₹560", true),
      ],
    );
  }

  Widget _buildToppings(String title, List<String> toppings, int maxOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text("you can choose up to $maxOptions option(s)",
            style: const TextStyle(color: Colors.black54, fontSize: 12)),
        Column(
          children: List.generate(
            toppings.length,
            (index) => Column(
              children: [
                const SizedBox(height: 5),
                checkBoxRowVarient(toppings[index], "₹${5 + index}", true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Function to Show BottomSheet
void showProductBottomSheet(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: ProductBottomSheet(product: product),
      );
    },
  );
}

Card radioVarientButton(String title, String price, int value, int groupValue,
    void Function(int?) onChanged) {
  return Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Colors.green, width: 1.5),
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Radio(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
        ],
      ),
    ),
  );
}

Card checkBoxRowVarient(String title, String price, bool veg) {
  return Card(
    elevation: 2,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: Colors.transparent,
                  border: Border.all(
                      color: veg ? Colors.green : Colors.red, width: 2),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: veg ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Row(
            children: [
              Text(
                price,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
              ),
              SizedBox(
                height: 15,
                child: Checkbox(
                  value: true, // Set initial value
                  onChanged: (bool? newValue) {
                    // Handle checkbox state change
                  },
                  activeColor: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
