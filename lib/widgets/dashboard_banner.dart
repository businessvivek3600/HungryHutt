import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DashboardBanner1 extends StatefulWidget {
  final List<Widget> items;
  final EdgeInsetsGeometry? margin;
  const DashboardBanner1({super.key, this.margin, required this.items});

  @override
  State<DashboardBanner1> createState() => _DashboardBanner1State();
}

class _DashboardBanner1State extends State<DashboardBanner1> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: widget.margin,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.15,
          child: CarouselSlider(
              items: widget.items,
              carouselController: _carouselController,
              options: CarouselOptions(
                  viewportFraction: 0.95,
                  initialPage: _currentIndex,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, _) {
                    _currentIndex = index;
                    setState(() {});
                  })),
        ),
      ],
    );
  }
}

class DashboardBanner2 extends StatefulWidget {
  final List<Widget> items;
  final EdgeInsetsGeometry? margin;
  const DashboardBanner2({super.key, this.margin, required this.items});

  @override
  State<DashboardBanner2> createState() => _DashboardBanner2State();
}

class _DashboardBanner2State extends State<DashboardBanner2> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        // Dark Gray
                        Colors.black,
                        Colors.black54, // Light Gray
                        Colors.black12, // Black
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  AppLocalizations.of(context)!.lbl_secondBanner,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.black12, // Light Gray
                        Colors.black54, // Dark Gray
                        Colors.black, // Black
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: widget.margin,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.15,
          child: CarouselSlider(
            items: widget.items,
            carouselController: _carouselController,
            options: CarouselOptions(
              viewportFraction: 0.95,
              initialPage: _currentIndex,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              onPageChanged: (index, _) {
                setState(() => _currentIndex = index);
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Center(
//   child: DotsIndicator(
//     dotsCount: widget.items.length,
//     position: _currentIndex,
//     onTap: (i) {
//       _currentIndex = i.toInt();
//       _carouselController.animateToPage(_currentIndex,
//           duration: const Duration(microseconds: 1),
//           curve: Curves.easeInOut);
//     },
//     decorator: DotsDecorator(
//       activeSize: const Size(6, 6),
//       size: const Size(6, 6),
//       activeShape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(
//           Radius.circular(50.0),
//         ),
//       ),
//       activeColor: Theme.of(context).colorScheme.primary,
//       color: Colors.grey,
//     ),
//   ),
// ),
//             ],
//           ))
//     ]);
//   }
// }
