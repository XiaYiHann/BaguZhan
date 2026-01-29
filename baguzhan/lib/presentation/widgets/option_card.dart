import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

enum _OptionVisualState {
  normal,
  selected,
  correct,
  incorrect,
}

class _OptionVisualStyle {
  const _OptionVisualStyle({
    required this.borderColor,
    required this.backgroundColor,
    required this.indexBackgroundColor,
    required this.indexTextColor,
  });

  final Color borderColor;
  final Color backgroundColor;
  final Color indexBackgroundColor;
  final Color indexTextColor;
}

class OptionCard extends StatefulWidget {
  const OptionCard({
    super.key,
    required this.indexLabel,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isIncorrect,
    required this.isDisabled,
    required this.onTap,
  });

  final String indexLabel;
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isIncorrect;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  State<OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<OptionCard> {
  bool _pressed = false;

  static const _styles = <_OptionVisualState, _OptionVisualStyle>{
    _OptionVisualState.normal: _OptionVisualStyle(
      borderColor: AppTheme.borderGray,
      backgroundColor: Colors.white,
      indexBackgroundColor: Colors.white,
      indexTextColor: AppTheme.textSecondary,
    ),
    _OptionVisualState.selected: _OptionVisualStyle(
      borderColor: AppTheme.duoBlue,
      backgroundColor: AppTheme.selectedBackground,
      indexBackgroundColor: AppTheme.duoBlue,
      indexTextColor: Colors.white,
    ),
    _OptionVisualState.correct: _OptionVisualStyle(
      borderColor: AppTheme.duoGreen,
      backgroundColor: AppTheme.correctBackground,
      indexBackgroundColor: AppTheme.duoGreen,
      indexTextColor: Colors.white,
    ),
    _OptionVisualState.incorrect: _OptionVisualStyle(
      borderColor: AppTheme.duoRed,
      backgroundColor: AppTheme.incorrectBackground,
      indexBackgroundColor: AppTheme.duoRed,
      indexTextColor: Colors.white,
    ),
  };

  _OptionVisualState get _visualState {
    if (widget.isCorrect) {
      return _OptionVisualState.correct;
    }
    if (widget.isIncorrect) {
      return _OptionVisualState.incorrect;
    }
    if (widget.isSelected) {
      return _OptionVisualState.selected;
    }
    return _OptionVisualState.normal;
  }

  void _setPressed(bool value) {
    if (widget.isDisabled) {
      return;
    }
    if (_pressed == value) {
      return;
    }
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = _styles[_visualState]!;
    final shadow = _pressed ? AppTheme.shadowPressed : AppTheme.shadowDown;
    final translateY = _pressed ? 2.0 : 0.0;

    return GestureDetector(
      onTap: widget.isDisabled
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedContainer(
        duration: AppTheme.durationPress,
        curve: AppTheme.curvePress,
        transform: Matrix4.translationValues(0, translateY, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border:
              Border.all(color: style.borderColor, width: AppTheme.borderWidth),
          boxShadow: [shadow],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: style.indexBackgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                border: Border.all(
                  color: style.borderColor,
                  width: AppTheme.borderWidth,
                ),
              ),
              child: Text(
                widget.indexLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: style.indexTextColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.text,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
