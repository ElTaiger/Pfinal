import 'package:flutter/material.dart';

void animarHaciaCarrito(BuildContext context, GlobalKey cartKey, BuildContext itemContext, String imageUrl) {
  final RenderBox? cartBox = cartKey.currentContext?.findRenderObject() as RenderBox?;
  final RenderBox? itemBox = itemContext.findRenderObject() as RenderBox?;

  if (cartBox == null || itemBox == null) return;

  final cartPosition = cartBox.localToGlobal(Offset.zero);
  final itemPosition = itemBox.localToGlobal(Offset.zero);

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
        builder: (context, value, child) {
          final currentX = itemPosition.dx + (cartPosition.dx - itemPosition.dx) * value;
          final currentY = itemPosition.dy + (cartPosition.dy - itemPosition.dy) * value;
          final currentScale = 1.0 - (0.5 * value); // se hace un poco más pequeño
          final currentOpacity = 1.0 - (0.5 * value);

          return Positioned(
            left: currentX,
            top: currentY,
            child: Transform.scale(
              scale: currentScale,
              child: Opacity(
                opacity: currentOpacity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(imageUrl, width: 50, height: 75, fit: BoxFit.cover),
                ),
              ),
            ),
          );
        },
        onEnd: () {
          overlayEntry.remove();
        },
      );
    },
  );

  Overlay.of(context).insert(overlayEntry);
}
