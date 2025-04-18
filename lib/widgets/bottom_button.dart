import 'package:flutter/material.dart';

class BottomButton extends StatefulWidget {
  final Widget? child;
  final Function()? onPressed;
  @required
  final bool? loadingState;
  final bool? disabledState;

  const BottomButton({super.key, this.child, this.loadingState, this.disabledState, this.onPressed});
  @override
  State<BottomButton> createState() => _BottomButtonState();
}

class _BottomButtonState extends State<BottomButton> {

  _BottomButtonState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: FilledButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF68a039)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        onPressed: widget.loadingState! || widget.disabledState! ? null : widget.onPressed,
        child: !widget.loadingState!
            ? widget.child
            : const SizedBox(
                height: 20.0,
                width: 20.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF68a039)),
                ),
              ),
      ),
    );
  }
}
