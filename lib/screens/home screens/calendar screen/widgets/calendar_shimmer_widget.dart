import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCalendar extends StatelessWidget {
  const ShimmerCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[600]!,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1500),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, childAspectRatio: 0.35),
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.all(2.0),
              color: Colors.grey,
            );
          },
          itemCount: 35,
        ),
      ),
    );
  }
}
