import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/screens/login_screen.dart';

class IntroScreen extends BaseRoute {
  const IntroScreen(
      {super.key,
      super.analytics,
      super.observer,
      super.routeName = 'IntroScreen'});

  @override
  BaseRouteState createState() => _IntroScreenState();
}

class _IntroScreenState extends BaseRouteState {
  int _currentIndex = 0;
  PageController? _pageController;

  _IntroScreenState() : super();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          body: Stack(children: [
        PageView(
            controller: _pageController,
            onPageChanged: (index) {
              _currentIndex = index;
              setState(() {});
            },
            children: [
              Image.asset(
                'assets/images/intro_1.png',
                fit: BoxFit.cover,
              ),
              Image.asset(
                'assets/images/intro_2.png',
                fit: BoxFit.cover,
              ),
              Image.asset(
                'assets/images/intro_3.png',
                fit: BoxFit.cover,
              ),
            ]),
        Container(
          margin: const EdgeInsets.only(top: 25),
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                  margin: const EdgeInsets.only(right: 15, top: 20),
                  width: 100,
                  child: Stack(
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          for (int i = 0; i < 3; i++)
                            if (i == _currentIndex) ...[circleBar(true)] else
                              circleBar(false),
                        ],
                      ),
                    ],
                  ))
            ],
          ),
        ),
        Positioned(
          right: MediaQuery.of(context).size.width / 3,
          bottom: 15,
          child: Align(
            alignment: Alignment.center,
            child: TextButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent)),
              onPressed: () {
                if (_currentIndex < 2) {
                  _pageController!.animateToPage(_currentIndex + 1, duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
                } else {
                Get.to(() => LoginScreen(
                      analytics: widget.analytics,
                      observer: widget.observer,
                    ));
                 }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _currentIndex < 2 ? 'Next' : 'Get Started',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 2.0,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_right_rounded,
                    size: 30,
                    color: Theme.of(context).colorScheme.primary,
                  )
                ],
              ),
            ),
          ),
        )
      ])),
    );
  }

  Widget circleBar(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 50),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: isActive ? 5 : 5,
      width: isActive ? 23 : 10,
      decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withOpacity(0.5),
          borderRadius: const BorderRadius.all(Radius.circular(12))),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _pageController!.addListener(() {});
  }
}
