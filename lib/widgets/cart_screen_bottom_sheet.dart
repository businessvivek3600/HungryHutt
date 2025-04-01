import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/widgets/bottom_button.dart';

class CartScreenBottomSheet extends StatefulWidget {
  final CartController? cartController;
  final Function()? onButtonPressed;
  const CartScreenBottomSheet(
      {super.key, this.onButtonPressed, this.cartController});

  @override
  State<CartScreenBottomSheet> createState() => _CartScreenBottomSheetState();
}

class _CartScreenBottomSheetState extends State<CartScreenBottomSheet> {
  _CartScreenBottomSheetState();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Adjust color as needed
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0), // Adjust the radius as needed
          topRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0,
            spreadRadius: 2.0,
            offset: Offset(0, -2), // Moves shadow upwards
          ),
        ],
      ),
      padding: EdgeInsets.all(8.0), // Adjust padding as needed
      child: BottomButton(
        loadingState: false,
        disabledState: false,
        onPressed: () => widget.onButtonPressed!(),
        child: Text("Select Delivery Address"),
      ),
    );
  }
}
