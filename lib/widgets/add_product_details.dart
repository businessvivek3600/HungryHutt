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
  bool showLeadingIcon = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 100 && !showLeadingIcon) {
      setState(() {
        showLeadingIcon = true;
      });
    } else if (_scrollController.offset <= 100 && showLeadingIcon) {
      setState(() {
        showLeadingIcon = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            _scrollController = scrollController; // Assign the controller

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  expandedHeight: 250,
                  backgroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.network(
                      global.appInfo!.imageUrl! + widget.product.productImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              "${global.appInfo!.currencySign} ${widget.product.price}",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.product.description!,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            buildGradientHeadingRow(context, "CHOOSE A VARIANT"),
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
                            const Text(
                              "Upgrade Your Base - Regular",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              "you can choose up to 1 options(s)",
                              style:
                              TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                            const SizedBox(height: 10),
                            checkBoxRowVarient("Double Cheese", "₹410", true),
                            const SizedBox(height: 5),
                            checkBoxRowVarient(
                                "Ultra thin Crust Pizza - Regular Pizza",
                                "₹560",
                                true),
                            const SizedBox(height: 20),
                            const Text(
                              "Toppings-veg[Regular]",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              "you can choose up to 4 options(s)",
                              style:
                              TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                            Column(
                              children: List.generate(
                                vegPizzaToppings.length,
                                    (index) => Column(
                                  children: [
                                    const SizedBox(height: 5),
                                    checkBoxRowVarient(
                                        vegPizzaToppings[index], "₹5$index", true),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Toppings-Non-veg[Regular]",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              "you can choose up to 3 options(s)",
                              style:
                              TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                            Column(
                              children: List.generate(
                                nonVegPizzaToppings.length,
                                    (index) => Column(
                                  children: [
                                    checkBoxRowVarient(
                                        nonVegPizzaToppings[index], "₹7$index", false),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                "Add",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        // Close Button
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
              child: const Icon(Icons.close, size: 30),
            ),
          ),
        ),

        // Show leading icon when scrolled
        if (showLeadingIcon)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back, color: Colors.white),
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
    backgroundColor: Colors.grey.shade100,
    builder: (context) {
      return ProductBottomSheet(product: product);
    },
  );
}


Card radioVarientButton(String title, String price, int value, int groupValue, void Function(int?) onChanged) {
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
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
