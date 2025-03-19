import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/models/address_model.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/society_model.dart';
import 'package:user/widgets/bottom_button.dart';
import 'package:user/widgets/my_text_field.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class AddAddressScreen extends BaseRoute {
  final Address? address;
  final int? screenId;
  const AddAddressScreen(this.address,
      {super.key,
      super.analytics,
      super.observer,
      super.routeName = 'AddAddressScreen',
      this.screenId});
  @override
  BaseRouteState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends BaseRouteState<AddAddressScreen> {
  Position? _currentPosition;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  final _cAddress = TextEditingController();
  final _cLandmark = TextEditingController();
  final _cPincode = TextEditingController();
  final _cState = TextEditingController();
  final _cCity = TextEditingController();
  final _cName = TextEditingController();
  final _cPhone = TextEditingController();
  final _cSociety = TextEditingController();
  final _cSearchSociety = TextEditingController();
  final _fSociety = FocusNode();
  final _fName = FocusNode();
  final _fPhone = FocusNode();
  final _fAddress = FocusNode();
  final _fLandmark = FocusNode();
  final _fPincode = FocusNode();
  final _fState = FocusNode();
  final _fCity = FocusNode();
  final _fDismiss = FocusNode();
  GlobalKey<ScaffoldState>? _scaffoldKey;
  Society? _selectedSociety = Society();
  String type = 'Home';
  bool _isDataLoaded = false;
  List<Society>? _societyList = [];
  final List<Society> _tSocietyList = [];
  final _fSearchSociety = FocusNode();

  _AddAddressScreenState() : super();
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId("current_location"),
            position: LatLng(position.latitude, position.longitude),
            draggable: true,
            onDragEnd: (newPosition) {
              _updateAddress(newPosition.latitude, newPosition.longitude);
            },
          ),
        );
      });

      _updateAddress(position.latitude, position.longitude);

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  /// **Convert Latitude/Longitude to Address & Update Fields**
  Future<void> _updateAddress(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        setState(() {
          _cAddress.text =
              "${place.name}, ${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}";
          _cCity.text = place.locality ?? "";
          _cState.text = place.administrativeArea ?? "";
          _cPincode.text = place.postalCode ?? "";
        });
      }
    } catch (e) {
      debugPrint("Error getting address: $e");
    }
  }

  /// **Open Full Screen Map for Location Selection**
  Future<void> _openMapScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialPosition: _currentPosition != null
              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
              : const LatLng(30.7333, 76.7794),
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        LatLng selectedLatLng = result["latLng"];
        _currentPosition = Position(
          latitude: selectedLatLng.latitude,
          longitude: selectedLatLng.longitude,
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          timestamp: DateTime.now(),
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId("selected_location"),
            position: selectedLatLng,
            draggable: true,
            onDragEnd: (newPosition) {
              _updateAddress(newPosition.latitude, newPosition.longitude);
            },
          ),
        );
      });

      /// Update Address Fields
      _cAddress.text = result["address"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.keyboard_arrow_left,
            ),
          ),
          title: widget.address!.addressId == null
              ? Text(
                  AppLocalizations.of(context)!.tle_add_new_address,
                  style: Theme.of(context).textTheme.titleLarge,
                )
              : Text(
                  AppLocalizations.of(context)!.tle_edit_address,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
        ),
        body: SafeArea(
            child: global.nearStoreModel != null &&
                    global.nearStoreModel!.id != null
                ? _isDataLoaded
                    ? SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: 150,
                              child: _currentPosition == null
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                            _currentPosition!.latitude,
                                            _currentPosition!.longitude),
                                        zoom: 15,
                                      ),
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        _mapController = controller;
                                        // Move camera after map is created
                                        _mapController!.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                              target: LatLng(
                                                  _currentPosition!.latitude,
                                                  _currentPosition!.longitude),
                                              zoom: 15,
                                            ),
                                          ),
                                        );
                                      },
                                      markers: _markers,
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _openMapScreen,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              color: Colors.red),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _cAddress.text.isNotEmpty
                                                  ? _cAddress.text
                                                  : "Tap here to select a location",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color:
                                                      _cAddress.text.isNotEmpty
                                                          ? Colors.black
                                                          : Colors.grey),
                                            ),
                                          ),
                                          const Icon(Icons.edit,
                                              color: Colors.blue),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  _buildTextField(_cName, "Name", true),
                                  _buildTextField(_cPhone, "Phone Number", true,
                                      keyboardType: TextInputType.phone),
                                  _buildTextField(_cAddress, "Address", true),
                                  _buildTextField(
                                      _cLandmark, "Landmark (Optional)", false),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            ListTile(
                              title: Text(
                                AppLocalizations.of(context)!.lbl_save_address,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    child: InkWell(
                                      onTap: () {
                                        type = 'Home';
                                        setState(() {});
                                      },
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              color: type == 'Home'
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .scaffoldBackgroundColor),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 4),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "${AppLocalizations.of(context)!.txt_home} ",
                                            style: TextStyle(
                                              color: type == 'Home'
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: type == 'Home'
                                                  ? FontWeight.w400
                                                  : FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          )),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      type = 'Office';
                                      setState(() {});
                                    },
                                    customBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                            color: type == 'Office'
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .scaffoldBackgroundColor),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${AppLocalizations.of(context)!.txt_office} ",
                                          style: TextStyle(
                                            color: type == 'Office'
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: type == 'Office'
                                                ? FontWeight.w400
                                                : FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    child: InkWell(
                                      onTap: () {
                                        type = 'Others';
                                        setState(() {});
                                      },
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              color: type == 'Others'
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .scaffoldBackgroundColor),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 4),
                                          alignment: Alignment.center,
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .txt_others,
                                              style: TextStyle(
                                                color: type == 'Others'
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: type == 'Others'
                                                    ? FontWeight.w400
                                                    : FontWeight.w700,
                                                fontSize: 13,
                                              ))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : _shimmerList()
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(global.locationMessage!),
                    ),
                  )),
        bottomNavigationBar: _isDataLoaded
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: BottomButton(
                    key: UniqueKey(),
                    loadingState: false,
                    disabledState: false,
                    onPressed: () {
                      _save();
                    },
                    child:
                        Text(AppLocalizations.of(context)!.btn_save_address)),
              )
            : null,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    if (global.nearStoreModel != null && global.nearStoreModel!.id != null) {
      _init();
    }
  }

  _fillData() {
    try {
      _cName.text = widget.address!.receiverName!;
      _cPhone.text = widget.address!.receiverPhone!;
      // _cPincode.text = widget.address!.pincode!;
      _cAddress.text = widget.address!.houseNo!;
      // _cSociety.text = widget.address!.society!;
      // _cState.text = widget.address!.state!;
      // _cCity.text = widget.address!.city!;
      _cLandmark.text = widget.address!.landmark!;
    } catch (e) {
      debugPrint("Excetion - addAddessScreen.dart - _fillData():$e");
    }
  }

  // _getSocietyList() async {
  //   try {
  //     bool isConnected = await br.checkConnectivity();
  //     if (isConnected) {
  //       await apiHelper.getSocietyForAddress().then((result) async {
  //         if (result != null) {
  //           if (result.status == "1") {
  //             _societyList = result.data;
  //             _tSocietyList.addAll(_societyList!);
  //           }
  //         }
  //       });
  //     } else {
  //       showNetworkErrorSnackBar(_scaffoldKey);
  //     }
  //   } catch (e) {
  //     debugPrint("Exception - add_address_screen.dart -  _getSocietyList():$e");
  //   }
  // }

  _init() async {
    try {
      // await _getSocietyList();
      if (widget.address!.addressId != null) {
        _fillData();
      } else {
        // debugPrint("USER CITY N AREA${global.currentUser.userCity}, ${global.currentUser.userArea}");
        // _cCity.text = global.userProfileController.currentUser.userCity.
        // _cCity.text = global.nearStoreModel!.city!;
      }
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - add_address_screen.dart -  _init():$e");
    }
  }

  _save() async {
    try {
      if (_cName.text.isNotEmpty &&
              _cPhone.text.isNotEmpty &&
              _cPhone.text.length == global.appInfo!.phoneNumberLength &&
              // _cPincode.text.isNotEmpty &&
              _cAddress.text.isNotEmpty
      //&&
              // _cLandmark.text.isNotEmpty
          //&&
          // _cSociety.text.isNotEmpty &&
          // _cCity.text.isNotEmpty
          ) {
        bool isConnected = await br.checkConnectivity();
        if (isConnected) {
          showOnlyLoaderDialog();
          Address tAddress = Address();
          tAddress.receiverName = _cName.text;
          tAddress.receiverPhone = _cPhone.text;
          // tAddress.houseNo = _cAddress.text;
          tAddress.landmark = _cLandmark.text;
          // tAddress.pincode = _cPincode.text;
          // tAddress.society = _cSociety.text;
          // tAddress.state = _cState.text;
          // tAddress.city = _cCity.text;
          tAddress.type = type;
          String? latlng = await getLocationFromAddress(
              '${_cAddress.text}, ${_cLandmark.text}, ${_cSociety.text}');
          debugPrint(latlng);
          if (latlng != null) {
            List<String> tList = latlng.split("|");
            tAddress.lat = tList[0];
            tAddress.lng = tList[1];
            if (tAddress.lat != null && tAddress.lat != null) {
              if (widget.address!.addressId != null) {
                print("___________Edit Address  Hit");
                tAddress.addressId = widget.address!.addressId;
                await apiHelper.editAddress(tAddress).then((result) async {
                  if (result != null) {
                    if (result.status == "1") {
                      await global.userProfileController.getUserAddressList();

                      hideLoader();
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    } else {
                      hideLoader();
                      showSnackBar(
                          key: _scaffoldKey,
                          snackBarMessage: '${result.message}');
                    }
                  } else {
                    hideLoader();
                    showSnackBar(
                        key: _scaffoldKey,
                        snackBarMessage:
                            'Some error occurred please try again.');
                  }
                });
              } else {
                print("📤___________-AddAdress Hit");
                Map<String, String> requestData = {
                  'receiver_name': _cName.text,
                  'receiver_phone': _cPhone.text,
                  'address': _cAddress.text,
                  'lat': _currentPosition?.latitude.toString() ?? '',
                  'lng': _currentPosition?.longitude.toString() ?? '',
                  'type': type,
                };
                var response = await apiHelper.addAddress(requestData);

                print("✅ API Response from addAddress: $response");
                if (response) {
                  // await global.userProfileController.getUserAddressList();
                  hideLoader();
                  if (!mounted) return;
                  Navigator.of(context).pop();
                } else {
                  hideLoader();
                  showSnackBar(
                      key: _scaffoldKey,
                      snackBarMessage: "Failed to add address.");
                }
              }
            } else {
              hideLoader();
              showSnackBar(
                  key: _scaffoldKey,
                  snackBarMessage:
                      'we are not able to find this location please input correct address');
            }
          } else {
            hideLoader();
            showSnackBar(
                key: _scaffoldKey,
                snackBarMessage:
                    'we are not able to find this location please input correct address');
          }
        } else {
          showNetworkErrorSnackBar(_scaffoldKey);
        }
      } else if (_cName.text.isEmpty) {
        showSnackBar(
            key: _scaffoldKey,
            snackBarMessage:
                '${AppLocalizations.of(context)!.txt_please_enter_your_name} ');
      } else if (_cPhone.text.isEmpty ||
          (_cPhone.text.isNotEmpty &&
              _cPhone.text.trim().length !=
                  global.appInfo!.phoneNumberLength)) {
        showSnackBar(
            key: _scaffoldKey,
            snackBarMessage: AppLocalizations.of(context)!
                .txt_please_enter_valid_mobile_number);
      } else if (_cAddress.text.trim().isEmpty) {
        showSnackBar(
            key: _scaffoldKey,
            snackBarMessage: AppLocalizations.of(context)!.txt_enter_houseNo);
      } else if (_cLandmark.text.trim().isEmpty) {
        showSnackBar(
            key: _scaffoldKey,
            snackBarMessage:
                '${AppLocalizations.of(context)!.txt_enter_landmark} ');
      } else if (_cPincode.text.trim().isEmpty) {
        showSnackBar(
            key: _scaffoldKey,
            snackBarMessage: AppLocalizations.of(context)!.txt_enter_pincode);
      } else if (_selectedSociety!.societyId == null) {
        showSnackBar(
            key: _scaffoldKey,
            snackBarMessage: AppLocalizations.of(context)!.txt_select_society);
      } else if (_cCity.text.isEmpty) {
        showSnackBar(
            key: _scaffoldKey,
            snackBarMessage:
                ' ${AppLocalizations.of(context)!.txt_select_city}');
      } else if (_cState.text.isEmpty) {
        showSnackBar(
            key: _scaffoldKey,
            snackBarMessage: AppLocalizations.of(context)!.txt_select_state);
      }
    } catch (e) {
      debugPrint("Exception - add_address_screen.dart - _save():$e");
    }
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isRequired,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _shimmerList() {
    try {
      return ListView.builder(
        itemCount: 7,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(top: 15, left: 16, right: 16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 52,
                    width: MediaQuery.of(context).size.width,
                    child: const Card(),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Exception - add_address_screen.dart - _shimmerList():$e");
      return const SizedBox();
    }
  }

  _showSocietySelectDialog() {
    try {
      showDialog(
          context: context,
          useRootNavigator: true,
          barrierDismissible: true,
          barrierColor: Colors.transparent,
          builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) =>
                    AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  backgroundColor:
                      Theme.of(context).inputDecorationTheme.fillColor,
                  title: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.hnt_select_society,
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(0.0))),
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.only(),
                        child: TextFormField(
                          controller: _cSearchSociety,
                          focusNode: _fSearchSociety,
                          style: Theme.of(context).textTheme.titleMedium,
                          decoration: InputDecoration(
                            fillColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            hintText: AppLocalizations.of(context)!
                                .htn_search_society,
                            contentPadding: const EdgeInsets.only(
                                top: 10, left: 10, right: 10),
                          ),
                          onChanged: (val) {
                            _societyList!.clear();
                            if (val.isNotEmpty && val.length > 2) {
                              _societyList!.addAll(_tSocietyList.where((e) => e
                                  .societyName!
                                  .toLowerCase()
                                  .contains(val.toLowerCase())));
                            } else {
                              _societyList!.addAll(_tSocietyList);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: _societyList != null && _societyList!.isNotEmpty
                        ? ListView.builder(
                            itemCount: _cSearchSociety.text.isNotEmpty &&
                                    _tSocietyList.isNotEmpty
                                ? _tSocietyList.length
                                : _societyList!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return RadioListTile(
                                  title: Text(_cSearchSociety.text.isNotEmpty &&
                                          _tSocietyList.isNotEmpty
                                      ? '${_tSocietyList[index].societyName}'
                                      : '${_societyList![index].societyName}'),
                                  value: _cSearchSociety.text.isNotEmpty &&
                                          _tSocietyList.isNotEmpty
                                      ? _tSocietyList[index]
                                      : _societyList![index],
                                  groupValue: _selectedSociety,
                                  onChanged: (dynamic value) async {
                                    _selectedSociety = value;
                                    _cSociety.text =
                                        _selectedSociety!.societyName!;
                                    List<String> listString = _selectedSociety!
                                        .societyName!
                                        .split(",");

                                    _cState.text =
                                        listString[listString.length - 2];

                                    Navigator.of(context).pop();

                                    setState(() {});
                                  });
                            })
                        : Center(
                            child: Text(
                            AppLocalizations.of(context)!.txt_no_society,
                            textAlign: TextAlign.center,
                          )),
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {});
                        },
                        child: Text(AppLocalizations.of(context)!.btn_close))
                  ],
                ),
              ));
    } catch (e) {
      debugPrint(
          "Exception - add_address_screen.dart - _showSocietySelectDialog():$e");
    }
  }
}

