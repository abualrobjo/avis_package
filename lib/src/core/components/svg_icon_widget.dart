import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIconWidget extends StatelessWidget {
  const SvgIconWidget({
    super.key,
    required this.name,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  });

  final String name;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      package: 'avis_package',
      width: width ?? 24,
      height: height ?? 24,
      matchTextDirection: true,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
      fit: fit,
    );
  }
}
