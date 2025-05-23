import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/address_model.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/membership_status_model.dart';
import 'package:user/models/order_model.dart';
import 'package:user/models/time_slot_model.dart';
import 'package:user/screens/add_address_screen.dart';
import 'package:user/screens/membership_screen.dart';
import 'package:user/screens/payment_screen.dart';
import 'package:user/widgets/address_info_card.dart';
import 'package:user/widgets/confirmation_slider.dart';
import 'package:user/widgets/date_time_selector.dart';
import 'package:user/widgets/toastfile.dart';

class CheckoutScreen extends BaseRoute {
  final CartController? cartController;

  const CheckoutScreen({super.key, super.analytics, super.observer, super.routeName = 'CheckoutScreen', this.cartController});

  @override
  BaseRouteState createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState extends BaseRouteState<CheckoutScreen> {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  Address? _selectedAddress = Address();
  List<Address> _addressList = [];
  bool _isLoading = true;
  // final List<TimeSlot>? _timeSlotList = [];
  // DateTime? _selectedDate;
  // TimeSlot? _selectedTimeSlot;
  // late DateTime _openingTime;
  // late DateTime _closingTime;
  // final bool _isClosingTime = false;
  final ScrollController _scrollController = ScrollController();
  Order? orderDetails;

  MembershipStatus? _membershipStatus = MembershipStatus();

  _CheckoutScreenState();
  Future<void> _fetchAddresses() async {
    var addressList = await apiHelper.getAddressList();
    if (addressList != null && addressList.isNotEmpty) {
      setState(() {
        _addressList = addressList;
        _selectedAddress = _addressList.first;
      });


    }
    setState(() {
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle subHeadingStyle = textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
    );
    return PopScope(
      canPop: true,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.btn_proceed_to_checkout,
              style: textTheme.titleLarge,
            ),
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.keyboard_arrow_left)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///---- address container
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width,
                    child: _addressList.isNotEmpty
                        ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: _addressList.length,
                      itemBuilder: (BuildContext ctx, int index) {
                        Address address = _addressList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child:
                                AddressInfoCard(
                                  analytics: widget.analytics,
                                  observer: widget.observer,
                                  key: UniqueKey(),
                                  address: address,
                                  isSelected: _selectedAddress == address,
                                  value: address,
                                  groupValue: _selectedAddress,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedAddress = value!;
                                    });
                                    _selectAddressForCheckout(selectedAddressId:_selectedAddress?.addressId ?? 0 , addressSelected: value);
                                  },
                                ),

                        );
                      },
                    )
                        : TextButton.icon(
                      onPressed: () {
                        Get.to(() => AddAddressScreen(
                          Address(),
                          analytics: widget.analytics,
                          observer: widget.observer,
                          screenId: 0,
                        ))!.then((value) {
                          setState(() {
                            _fetchAddresses(); // Refresh address list after adding
                          });
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: Text(
                        AppLocalizations.of(context)!.tle_add_new_address,
                        style: textTheme.titleMedium!.copyWith(fontSize: 14),
                      ),
                    ),
                  ),


                  /// --commented code
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${AppLocalizations.of(context)!.txt_items_in_cart} ",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${global.cartCount}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.lbl_total_amount} ",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.cartController!.cartItemsList != null
                              ? "${global.appInfo!.currencySign} ${widget.cartController!.cartItemsList!.totalPrice!.toStringAsFixed(2)}"
                              : '${global.appInfo!.currencySign} 0',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ConfirmationSlider(
                        width: MediaQuery.of(context).size.width - 32,
                        height: 60,
                        backgroundColor: const Color(0xffFBE8E6),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        backgroundShape: BorderRadius.circular(5),
                        foregroundShape: BorderRadius.circular(5),
                        text:
                            AppLocalizations.of(context)!.txt_swipe_to_order,
                        onConfirmation: () async {
                          await _makeOrder();
                        })
                  ],
                ),
              ),
            ),   
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
    if (global.nearStoreModel!.storeOpeningTime != null &&
        global.nearStoreModel!.storeOpeningTime != '' &&
        global.nearStoreModel!.storeClosingTime != null &&
        global.nearStoreModel!.storeClosingTime != '') {
      // _openingTime = DateFormat('yyyy-MM-dd hh:mm a')
      //     .parse(global.nearStoreModel!.storeOpeningTime!.toUpperCase());
      // _closingTime = DateFormat('yyyy-MM-dd hh:mm a')
      //     .parse(global.nearStoreModel!.storeClosingTime!.toUpperCase());
    }
  }

  _checkMembershipStatus() async {
    try {
      _membershipStatus = await checkMemberShipStatus(_scaffoldKey);
      if (_membershipStatus!.status == 'running') {
      } else {
        Get.to(() => MemberShipScreen(analytics: widget.analytics, observer: widget.observer));
      }
    } catch (e) {
      debugPrint("Exception - checkout_screen.dart - _checkMembershipStatus():$e");
    }
  }

  // _getTimeSlotList() async {
  //   try {
  //     showOnlyLoaderDialog();
  //     bool isConnected = await br.checkConnectivity();
  //     if (isConnected) {
  //       await apiHelper.getTimeSlot(_selectedDate).then((result) async {
  //         _selectedTimeSlot = TimeSlot();
  //         if (result != null) {
  //           if (result.status == "1") {
  //             _timeSlotList = result.data;
  //             _selectedTimeSlot = _timeSlotList![0];
  //           } else {
  //             showSnackBar(key: _scaffoldKey, snackBarMessage: result.message);
  //             _timeSlotList = [];
  //           }
  //         }
  //         setState(() {});
  //       });
  //     } else {
  //       showNetworkErrorSnackBar(_scaffoldKey);
  //     }
  //     hideLoader();
  //   } catch (e) {
  //     debugPrint("Exception - checkout_screen.dart - _getTimeSlotList():$e");
  //   }
  // }

  _makeOrder() async {
    try {
      if (_selectedAddress == null ||
          (_selectedAddress != null && _selectedAddress?.addressId == null)) {
        showToast(AppLocalizations.of(context)!.txt_select_deluvery_address);
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   backgroundColor: Theme
        //       .of(context)
        //       .colorScheme.primary,
        //   content: Text(
        //     '${AppLocalizations
        //         .of(context)
        //         .txt_select_deluvery_address}',
        //     textAlign: TextAlign.center,
        //   ),
        //   duration: Duration(seconds: 2),
        // ));
      }
      // else if (_selectedDate == null &&
      //     _membershipStatus?.status != 'running') {
      //   // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   //   backgroundColor: Theme
      //   //       .of(context)
      //   //       .colorScheme.primary,
      //   //   content: Text(
      //   //     '${AppLocalizations
      //   //         .of(context)
      //   //         .txt_select_date}',
      //   //     textAlign: TextAlign.center,
      //   //   ),
      //   //   duration: Duration(seconds: 2),
      //   // ));
      //   showToast(AppLocalizations.of(context)!.txt_select_date);
      // } else if (_selectedTimeSlot?.timeslot == null &&
      //     _membershipStatus?.status != 'running') {
      //   // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   //   backgroundColor: Theme
      //   //       .of(context)
      //   //       .colorScheme.primary,
      //   //   content: Text(
      //   //     '${AppLocalizations
      //   //         .of(context)
      //   //         .txt_select_time_slot}',
      //   //     textAlign: TextAlign.center,
      //   //   ),
      //   //   duration: Duration(seconds: 2),
      //   // ));
      //   showToast(AppLocalizations.of(context)!.txt_select_time_slot);
      // }
      else {
        // debugPrint(_selectedTimeSlot.timeslot);
        showOnlyLoaderDialog();
        bool isConnected = await br.checkConnectivity();
        if (isConnected) {
          await apiHelper
              .makeOrder(

                )
              .then((result) async {
            if (result != null) {
              if (result.status == "1") {
                orderDetails = result.data;
                hideLoader();
                Get.to(() => PaymentGatewayScreen(
                    analytics: widget.analytics,
                    observer: widget.observer,
                    screenId: 1,
                    totalAmount: orderDetails!.remPrice,
                    cartController: widget.cartController,
                    order: orderDetails));
              } else {
                hideLoader();
                showToast(result.message);
                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //   backgroundColor: Theme
                //       .of(context)
                //       .colorScheme.primary,
                //   content: Text(
                //     result.message,
                //     textAlign: TextAlign.center,
                //   ),
                //   duration: Duration(seconds: 2),
                // ));
              }
            }
          });
        } else {
          showNetworkErrorSnackBar(_scaffoldKey);
        }
      }
    } catch (e) {
      debugPrint("Exception - checkout_screen.dart - _makeOrder():$e");
    }
  }

  _selectAddressForCheckout(
      {int? selectedAddressId, Address? addressSelected, int? index}) async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        showOnlyLoaderDialog();
        await apiHelper
            .selectAddressForCheckout(selectedAddressId)
            .then((result) async {
          hideLoader();
          if (result != null) {
            if (result.status == "1") {
              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //   backgroundColor: Theme
              //       .of(context)
              //       .colorScheme.primary,
              //   content: Text(
              //     result.message,
              //     textAlign: TextAlign.center,
              //   ),
              //   duration: Duration(seconds: 2),
              // ));
              showToast(result.message);
              setState(() {
                _selectedAddress = addressSelected;
                global.userProfileController.addressList[index!].isSelected =
                !global
                    .userProfileController.addressList[index].isSelected;
              });
            } else {
              showToast(result.message);
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - checkout_screen.dart - _selectAddressForCheckout():$e");
    }
  }
}




 ///_commented code-
// _isClosingTime == false &&
//         global.nearStoreModel?.storeOpeningTime != null &&
//     (global.nearStoreModel?.storeOpeningTime?.isNotEmpty ?? false) &&
//         global.nearStoreModel!.storeClosingTime != null &&
//     (global.nearStoreModel?.storeClosingTime?.isNotEmpty ?? false) &&
//         DateTime.now().isAfter(_openingTime) &&
//         DateTime.now().isBefore(
//             _closingTime.subtract(const Duration(hours: 1)))
//     ? SizedBox(
//         height: 50,
//         width: double.infinity,
//         child: SwitchListTile(
//           tileColor: Theme.of(context).colorScheme.primaryContainer,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10)),
//           value: _membershipStatus!.status == 'running'
//               ? true
//               : false,
//           activeColor: Theme.of(context).colorScheme.primary,
//           onChanged: (val) async {
//             if (_isClosingTime == false &&
//                 global.nearStoreModel?.storeOpeningTime !=
//                     null &&
//                 (global.nearStoreModel?.storeOpeningTime?.isNotEmpty ?? false) &&
//                 global.nearStoreModel?.storeClosingTime !=
//                     null &&
//                 global.nearStoreModel?.storeClosingTime !=
//                     '' &&
//                 DateTime.now().isAfter(_openingTime) &&
//                 DateTime.now().isBefore(_closingTime
//                     .subtract(const Duration(hours: 1)))) {
//               if (val) {
//                 await _checkMembershipStatus();
//               } else {
//                 _membershipStatus!.status = 'Pending';
//                 if (_scrollController.hasClients) {
//                   Future.delayed(const Duration(milliseconds: 50),
//                       () {
//                     _scrollController.jumpTo(_scrollController
//                         .position.maxScrollExtent);
//                   });
//                 }
//               }
//             } else {
//               _isClosingTime = true;
//             }
//
//             setState(() {});
//           },
//           title: Text(
//             _membershipStatus!.status == 'running'
//                 ? AppLocalizations.of(context)!.btn_instant_delivery
//                 : AppLocalizations.of(context)!.btn_req_instant_delivery,
//             style: Theme.of(context)
//                 .textTheme
//                 .labelLarge?.copyWith(fontSize: 15, color: Theme.of(context).colorScheme.onPrimaryContainer),
//           ),
//         ),
//       )
//     : SizedBox(
//         height: 60,
//         width: double.infinity,
//         child: Card(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10)),
//             child: const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Text(
//                   'Instant delivery not available as store closing time is near.'),
//             ))),
// _membershipStatus!.status != 'running'
//     ? Padding(
//         padding:
//             const EdgeInsets.only(top: 24.0, bottom: 8.0),
//         child: Text(
//           AppLocalizations.of(context)!.txt_preferred_time,
//           style: subHeadingStyle,
//         ),
//       )
//     : const SizedBox(),
// _membershipStatus!.status != 'running'
//     ? Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           InkWell(
//             onTap: () async {
//               _selectedDate = await showDatePicker(
//                 context: context,
//                 firstDate:
//                     DateTime.now().add(const Duration(days: 1)),
//                 initialDate:
//                     DateTime.now().add(const Duration(days: 1)),
//                 lastDate:
//                     DateTime.now().add(const Duration(days: 10)),
//                 initialDatePickerMode: DatePickerMode.day,
//                 currentDate:
//                     DateTime.now().add(const Duration(days: 1)),
//                 builder:
//                     (BuildContext context, Widget? child) {
//                   return Theme(
//                     data: Theme.of(context),
//                     child: child!,
//                   );
//                 },
//               );
//               if (_selectedDate != null) {
//                 await _getTimeSlotList();
//               }
//               setState(() {});
//             },
//             child: DateTimeSelector(
//               key: UniqueKey(),
//               heading:
//                   "${AppLocalizations.of(context)!.lbl_date} ",
//               selectedDate: _selectedDate,
//             ),
//           ),
//           const SizedBox(
//             width: 10,
//           ),
//           Expanded(
//             child: Container(
//               height: 80,
//               color: Theme.of(context).colorScheme.secondaryContainer,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       '${AppLocalizations.of(context)!.txt_time} ',
//                       style: textTheme.bodySmall,
//                     ),
//                     const Spacer(),
//                     SizedBox(
//                       height: 40,
//                       child: Center(
//                         child: DropdownButton(
//                           value: _selectedTimeSlot,
//                           isExpanded: false,
//                           isDense: true,
//                           icon: Icon(
//                             Icons.keyboard_arrow_down,
//                             color: Theme.of(context).colorScheme.onSecondaryContainer,
//                           ),
//                           underline: const SizedBox(),
//                           hint: Text(
//                             '${AppLocalizations.of(context)!.lbl_select_time_slot} ',
//                             style:
//                                 textTheme.bodyLarge!.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           items: _timeSlotList!.map<
//                                   DropdownMenuItem<TimeSlot>>(
//                               (TimeSlot timeSlot) {
//                             return DropdownMenuItem<TimeSlot>(
//                               value: timeSlot,
//                               enabled:
//                                   timeSlot.availibility ==
//                                           "available"
//                                       ? true
//                                       : false,
//                               child: Text(
//                                 timeSlot.timeslot!,
//                                 style: timeSlot
//                                             .availibility ==
//                                         "available"
//                                     ? textTheme.bodyLarge!
//                                         .copyWith(
//                                         fontWeight:
//                                             FontWeight.bold,
//                                       )
//                                     : textTheme.bodyLarge!
//                                         .copyWith(
//                                         color:
//                                             Colors.grey[400],
//                                       ),
//                               ),
//                             );
//                           }).toList(),
//                           onChanged: (dynamic value) {
//                             setState(() {
//                               _selectedTimeSlot = value;
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ],
//       )
//     : const SizedBox(),