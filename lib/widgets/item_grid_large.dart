import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/widgets/gradient_heading_row.dart';
import 'package:user/widgets/tag_container.dart';
import '../models/category_product_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'add_product_details.dart';

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
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double childAspectRatio = screenWidth < 600 ? 0.65 : 0.68;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildGradientHeadingRow(context, widget.title),
        GridView.builder(
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
            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        global.appInfo!.imageUrl! + product.productImage!,
                        fit: BoxFit.cover,
                        height: 120,
                        width: 140,
                      ),
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
                                  borderRadius:
                                  BorderRadius.circular(3.0),

                                  color: Colors.transparent,
                                  border: Border.all(color: Colors.green, width: 2),),
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
                              buildBadge("Bestseller",
                                  Colors.green.shade800),
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
                                  fontWeight: FontWeight.w600
                                ),
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
                            child: GestureDetector(
                                onTap: () {
                                  showProductBottomSheet(context,product);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xffe54740),
                                          width: 0.5)),
                                  child: const Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Add",
                                            style: TextStyle(
                                                color: Color(0xffe54740),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                        SizedBox(width: 4),
                                        Icon(Icons.add,
                                            color: Color(0xffe54740), size: 16),

                                        // Space between text and icon
                                      ],
                                    ),
                                  ),
                                )),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
