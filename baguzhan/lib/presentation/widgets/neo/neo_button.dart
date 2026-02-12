/// Neo-Brutal 风格按钮组件
library;

import 'package:flutter/material.dart';

import '../../../core/theme/neo_brutal_theme.dart';

/// Neo-Brutal 风格按钮
class NeoButton extends StatefulWidget {
  const NeoButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.type = NeoButtonType.primary,
    this.size = NeoButtonSize.medium,
    this.width,
    this.height,
    this.isLoading = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final NeoButtonType type;
  final NeoButtonSize size;
  final double? width;
  final double? height;
  final bool isLoading;

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _translateY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: NeoBrutalTheme.durationPress,
    );
    _translateY = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: NeoBrutalTheme.curvePress),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    if (widget.onPressed == null) {
      return NeoBrutalTheme.lockedGray;
    }
    switch (widget.type) {
      case NeoButtonType.primary:
        return NeoBrutalTheme.primary;
      case NeoButtonType.secondary:
        return NeoBrutalTheme.secondary;
      case NeoButtonType.accent:
        return NeoBrutalTheme.accent;
      case NeoButtonType.outline:
        return NeoBrutalTheme.surface;
    }
  }

  Color _getTextColor() {
    if (widget.onPressed == null) {
      return NeoBrutalTheme.charcoal.withOpacity(0.5);
    }
    return widget.type == NeoButtonType.outline
        ? NeoBrutalTheme.charcoal
        : Colors.white;
  }

  double _getHeight() {
    if (widget.height != null) return widget.height!;
    switch (widget.size) {
      case NeoButtonSize.small:
        return NeoBrutalTheme.buttonHeightSm;
      case NeoButtonSize.medium:
        return NeoBrutalTheme.buttonHeightMd;
      case NeoButtonSize.large:
        return NeoBrutalTheme.buttonHeightLg;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final bgColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final height = _getHeight();

    return AnimatedBuilder(
      animation: _translateY,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _isPressed ? _translateY.value : 0),
          child: GestureDetector(
            onTapDown: isEnabled ? _handleTapDown : null,
            onTapUp: isEnabled ? _handleTapUp : null,
            onTapCancel: isEnabled ? _handleTapCancel : null,
            onTap: widget.isLoading ? null : widget.onPressed,
            child: Container(
              width: widget.width,
              height: height,
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(
                  color: NeoBrutalTheme.borderColor,
                  width: NeoBrutalTheme.borderWidth,
                ),
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSm),
                boxShadow: _isPressed
                    ? NeoBrutalTheme.shadowPressed
                    : NeoBrutalTheme.shadowMd,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      )
                    : DefaultTextStyle(
                        style: TextStyle(
                          color: textColor,
                          fontSize: widget.size == NeoButtonSize.small ? 14 : 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                        child: widget.child,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Neo 文本按钮（便捷构造函数）
class NeoTextButton extends StatelessWidget {
  const NeoTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = NeoButtonType.primary,
    this.size = NeoButtonSize.medium,
    this.width,
  });

  final String text;
  final VoidCallback? onPressed;
  final NeoButtonType type;
  final NeoButtonSize size;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return NeoButton(
      onPressed: onPressed,
      type: type,
      size: size,
      width: width,
      child: Text(text.toUpperCase()),
    );
  }
}
