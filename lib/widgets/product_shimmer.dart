

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget productShimmer() {
  try {
    return ListView.builder(
      itemCount: 10,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          //      margin: EdgeInsets.only(top: 15, bottom: 8),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: const Card(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  } catch (e) {
    debugPrint("Exception - productDetailScreen.dart - _productShimmer():$e");
    return const SizedBox();
  }
}