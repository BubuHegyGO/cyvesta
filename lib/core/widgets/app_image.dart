import 'package:flutter/material.dart';

/// Hálózati (Firebase Storage) vagy asset kép egységes megjelenítése.
class AppImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AppImage(
      this.path, {
        super.key,
        this.width,
        this.height,
        this.fit = BoxFit.cover,
        this.errorBuilder,
      });

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
        loadingBuilder: (c, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      );
    }
    return Image.asset(path, width: width, height: height, fit: fit, errorBuilder: errorBuilder);
  }
}
