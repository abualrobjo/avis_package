import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    required this.name,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.extension = 'png',
    this.folder = 'images',
  });

  final String name;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final String extension;
  final String? folder;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/$folder/$name.$extension',
      package: 'avis_package',
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }
}
