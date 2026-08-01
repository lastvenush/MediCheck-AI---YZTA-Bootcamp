import 'package:flutter/material.dart';

import '../../models/product.dart';

Widget buildProductImage({
  required Product product,
  required BoxFit fit,
  required ImageErrorWidgetBuilder errorBuilder,
  double? width,
  double? height,
}) {
  final imagePath = product.imageUrl;

  if (imagePath.startsWith('assets/')) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }

  return Image.network(
    imagePath,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}
