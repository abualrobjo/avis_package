import 'package:avis_package/src/core/_core.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Image.network(
      ApiEndpoints.imagePath + url,
      width: width,
      height: height,
      color: color,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return loadingWidget ??
            Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.broken_image, size: 32);
      },
    );
  }
}
