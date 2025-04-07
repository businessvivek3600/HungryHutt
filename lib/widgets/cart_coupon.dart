import 'package:flutter/material.dart';

class CouponPage extends StatelessWidget {
  const CouponPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.9;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("APPLY COUPON",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Your cart: ₹2059.34",
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 8),
              _buildCouponInputField(),
              const SizedBox(height: 16),
              const Text("Applied coupon",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              cartCoupon(cardWidth),
              const SizedBox(height: 16),
              const Text("More offers",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              cartCoupon(cardWidth),
              const SizedBox(height: 8),
              cartCoupon(cardWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponInputField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Enter Coupon Code",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text("APPLY",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }

  SizedBox cartCoupon(double cardWidth) {
    return SizedBox(
      width: cardWidth,
      child: Card(
        color: Colors.white12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Ticket Section with Cutouts
              Stack(
                children: [
                  // White background to prevent transparency issues
                  Container(
                    width: 50,
                    decoration: const BoxDecoration(
                      color: Colors
                          .transparent, // Ensures transparency doesn't show
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  // Ticket with Cutouts
                  ClipPath(
                    clipper: TicketClipper(),
                    child: Container(
                      width: 50,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF68a039), // Green Ticket Color
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: const RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          "BUY 1 GET 1",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Main Content
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'BUY1GET1',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        RichText(
                          text: const TextSpan(
                            text: 'Save ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '₹1029',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' on this order!'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Divider(color: Colors.grey.shade300, thickness: 1),
                        const SizedBox(height: 5),
                        Text(
                          "Add 2 'Buy 1 Get 1' items to get 1 item(s) for free",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                child: const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 12, right: 12),
                    child: Text(
                      "REMOVE",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Ticket Clipper for Cutout Effect
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 10.0; // Radius of the cutouts
    Path path = Path();

    // Create a rectangle for the main ticket shape
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create circular cutouts
    Path cutouts = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(0, size.height * 0.25), radius: radius))
      ..addOval(Rect.fromCircle(
          center: Offset(0, size.height * 0.50), radius: radius))
      ..addOval(Rect.fromCircle(
          center: Offset(0, size.height * 0.75), radius: radius));

    // Subtract the circles from the rectangle
    return Path.combine(PathOperation.difference, path, cutouts);
  }

  @override
  bool shouldReclip(TicketClipper oldClipper) => false;
}
