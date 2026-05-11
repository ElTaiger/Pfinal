import 'dart:ui';
import 'package:flutter/material.dart';

class FloatingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leading;
  final Widget? title;
  final List<Widget>? actions;
  final bool isScrolled;
  final bool centerTitle;
  final double? leadingWidth;
  final double? titleSpacing;
  final Widget? flexibleSpace;

  const FloatingAppBar({
    super.key,
    required this.leading,
    this.title,
    this.actions,
    this.isScrolled = true,
    this.centerTitle = true,
    this.leadingWidth,
    this.titleSpacing,
    this.flexibleSpace,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 25, left: 40, right: 40),
      height: 70,
      child: Stack(
        children: [
          Hero(
            tag: 'floating_app_bar_bg_hero',
            child: Material(
              type: MaterialType.transparency,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: isScrolled ? 15.0 : 0.0, 
                    end: isScrolled ? 15.0 : 0.0,
                  ),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  builder: (context, blurValue, child) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        decoration: BoxDecoration(
                          color: isScrolled ? Colors.black.withOpacity(0.65) : Colors.transparent,
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(color: isScrolled ? Colors.white30 : Colors.transparent, width: 1),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          AppBar(
            forceMaterialTransparency: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 70,
            centerTitle: centerTitle,
            titleSpacing: titleSpacing,
            leadingWidth: leadingWidth,
            leading: leading,
            title: title,
            actions: actions,
            flexibleSpace: flexibleSpace,
          ),
        ],
      ),
    );
  }
}

class SequentialFadeHero extends StatelessWidget {
  final String tag;
  final Widget child;

  const SequentialFadeHero({required this.tag, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
        return Material(
          type: MaterialType.transparency,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              double progress = flightDirection == HeroFlightDirection.push ? animation.value : 1.0 - animation.value;
              double outOpacity = 0.0;
              double inOpacity = 0.0;
              if (progress <= 0.5) {
                outOpacity = 1.0 - (progress * 2.0);
              } else {
                inOpacity = (progress - 0.5) * 2.0;
              }
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (outOpacity > 0.0) Opacity(opacity: outOpacity, child: OverflowBox(maxWidth: double.infinity, maxHeight: double.infinity, child: fromHeroContext.widget)),
                  if (inOpacity > 0.0) Opacity(opacity: inOpacity, child: OverflowBox(maxWidth: double.infinity, maxHeight: double.infinity, child: toHeroContext.widget)),
                ],
              );
            },
          ),
        );
      },
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}
