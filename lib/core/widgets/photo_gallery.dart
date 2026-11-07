import 'package:flutter/material.dart';
import 'app_image.dart';

/// Lapozható fotógaléria (pöttyökkel és számlálóval); koppintásra teljes képernyős nézet.
class PhotoGallery extends StatefulWidget {
  final List<String> images;
  final double height;

  const PhotoGallery({super.key, required this.images, this.height = 260});

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _placeholder(double h) => Container(
    height: h,
    width: double.infinity,
    color: const Color(0xFF072A40),
    child: const Icon(Icons.villa_rounded, size: 70, color: Color(0xFF99FF99)),
  );

  void _openFullscreen(int start) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenGallery(images: widget.images, initialIndex: start),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imgs = widget.images;
    if (imgs.isEmpty) return _placeholder(widget.height);

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: imgs.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => _openFullscreen(i),
              child: AppImage(
                imgs[i],
                height: widget.height,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _placeholder(widget.height),
              ),
            ),
          ),
          if (imgs.length > 1) ...[
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                child: Text('${_index + 1} / ${imgs.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  imgs.length,
                      (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 9 : 6,
                    height: i == _index ? 9 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _index ? const Color(0xFFFF9F1C) : Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FullscreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullscreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_index + 1} / ${widget.images.length}', style: const TextStyle(fontSize: 15)),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) => InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: AppImage(
              widget.images[i],
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const Icon(Icons.broken_image_rounded, color: Colors.white54, size: 60),
            ),
          ),
        ),
      ),
    );
  }
}
