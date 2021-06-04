import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Shimmer CustomLoader() {
  return Shimmer.fromColors(
    period: Duration(milliseconds: 400),
    baseColor: Colors.white70,
    highlightColor: Colors.blue.shade50,
    child: Container(decoration: BoxDecoration(color: Colors.white70)),
  );
}
