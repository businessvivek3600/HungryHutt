import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'gradient_heading_row.dart';

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
  CarouselSliderController(); // ✅ Corrected Controller

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildGradientHeadingRow(context,AppLocalizations.of(context)!.lbl_secondBanner),// Replace with your heading
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.2, // Adjusted height
          child: Stack(
            children: [
              CarouselSlider(
                items: widget.items.map((imageWidget) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox.expand(
                      child: imageWidget, // ✅ Ensures full container height
                    ),
                  );
                }).toList(),
                carouselController: _carouselController,
                options: CarouselOptions(
                  height: double.infinity, // ✅ Ensures full height
                  viewportFraction: 1.0, // Full width
                  initialPage: _currentIndex,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: false,
                  onPageChanged: (index, _) {
                    setState(() => _currentIndex = index);
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.items.length, (index) {
                    return Container(
                      width: _currentIndex == index ? 8.0 : 4.0,
                      height: _currentIndex == index ? 8.0 : 4.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    );
                  }),
                ),
              ),
            ],
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
