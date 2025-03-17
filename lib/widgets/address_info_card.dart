import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user/models/address_model.dart';
import 'package:user/screens/add_address_screen.dart';

class AddressInfoCard extends StatefulWidget {
  final bool? isSelected;
  final Address? value;
  final Address? groupValue;
  final Function(Address?)? onChanged;
  final Address? address;
  final dynamic analytics;
  final dynamic observer;

  const AddressInfoCard({
    super.key,
    this.value,
    this.groupValue,
    this.isSelected,
    this.onChanged,
    this.address,
    this.analytics,
    this.observer,
  });

  @override
  State<AddressInfoCard> createState() => _AddressInfoCardState();
}

class _AddressInfoCardState extends State<AddressInfoCard> {
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => widget.onChanged!(widget.value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isSelected == true
              ? Theme.of(context).colorScheme.secondaryContainer.withAlpha(100)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.isSelected == true ? Colors.orange : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            // Address Type Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.near_me, // Location icon
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),

            // Address Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address Name (Bold)
                  Text(
                    widget.address?.type ?? "Address",
                    style: textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Full Address
                  Text(
                    widget.address?.receiverName ?? "",
                    style: textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Receiver Phone Number
                  if (widget.address?.receiverPhone != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.address!.receiverPhone!,
                        style: textTheme.bodySmall!.copyWith(
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  if (widget.address?.fullAddress != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.address!.fullAddress!,
                        style: textTheme.bodySmall!.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Edit Icon
            InkWell(
              onTap: () => Get.to(() => AddAddressScreen(
                widget.address,
                analytics: widget.analytics,
                observer: widget.observer,
                screenId: 0,
              )),
              child: const Icon(
                Icons.chevron_right, // Arrow icon for navigation
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
