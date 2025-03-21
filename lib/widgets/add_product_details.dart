import 'package:user/models/businessLayer/global.dart' as global;
import 'package:flutter/material.dart';
import 'package:user/models/category_product_model.dart';
import 'package:user/widgets/gradient_heading_row.dart';

List<String> vegPizzaToppings = [
  "Mozzarella",
  "Cheddar",
  "Olives",
  "Jalapenos",
  "Paneer",
  "Mushrooms",
  "Capsicum",
  "Onion",
  "Tomato",
  "Sweet Corn",
];
List<String> nonVegPizzaToppings = [
  "Pepperoni",
  "Chicken Tikka",
  "BBQ Chicken",
  "Spicy Sausage",
  "Ham",
  "Bacon",
];
List<Map<String, String>> variantOptions = [
  {"title": "Regular (serve 1,17cm)", "price": "₹ 245"},
  {"title": "Medium (serve 2,25cm)", "price": "₹ 545"},
  {"title": "Large (serve 4,33cm)", "price": "₹ 645"},
  {"title": "Giant (serve 8,45cm)", "price": "₹ 945"},
];

class ProductBottomSheet extends StatefulWidget {
  final Product product;

  const ProductBottomSheet({super.key, required this.product});

  @override
  _ProductBottomSheetState createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ProductBottomSheet> {
  int selectedVariant = 1;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DraggableScrollableSheet(
          initialChildSize: 0.86,
          minChildSize: 0.86,
          maxChildSize:0.86,
          builder: (context, scrollController) {
            return Container(
              margin: EdgeInsets.only(top: 0),
              decoration:  BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(20)),
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
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _buildBadge("Bestseller", Colors.green.shade800),
                                      const SizedBox(width: 5),
                                      _buildBadge("New", Colors.orange),
                                    ],
                                  ),
                                  const SizedBox(height: 5),

                                  // Product Title, Price & Description
                                  Text(
                                    widget.product.productName!,
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  Text("Customisable",
                                      style: TextStyle(
                                          color: Colors.grey.shade500, fontSize: 10)),
                                  Text(
                                      "${global.appInfo!.currencySign} ${widget.product.price}",
                                      style: const TextStyle(fontSize: 14)),
                                  const SizedBox(height: 10),
                                  _buildExpandableText(widget.product.description!),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Badges




                          const SizedBox(height: 20),
                          buildGradientHeadingRow(context, "CHOOSE A VARIANT"),

                          // Variant Grid
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

                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text("Add",
                                style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
              child: Image.asset("assets/images/close.png",height: 10,
              width: 10,fit: BoxFit.cover,),
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
