import 'package:flutter/material.dart';

/// Image that starts fitted to the space and zooms with a pinch.
/// A second double tap returns it to the original size.
class PinchZoomImage extends StatefulWidget {
  const PinchZoomImage({
    super.key,
    required this.imageUrl,
    this.borderRadius = 16,
  });

  final String imageUrl;
  final double borderRadius;

  @override
  State<PinchZoomImage> createState() => _PinchZoomImageState();
}

class _PinchZoomImageState extends State<PinchZoomImage> {
  final _controller = TransformationController();
  Offset? _doubleTapPoint;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    final point = _doubleTapPoint ?? Offset.zero;
    final zoomed = _controller.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed) {
      _controller.value = Matrix4.identity();
      return;
    }
    const scale = 2.5;
    _controller.value = Matrix4.identity()
      ..translateByDouble(
        -point.dx * (scale - 1),
        -point.dy * (scale - 1),
        0,
        1,
      )
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: GestureDetector(
        onDoubleTapDown: (details) => _doubleTapPoint = details.localPosition,
        onDoubleTap: _onDoubleTap,
        child: InteractiveViewer(
          transformationController: _controller,
          minScale: 1,
          maxScale: 5,
          clipBehavior: Clip.hardEdge,
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const SizedBox.expand(
                child: Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) => const SizedBox.expand(
              child: Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.white70),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

bool isImageResource({required String type, required String url}) {
  if (type == 'image') return true;
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
  return path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.png') ||
      path.endsWith('.webp') ||
      path.endsWith('.gif');
}
