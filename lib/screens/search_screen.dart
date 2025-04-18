import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/category_product_model.dart';
import 'package:user/models/recent_search_model.dart';
import 'package:user/screens/search_results_screen.dart';
import 'package:user/utils/navigation_utils.dart';
import 'package:user/widgets/chip_menu.dart';
import 'package:user/widgets/my_text_box.dart';

class SearchScreen extends BaseRoute {
  const SearchScreen({super.key, super.analytics, super.observer, super.routeName = 'SearchScreen'});

  @override
  BaseRouteState createState() => _SearchScreenState();
}

class SearchScreenHeader extends StatefulWidget {
  final TextTheme textTheme;
  final dynamic analytics;
  final dynamic observer;

  const SearchScreenHeader({super.key, required this.textTheme, this.analytics, this.observer});

  @override
  State<SearchScreenHeader> createState() => _SearchScreenHeaderState();
}

class _SearchScreenHeaderState extends State<SearchScreenHeader> {
  final TextEditingController _cSearch = TextEditingController();

  _SearchScreenHeaderState();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MyTextBox(
            key: const Key('30'),
            autofocus: false,
            controller: _cSearch,
            suffixIcon: Icon(
              Icons.cancel,
              color: Theme.of(context).colorScheme.primary,
            ),
            prefixIcon: Icon(
              Icons.search_outlined,
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey[800] : Colors.grey[350],
            ),
            hintText: AppLocalizations.of(context)!.hnt_search_product,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {},
            onEditingComplete: () {
              Get.to(() => SearchResultsScreen(
                analytics: widget.analytics,
                observer: widget.observer,
                searchParams: _cSearch.text.trim(),
              ));
            }),
        const SizedBox(width: 16),
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            AppLocalizations.of(context)!.lbl_cancel,
            style: widget.textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey[800] : Colors.grey[350],
            ),
          ),
        )
      ],
    );
  }
}

class _SearchScreenState extends BaseRouteState {
  bool _isDataLoaded = false;
  List<RecentSearch>? _recentSearchList = [];
  List<Product>? _trendingSearchProducts = [];
  GlobalKey<ScaffoldState>? _scaffoldKey;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: global.nearStoreModel != null
            ? null
            : AppBar(
                title: Text(
                  AppLocalizations.of(context)!.hnt_search_product,
                  style: textTheme.titleLarge,
                ),
              ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: global.nearStoreModel != null
                ? RefreshIndicator(
                    onRefresh: () async {
                      await _onRefresh();
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 16.0,
                              bottom: 32,
                            ),
                            child: SearchScreenHeader(
                              textTheme: textTheme,
                              analytics: widget.analytics,
                              observer: widget.observer,
                            ),
                          ),
                          _trendingSearchProducts != null ? Text(
                            AppLocalizations.of(context)!.lbl_trending_products,
                            style: textTheme.titleLarge,
                          ) : SizedBox(),
                          _trendingSearchProducts != null ?
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: _isDataLoaded
                                ? _trendingSearchProducts != null && _trendingSearchProducts!.isNotEmpty
                                    ? ChipMenu(
                                        analytics: widget.analytics,
                                        observer: widget.observer,
                                        trendingSearchProductList: _trendingSearchProducts,
                                        onChanged: (value) {},
                                      )
                                    : Text(AppLocalizations.of(context)!.txt_nothing_to_show)
                                : _shimmer1(),
                          ) : SizedBox(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              AppLocalizations.of(context)!.lbl_recent_search,
                              style: textTheme.titleLarge,
                            ),
                          ),
                          _isDataLoaded
                              ? _recentSearchList != null && _recentSearchList!.isNotEmpty
                                  ? ListView.builder(
                                      itemCount: _recentSearchList!.length,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) => InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(NavigationUtils.createAnimatedRoute(
                                              1.0,
                                              SearchResultsScreen(
                                                analytics: widget.analytics,
                                                observer: widget.observer,
                                                searchParams: _recentSearchList![index].keyword,
                                              )));
                                        },
                                        child: ListTile(
                                          leading: const Icon(
                                            Icons.history_outlined,
                                          ),
                                          title: Text(
                                            _recentSearchList![index].keyword!,
                                            style: textTheme.bodyLarge,
                                          ),
                                          trailing: const Icon(
                                            Icons.chevron_right,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Text(AppLocalizations.of(context)!.txt_nothing_to_show)
                              : _shimmer2()
                        ],
                      ),
                    ),
                  )
                : Center(child: Text(global.locationMessage!)),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (global.nearStoreModel != null) {
      _init();
    }
  }

  _getRecentSearchData() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        debugPrint("Fetching recent search data from API...");
        await apiHelper.showRecentSearch().then((result) async {
          if (result != null) {
            if (result.status == "1") {
              _recentSearchList = result.data;
              debugPrint("Recent search data received from API: $_recentSearchList");
            } else {
              _recentSearchList = null;
              debugPrint("API call failed. No recent search data available.");
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
        debugPrint("No internet connection. Cannot fetch recent search data.");
      }
    } catch (e) {
      debugPrint("Exception - search_screen.dart - _getRecentSearchData(): $e");
    }
  }


  _init() async {
    try {
      await _getRecentSearchData();
      await _showTrendingSearchProducts();
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - search_screen.dart - _init():$e");
    }
  }

  _onRefresh() async {
    try {
      _isDataLoaded = false;
      setState(() {});
      await _init();
    } catch (e) {
      debugPrint("Exception - search_screen.dart - _onRefresh():$e");
    }
  }

  _shimmer1() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            SizedBox(
                height: 43,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 3.3,
                        height: 43,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        )),
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 3.3,
                        height: 43,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        )),
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 3.3,
                        height: 43,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ))
                  ],
                )),
            SizedBox(
                height: 43,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 3.3,
                        height: 43,
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        )),
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 3.3,
                        height: 43,
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        )),
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 3.3,
                        height: 43,
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ))
                  ],
                )),
          ],
        ));
  }

  _shimmer2() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(height: 60, width: MediaQuery.of(context).size.width, child: const Card());
              })),
    );
  }

  _showTrendingSearchProducts() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.showTrendingSearchProducts().then((result) async {
          if (result != null) {
            if (result.status == "1") {
              _trendingSearchProducts = result.data;
            } else {
              showSnackBar(key: _scaffoldKey, snackBarMessage: result.message);
              _trendingSearchProducts = null;
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - search_screen.dart - _getRecentSearchData():$e");
    }
  }
}