class MapScreen extends StatefulWidget {
  final LatLng initialPosition;

  const MapScreen({super.key, required this.initialPosition});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  late LatLng _selectedLocation;
  String _selectedAddress = "Searching address...";

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialPosition;
    _getAddressFromLatLng(
        _selectedLocation.latitude, _selectedLocation.longitude);
  }

  /// **Convert LatLng to Address**
  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        setState(() {
          _selectedAddress =
              "${place.name}, ${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}";
        });
      }
    } catch (e) {
      debugPrint("Error getting address: $e");
    }
  }

  /// **Update Marker & Move Camera**
  void _updateLocation(LatLng newPosition) {
    setState(() {
      _selectedLocation = newPosition;
    });
    _mapController.animateCamera(CameraUpdate.newLatLng(newPosition));

    _getAddressFromLatLng(newPosition.latitude, newPosition.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Location")),
      body: Stack(
        children: [
          /// **Google Map**
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (LatLng tappedPoint) {
              _updateLocation(tappedPoint);
            },
            markers: {
              Marker(
                markerId: const MarkerId("selected_location"),
                position: _selectedLocation,
                draggable: true,
                onDragEnd: (newPosition) {
                  _updateLocation(newPosition);
                },
              ),
            },
          ),

          /// **Selected Address Text**
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  const BoxShadow(color: Colors.black26, blurRadius: 5),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedAddress,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      /// **Confirm Button to Save Location**
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context, {
            "latLng": _selectedLocation,
            "address": _selectedAddress,
          });
        },
        label: const Text("Confirm"),
        icon: const Icon(Icons.check),
      ),
    );
  }
}

