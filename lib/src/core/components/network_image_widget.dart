import 'package:avis_package/src/core/_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkImageWidget extends StatelessWidget {
  const NetworkImageWidget({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.loadingWidget,
    this.errorWidget,
  });

  final String url;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  static bool isSvgUrl(String value) {
    if (value.trim().isEmpty) return false;
    final path = value.split('?').first.split('#').first.toLowerCase().trim();
    return path.endsWith('.svg');
  }

  static String resolveUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return ApiEndpoints.imagePath + trimmed;
  }

  Widget _defaultLoading() {
    return loadingWidget ??
        Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: color,
            ),
          ),
        );
  }

  Widget _defaultError() {
    return errorWidget ?? const Icon(Icons.broken_image, size: 32);
  }

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: _defaultError(),
      );
    }

    final resolvedUrl = resolveUrl(url);
    final useSvg = isSvgUrl(url) || isSvgUrl(resolvedUrl);

    if (useSvg) {
      return SvgPicture.network(
        resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        placeholderBuilder: (_) => SizedBox(
          width: width,
          height: height,
          child: _defaultLoading(),
        ),
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: width,
          height: height,
          child: _defaultError(),
        ),
      );
    }

    return Image.network(
      resolvedUrl,
      width: width,
      height: height,
      color: color,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: _defaultLoading(),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: width,
          height: height,
          child: _defaultError(),
        );
      },
    );
  }
}
