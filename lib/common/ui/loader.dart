import 'package:flutter/material.dart';
import 'package:project_netsurf/common/contants.dart';
import 'package:shimmer/shimmer.dart';

Shimmer CustomLoader() {
  return Shimmer.fromColors(
    period: Duration(milliseconds: 400),
    baseColor: Color(LOADER_BASE_COLOR),
    highlightColor: Color(LOADER_COLOR),
    child: Container(decoration: BoxDecoration(color: Colors.white70)),
  );
}
