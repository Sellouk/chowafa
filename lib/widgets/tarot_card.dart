import 'package:flutter/material.dart';
import 'dart:math';

class TarotCard extends StatefulWidget {
  final String frontImage;
  final String backImage;
  final double width;
  final double height;
  final bool isFlipped;
  final Duration flipDelay;

  const TarotCard({
    super.key,
    required this.frontImage,
    required this.backImage,
    required this.width,
    required this.height,
    this.isFlipped = false,
    this.flipDelay = Duration.zero,
  });

  @override
  State<TarotCard> createState() => _TarotCardState();
}

class _TarotCardState extends State<TarotCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = false;
  bool _hasStartedFlip = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _animation.addListener(() {
      if (_animation.value >= 0.5 && !_showFront) {
        setState(() {
          _showFront = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(TarotCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped && !_hasStartedFlip) {
      _hasStartedFlip = true;
      Future.delayed(widget.flipDelay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double rotationValue = _animation.value * pi;
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotationValue),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9B59B6).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _showFront
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: Image.asset(
                        widget.frontImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF2D1B47),
                            child: const Center(
                              child: Icon(
                                Icons.auto_awesome,
                                color: Color(0xFFE8D5B7),
                                size: 30,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Image.asset(
                      widget.backImage,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        );
      },
    );
  }
}