///un used

// Container(
//   decoration: const BoxDecoration(
//       borderRadius:
//           BorderRadius.all(Radius.circular(0.0))),
//   margin: const EdgeInsets.only(
//       top: 15, left: 16, right: 16),
//   padding: const EdgeInsets.only(),
//   child: MyTextField(
//     key: const Key('19'),
//     controller: _cName,
//     focusNode: _fName,
//     autofocus: false,
//     textCapitalization: TextCapitalization.words,
//     hintText:
//         AppLocalizations.of(context)!.lbl_name,
//     onFieldSubmitted: (val) {
//       setState(() {});
//       FocusScope.of(context).requestFocus(_fPhone);
//     },
//     onChanged: (value) {},
//   ),
// ),
// Container(
//   decoration: const BoxDecoration(
//       borderRadius:
//           BorderRadius.all(Radius.circular(0.0))),
//   margin: const EdgeInsets.only(
//       top: 15, left: 16, right: 16),
//   padding: const EdgeInsets.only(),
//   child: MyTextField(
//     key: const Key('20'),
//     controller: _cPhone,
//     focusNode: _fPhone,
//     autofocus: false,
//     keyboardType:
//         const TextInputType.numberWithOptions(
//             signed: true, decimal: true),
//     inputFormatters: [
//       FilteringTextInputFormatter.digitsOnly,
//       LengthLimitingTextInputFormatter(
//           global.appInfo!.phoneNumberLength)
//     ],
//     hintText:
//         '${AppLocalizations.of(context)!.lbl_phone_number} ',
//     onFieldSubmitted: (val) {
//       FocusScope.of(context)
//           .requestFocus(_fAddress);
//     },
//   ),
// ),
// Container(
//   decoration: const BoxDecoration(
//       borderRadius:
//           BorderRadius.all(Radius.circular(0.0))),
//   margin: const EdgeInsets.only(
//       top: 15, left: 16, right: 16),
//   padding: const EdgeInsets.only(),
//   child: MyTextField(
//     key: const Key('21'),
//     controller: _cAddress,
//     focusNode: _fAddress,
//     hintText:
//         '${AppLocalizations.of(context)!.txt_address} ',
//     onFieldSubmitted: (val) {
//       FocusScope.of(context)
//           .requestFocus(_fLandmark);
//     },
//   ),
// ),
// Container(
//   decoration: const BoxDecoration(
//       borderRadius:
//           BorderRadius.all(Radius.circular(0.0))),
//   margin: const EdgeInsets.only(
//       top: 15, left: 16, right: 16),
//   padding: const EdgeInsets.only(),
//   child: MyTextField(
//     key: const Key('22'),
//     controller: _cLandmark,
//     focusNode: _fLandmark,
//     hintText:
//         '${AppLocalizations.of(context)!.hnt_near_landmark} ',
//     onFieldSubmitted: (val) {
//       FocusScope.of(context)
//           .requestFocus(_fPincode);
//     },
//   ),
// ),
// Container(
//   decoration: const BoxDecoration(
//       borderRadius:
//           BorderRadius.all(Radius.circular(0.0))),
//   margin: const EdgeInsets.only(
//       top: 15, left: 16, right: 16),
//   padding: const EdgeInsets.only(),
//   child: MyTextField(
//     key: const Key('23'),
//     controller: _cPincode,
//     focusNode: _fPincode,
//     hintText:
//         ' ${AppLocalizations.of(context)!.hnt_pincode}',
//     keyboardType:
//         const TextInputType.numberWithOptions(
//             signed: true, decimal: true),
//     inputFormatters: [
//       FilteringTextInputFormatter.digitsOnly,
//       LengthLimitingTextInputFormatter(
//           global.appInfo!.phoneNumberLength)
//     ],
//     onFieldSubmitted: (val) {
//       FocusScope.of(context)
//           .requestFocus(_fSociety);
//     },
//   ),
// ),
// Container(
//   decoration: const BoxDecoration(
//       borderRadius:
//           BorderRadius.all(Radius.circular(0.0))),
//   margin: const EdgeInsets.only(
//       top: 15, left: 16, right: 16),
//   padding: const EdgeInsets.only(),
//   child: MyTextField(
//     key: const Key('24'),
//     controller: _cSociety,
//     focusNode: _fSociety,
//     readOnly: true,
//     maxLines: 3,
//     hintText:
//         '${AppLocalizations.of(context)!.lbl_society} ',
//     onFieldSubmitted: (val) {
//       FocusScope.of(context).requestFocus(_fCity);
//     },
//     onTap: () {
//       _showSocietySelectDialog();
//     },
//   ),
// ),
// Row(
//   mainAxisSize: MainAxisSize.min,
//   children: [
//     Expanded(
//       child: Container(
//         decoration: const BoxDecoration(
//             borderRadius: BorderRadius.all(
//                 Radius.circular(0.0))),
//         margin: const EdgeInsets.only(
//             top: 15, left: 16, right: 8),
//         padding: const EdgeInsets.only(),
//         child: MyTextField(
//           key: const Key('25'),
//           controller: _cCity,
//           focusNode: _fCity,
//           hintText:
//               '${AppLocalizations.of(context)!.lbl_city} ',
//           // readOnly: true,
//           onFieldSubmitted: (val) {
//             FocusScope.of(context)
//                 .requestFocus(_fState);
//           },
//         ),
//       ),
//     ),
//     Expanded(
//       child: Container(
//         decoration: const BoxDecoration(
//             borderRadius: BorderRadius.all(
//                 Radius.circular(0.0))),
//         margin: const EdgeInsets.only(
//             top: 15, left: 8, right: 16),
//         padding: const EdgeInsets.only(),
//         child: MyTextField(
//           key: const Key('26'),
//           controller: _cState,
//           focusNode: _fState,
//           readOnly:
//               widget.address!.addressId != null
//                   ? true
//                   : false,
//           hintText:
//               '${AppLocalizations.of(context)!.hnt_state} ',
//           onFieldSubmitted: (val) {
//             FocusScope.of(context)
//                 .requestFocus(_fDismiss);
//           },
//         ),
//       ),
//     ),
//   ],
// ),
