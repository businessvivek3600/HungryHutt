import 'package:flutter/material.dart';

class TipContainer extends StatefulWidget {
  @override
  _TipContainerState createState() => _TipContainerState();
}

class _TipContainerState extends State<TipContainer> {
  int? selectedTip;
  bool isOtherSelected = false;
  TextEditingController tipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tip Title
          Text(
            "Tip",
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          // Tip Description
          const Text(
            "Day & night, our delivery partners bring your favourite meals. Thank them with a tip.",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 12),

          // Tip Amount Options
          Row(
            children: [
              _tipButton(20),
              _tipButton(30),
              _tipButton(50),
              _otherTipButton(),
            ],
          ),
          const SizedBox(height: 12),

          // Show Text Field only when "Other" is selected
          if (isOtherSelected)
            TextField(
              controller: tipController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
              decoration: InputDecoration(
                hintText: "₹ Enter Tip Amount",
                prefixText: "₹ ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tipButton(int amount) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTip = amount;
          isOtherSelected = false;
          tipController.clear(); // Clear custom input if a predefined tip is selected
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedTip == amount ? Colors.orange : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Text("₹$amount", style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _otherTipButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTip = null;
          isOtherSelected = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isOtherSelected ? Colors.orange : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Text("Other", style: const TextStyle(fontWeight: FontWeight.bold)),
            if (isOtherSelected)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: const Icon(Icons.close, size: 16, color: Colors.orange),
              ),
          ],
        ),
      ),
    );
  }
}
