import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/category_filter.dart';
import 'package:user/models/category_list_model.dart';
import 'package:user/screens/sub_categories_screen.dart';
import 'package:user/widgets/select_category_card.dart';

class AllCategoriesScreen extends BaseRoute {
  const AllCategoriesScreen(
      {super.key,
      super.analytics,
      super.observer,
      super.routeName = 'AllCategoriesScreen'});

  @override
  BaseRouteState createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends BaseRouteState {
  int _selectedIndex = 0;
  final List<CategoryList> _categoryList = [];
  bool _isDataLoaded = false;
  int? screenId;
  bool _isRecordPending = true;
  bool _isMoreDataLoaded = false;
  final ScrollController _scrollController = ScrollController();
  final CategoryFilter _categoryFilter = CategoryFilter();
  int page = 1;

  GlobalKey<ScaffoldState>? _scaffoldKey;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${AppLocalizations.of(context)!.tle_all_category} ",
          style: textTheme.titleLarge,
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.keyboard_arrow_left)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _onRefresh();
          },
          child: global.nearStoreModel != null &&
                  global.nearStoreModel!.id != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isDataLoaded
                      ? _categoryList.isNotEmpty
                          ? GridView.builder(
                              controller: _scrollController,
                              itemCount: _categoryList.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 16.0,
                                crossAxisSpacing: 12.0,
                                childAspectRatio: 1 / 1,
                              ),
                              itemBuilder: (context, index) =>
                                  SelectCategoryCard(
                                key: UniqueKey(),
                                category: _categoryList[index],
                                isSelected: _categoryList[index].isSelected,
                                borderRadius: 0,
                                onPressed: () {
                                  setState(() {
                                    _categoryList
                                        .map((e) => e.isSelected = false)
                                        .toList();
                                    _selectedIndex = index;
                                    if (_selectedIndex == index) {
                                      _categoryList[index].isSelected = true;
                                    }
                                  });
                                  if (_categoryList[index]
                                      .subcategory
                                      .isNotEmpty) {
                                    Get.to(SubCategoriesScreen(
                                      analytics: widget.analytics,
                                      observer: widget.observer,
                                      screenHeading: _categoryList[index].title,
                                      categoryId: _categoryList[index].catId,
                                    ));
                                  } else {
                                    showSnackBar(
                                        key: _scaffoldKey,
                                        snackBarMessage:
                                            ' ${AppLocalizations.of(context)!.txt_nothing_to_show}');
                                  }
                                },
                              ),
                            )
                          : Center(
                              child: Text(AppLocalizations.of(context)!
                                  .txt_nothing_to_show),
                            )
                      : _shimmer(),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(global.locationMessage!),
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _getCategoryList() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        if (_isRecordPending) {
          setState(() {
            _isMoreDataLoaded = true;
          });
          if (_categoryList.isEmpty) {
            page = 1;
          } else {
            page++;
          }
          await apiHelper
              .getCategoryList(_categoryFilter, page)
              .then((result) async {
            debugPrint("Raw API Response: $result");
            if (result != null) {
              debugPrint("Full API Response: ${result.data}");
              if (result.status == "1") {
                List<CategoryList> tList = result.data;
                if (tList.isEmpty) {
                  _isRecordPending = false;
                }
                _categoryList.addAll(tList);
                setState(() {
                  _isMoreDataLoaded = false;
                });
              }
            }
          });
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint(
          "Exception - all_categories_screen.dart - _getCategoryList():$e");
    }
  }

  _init() async {
    try {
      await _getCategoryList();
      _scrollController.addListener(() async {
        if (_scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent &&
            !_isMoreDataLoaded) {
          setState(() {
            _isMoreDataLoaded = true;
          });
          await _getCategoryList();
          setState(() {
            _isMoreDataLoaded = false;
          });
        }
      });
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - all_categories_screen.dart - _init():$e");
    }
  }

  _onRefresh() async {
    try {
      _isDataLoaded = false;
      _isRecordPending = true;
      setState(() {});
      await _init();
    } catch (e) {
      debugPrint("Exception - all_categories_screen.dart - _onRefresh():$e");
    }
  }

  _shimmer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: GridView.builder(
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 12.0,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) =>
                  const SizedBox(height: 130, width: 90, child: Card()))),
    );
  }
}
