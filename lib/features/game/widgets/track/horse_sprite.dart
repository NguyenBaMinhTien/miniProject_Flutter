import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const List<String> _horseFrames = [
  'assets/images/horse/horse1.png',
  'assets/images/horse/horse2.png',
  'assets/images/horse/horse3.png',
  'assets/images/horse/horse4.png',
  'assets/images/horse/horse5.png',
];

class HorseSprite extends StatefulWidget {
  const HorseSprite({
    super.key,
    required this.color,
    required this.isRunning,
    required this.isWinner,
  });

  final Color color;
  final bool isRunning;
  final bool isWinner;

  @override
  State<HorseSprite> createState() => _HorseSpriteState();
}

class _HorseSpriteState extends State<HorseSprite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (widget.isRunning) {
      _anim.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant HorseSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _anim.repeat();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _anim.stop();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.isWinner ? 'Winner horse' : 'Race horse',
      image: true,
      child: AnimatedScale(
        scale: widget.isWinner ? 1.18 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        child: SizedBox(
          width: 80, // Larger to accommodate detailed SVG
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: <Widget>[
              AnimatedBuilder(
                animation: _anim,
                builder: (context, child) {
                  final frame = widget.isRunning
                      ? (_anim.value * _horseFrames.length).floor() %
                          _horseFrames.length
                      : 0;
                  return Image.asset(
                    _horseFrames[frame],
                    width: 80,
                    height: 60,
                    fit: BoxFit.contain,
                  );
                },
              ),
              Positioned(
                right: 5,
                top: 5,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black45,
                          blurRadius: 2,
                          offset: Offset(1, 1))
                    ],
                  ),
                  child: const SizedBox(width: 16, height: 16),
                ),
              ),
              if (widget.isWinner)
                const Positioned(
                  top: -10,
                  child: Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
