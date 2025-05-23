import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/city_model.dart';
import 'package:user/models/society_model.dart';
import 'package:user/models/user_model.dart';
import 'package:user/widgets/bottom_button.dart';
import 'package:user/widgets/my_text_field.dart';

class ProfileEditScreen extends BaseRoute {
  const ProfileEditScreen({super.key, super.analytics, super.observer, super.routeName = 'ProfileEditScreen'});

  @override
  BaseRouteState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends BaseRouteState {
  final _cName = TextEditingController();
  final _cPhone = TextEditingController();
  final _cEmail = TextEditingController();
  final _fName = FocusNode();
  GlobalKey<ScaffoldState>? _scaffoldKey;
  final _fPhone = FocusNode();
  final _fEmail = FocusNode();
  final _cSearchCity = TextEditingController();
  final _fSearchCity = FocusNode();
  final _fSearchSociety = FocusNode();
  final _cSearchSociety = TextEditingController();
  List<City>? _citiesList = [];
  List<Society>? _societyList = [];
  final List<City> _tCityList = [];
  final List<Society> _tSocietyList = [];
  City? _selectedCity = City();
  Society? _selectedSociety = Society();
  final _cCity = TextEditingController();
  final _cSociety = TextEditingController();
  XFile? _tImage;
  final _fCity = FocusNode();
  final _fSociety = FocusNode();
  bool _isDataLoaded = false;
  _ProfileEditScreenState() : super();
  @override
  Widget build(BuildContext context) {
    print("-------------Edit Profile -------------------- ${global.currentUser!.addresses}");
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      key: _scaffoldKey,
      // backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.tle_edit_profile,
          style: textTheme.titleLarge,
        ),
        leading: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          onTap: () {
            Get.back();
          },
          child: Align(
            alignment: Alignment.center,
            child: Icon(MdiIcons.arrowLeft),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _isDataLoaded
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _tImage != null
                            ? CircleAvatar(
                                radius: 60,
                                backgroundImage: FileImage(File(_tImage!.path)),
                              )
                            : global.currentUser!.userImage != null
                                ? CachedNetworkImage(
                                    imageUrl: global.appInfo!.imageUrl! + global.currentUser!.userImage!,
                                    imageBuilder: (context, imageProvider) => Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 60,
                                          backgroundImage: imageProvider,
                                        )
                                      ],
                                    ),
                                    placeholder: (context, url) => const CircleAvatar(backgroundColor: Colors.white, radius: 60, child: Center(child: CircularProgressIndicator())),
                                    errorWidget: (context, url, error) => CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 60,
                                        child: Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Theme.of(context).colorScheme.primary,
                                        )),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 60,
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.primary,
                                    )),
                        Positioned(
                          bottom: 0,
                          right: -4,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: IconButton(
                              icon: const Icon(
                                Icons.add_a_photo_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                _showCupertinoModalSheet();
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ))
                : Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          width: MediaQuery.of(context).size.width - 16,
                          child: const Card(),
                        ),
                        SizedBox(
                          height: 40,
                          width: MediaQuery.of(context).size.width - 16,
                        ),
                      ],
                    ),
                  ),
            Expanded(
              child: _isDataLoaded
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.lbl_name,
                              style: textTheme.bodySmall,
                            ),
                            Container(
                              decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                              margin: const EdgeInsets.only(top: 5, bottom: 15),
                              padding: const EdgeInsets.only(),
                              child: MyTextField(
                                key: const Key('1'),
                                controller: _cName,
                                focusNode: _fName,
                                hintText: AppLocalizations.of(context)!.lbl_name,
                                onFieldSubmitted: (val) {
                                  FocusScope.of(context).requestFocus(_fPhone);
                                },
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.lbl_phone_number,
                              style: textTheme.bodySmall,
                            ),
                            Container(
                              decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                              margin: const EdgeInsets.only(top: 5, bottom: 15),
                              padding: const EdgeInsets.only(),
                              child: MyTextField(
                                key: const Key('2'),
                                controller: _cPhone,
                                focusNode: _fPhone,
                                readOnly: true,
                                hintText: '${global.appInfo!.countryCode} 0000000000',
                                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(global.appInfo!.phoneNumberLength)],
                                onFieldSubmitted: (val) {
                                  FocusScope.of(context).requestFocus(_fEmail);
                                },
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.lbl_email,
                              style: textTheme.bodySmall,
                            ),
                            Container(
                              decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                              margin: const EdgeInsets.only(top: 5, bottom: 15),
                              padding: const EdgeInsets.only(),
                              child: MyTextField(
                                key: const Key('3'),
                                controller: _cEmail,
                                focusNode: _fEmail,
                                readOnly: true,
                                hintText: 'user@gmail.com',
                                onFieldSubmitted: (val) {
                                  FocusScope.of(context).requestFocus(_fCity);
                                },
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.lbl_city,
                              style: textTheme.bodySmall,
                            ),
                            Container(
                              decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                              margin: const EdgeInsets.only(top: 5, bottom: 15),
                              padding: const EdgeInsets.only(),
                              child: MyTextField(
                                key: const Key('4'),
                                controller: _cCity,
                                focusNode: _fCity,
                                readOnly: true,
                                keyboardType: TextInputType.number,
                                onTap: () {
                                  _showCitySelectDialog();

                                  setState(() {});
                                },
                                hintText: AppLocalizations.of(context)!.hnt_select_city,
                                onFieldSubmitted: (val) {
                                  FocusScope.of(context).requestFocus(_fSociety);
                                },
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.lbl_society,
                              style: textTheme.bodySmall,
                            ),
                            Container(
                              decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                              margin: const EdgeInsets.only(top: 5, bottom: 15),
                              padding: const EdgeInsets.only(),
                              child: MyTextField(
                                key: const Key('5'),
                                controller: _cSociety,
                                focusNode: _fSociety,
                                readOnly: true,
                                keyboardType: TextInputType.number,
                                onTap: () {
                                  _showSocietySelectDialog();

                                  setState(() {});
                                },
                                hintText: AppLocalizations.of(context)!.hnt_select_society,
                                onFieldSubmitted: (val) {
                                  FocusScope.of(context).dispose();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _shimmerList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isDataLoaded
          ? SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: BottomButton(
                    key: UniqueKey(),
                    loadingState: false,
                    disabledState: false,
                    onPressed: () {
                      _save();
                    },
                    child: Text(AppLocalizations.of(context)!.btn_save_update)),
              ),
          )
          : null,
    );
  }


  @override
  void initState() {
    super.initState();
    _init();
  }

  _getCities() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getCity().then((result) {
          if (result != null && result.statusCode == 200 && result.status == '1') {
            _citiesList = result.data;
            _tCityList.addAll(_citiesList!);
          } else {
            _citiesList = [];
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - profile_edit_screen.dart - _getCities():$e");
    }
  }

  _getSociety(int? cityId, bool openDialog) async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getSociety(cityId).then((result) {
          if(!mounted) return;
          if (result != null && result.statusCode == 200 && result.status == '1') {
            _societyList = result.data;

            if (openDialog) {
              _tSocietyList.addAll(_societyList!);
              Navigator.of(context).pop();
              _cSearchCity.clear();
              _showSocietySelectDialog();
            }

            setState(() {});
          } else {
            Navigator.of(context).pop();
            _cSearchCity.clear();
            _societyList = [];

            showSnackBar(key: _scaffoldKey, snackBarMessage: result.message);
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - profile_edit_screen.dart - _getSociety():$e");
    }
  }

  _init() async {
    try {
      await _getCities();
      if (global.userProfileController.currentUser != null && global.userProfileController.addressList.isNotEmpty) {
        await _getSociety(global.currentUser!.userCity, false);
        _selectedCity = _citiesList!.firstWhere((e) => e.cityId == global.currentUser!.userCity);
        _cCity.text = _selectedCity!.cityName!;
        _selectedSociety = _societyList!.firstWhere((e) => e.societyId == global.currentUser!.userArea);
        _cSociety.text = _selectedSociety!.societyName!;
      } else {
        _cSociety.text = '';
      }

      _cName.text = global.userProfileController.currentUser?.name ?? '';
      _cEmail.text = global.userProfileController.currentUser?.email ?? '';
      _cPhone.text = global.userProfileController.currentUser?.userPhone ?? '';
      _isDataLoaded = true;
      setState(() {});
      // Print all initialized data
      print("====== Initialized Data ======");
      print("User Name: ${_cName.text}");
      print("User Email: ${_cEmail.text}");
      print("User Phone: ${_cPhone.text}");
      print("Selected City: ${_cCity.text} (ID: ${_selectedCity?.cityId})");
      print("Selected Society: ${_cSociety.text} (ID: ${_selectedSociety?.societyId})");
      print("City List: ${_citiesList?.map((e) => e).toList()}");
      print("Society List: ${_societyList?.map((e) => e).toList()}");
      print("================================");
    } catch (e) {
      debugPrint("Exception - profile_edit_screen.dart - _init(): $e");
    }
  }

  _save() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        if (_cName.text.isNotEmpty && _selectedCity != null && _selectedCity!.cityId != null && _selectedSociety != null && _selectedSociety!.societyId != null) {
          showOnlyLoaderDialog();
          CurrentUser user = CurrentUser();
          user.name = _cName.text;
          if (_tImage != null) {
            user.userImageFile = File(_tImage!.path);
          }
          user.userCity = _selectedCity!.cityId;
          user.userArea = _selectedSociety!.societyId;
          await apiHelper.updateProfile(user).then((result) async {
            if (result != null) {
              print("Update Profile Response: ${result}");
              if (result.status == "1") {
                global.userProfileController.currentUser = result.data;
                global.currentUser = global.userProfileController.currentUser;
                global.sp!.setString('currentUser', json.encode(global.currentUser!.toJson()));
                hideLoader();
                _init();
                if(!mounted) return;
                showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_profile_updated_successfully);
              } else {
                hideLoader();
                showSnackBar(key: _scaffoldKey, snackBarMessage: result.message.toString());
              }
            }
          });
          await apiHelper.updateFirebaseUser(global.currentUser);
        } else if (_cName.text.isEmpty) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_please_enter_your_name);
        } else if (_selectedCity!.cityId == null) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_select_city);
        } else if (_selectedSociety!.societyId == null) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_select_society);
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - profile_edit_screen.dart - _save():$e");
    }
  }

  Widget _shimmerList() {
    try {
      return ListView.builder(
        itemCount: 5,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
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
                    height: 20,
                    width: MediaQuery.of(context).size.width / 2,
                    child: const Card(),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    height: 52,
                    width: MediaQuery.of(context).size.width,
                    child: const Card(),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Exception - productDetailScreen.dart - _shimmerList():$e");
      return const SizedBox();
    }
  }

  _showCitySelectDialog() {
    try {
      showDialog(
          context: context,
          barrierColor: Colors.black38,
          builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) => AlertDialog(
                  elevation: 2,
                  scrollable: false,
                  contentPadding: EdgeInsets.zero,
                  backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
                  title: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.hnt_select_city),
                      Container(
                        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.only(),
                        child: TextFormField(
                          controller: _cSearchCity,
                          focusNode: _fSearchCity,
                          style: Theme.of(context).primaryTextTheme.bodyLarge,
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).scaffoldBackgroundColor,
                            hintText: AppLocalizations.of(context)!.hnt_search_city,
                            contentPadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                          ),
                          onChanged: (val) {
                            _citiesList!.clear();
                            if (val.isNotEmpty && val.length > 2) {
                              _citiesList!.addAll(_tCityList.where((e) => e.cityName!.toLowerCase().contains(val.toLowerCase())));
                            } else {
                              _citiesList!.addAll(_tCityList);
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
                    child: _citiesList != null && _citiesList!.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: _citiesList!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return RadioListTile(
                                  title: Text('${_citiesList![index].cityName}'),
                                  value: _citiesList![index],
                                  groupValue: _selectedCity,
                                  onChanged: (dynamic value) async {
                                    _selectedCity = value;
                                    _cCity.text = _selectedCity!.cityName!;
                                    _cSociety.clear();
                                    _selectedSociety!.societyId = null;
                                    await _getSociety(_selectedCity!.cityId, true);
                                    setState(() {});
                                  });
                            })
                        : Center(
                            child: Text(
                              AppLocalizations.of(context)!.txt_no_city,
                              textAlign: TextAlign.center,
                            ),
                          ),
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
      debugPrint("Exception - profile_edit_screen.dart - _showCitySelectDialog():$e");
    }
  }

  _showCupertinoModalSheet() {
    try {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Text(AppLocalizations.of(context)!.lbl_actions),
          actions: [
            CupertinoActionSheetAction(
              child: Text(
                AppLocalizations.of(context)!.lbl_take_picture,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                _tImage = await br.openCamera();
                global.selectedImage = _tImage!.path;

                setState(() {});
              },
            ),
            CupertinoActionSheetAction(
              child: Text(
                AppLocalizations.of(context)!.txt_upload_image_desc,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              onPressed: () async {
                Navigator.pop(context);

                _tImage = await br.selectImageFromGallery();
                global.selectedImage = _tImage!.path;

                setState(() {});
              },
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(AppLocalizations.of(context)!.lbl_cancel, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint("Exception - profile_edit_screen.dart - _showCupertinoModalSheet():$e");
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
                builder: (BuildContext context, StateSetter setState) => AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
                  title: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.hnt_select_society),
                      Container(
                        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.only(),
                        child: TextFormField(
                          controller: _cSearchSociety,
                          focusNode: _fSearchSociety,
                          style: Theme.of(context).textTheme.titleMedium,
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).scaffoldBackgroundColor,
                            hintText: AppLocalizations.of(context)!.htn_search_society,
                            contentPadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                          ),
                          onChanged: (val) {
                            _societyList!.clear();
                            if (val.isNotEmpty && val.length > 2) {
                              _societyList!.addAll(_tSocietyList.where((e) => e.societyName!.toLowerCase().contains(val.toLowerCase())));
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
                            itemCount: _cSearchSociety.text.isNotEmpty && _tSocietyList.isNotEmpty ? _tSocietyList.length : _societyList!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return RadioListTile(
                                  title: Text(_cSearchSociety.text.isNotEmpty && _tSocietyList.isNotEmpty ? '${_tSocietyList[index].societyName}' : '${_societyList![index].societyName}'),
                                  value: _cSearchSociety.text.isNotEmpty && _tSocietyList.isNotEmpty ? _tSocietyList[index] : _societyList![index],
                                  groupValue: _selectedSociety,
                                  onChanged: (dynamic value) async {
                                    _selectedSociety = value;
                                    _cSociety.text = _selectedSociety!.societyName!;
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
      debugPrint("Exception - profile_edit_screen.dart - _showSocietySelectDialog():$e");
    }
  }
}
