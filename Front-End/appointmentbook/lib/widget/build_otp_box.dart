import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BuildOtpBox extends StatefulWidget {
  const BuildOtpBox({
    super.key,
    required this.index,
    required this.focusNodes,
    required this.controllers,
  });

  final int index;
  final List<FocusNode> focusNodes;
  final List<TextEditingController> controllers;

  @override
  State<BuildOtpBox> createState() => _BuildOtpBoxState();
}

class _BuildOtpBoxState extends State<BuildOtpBox> {
  // ============================================================
  // HANDLE OTP INPUT
  // ============================================================

  void _onOtpChanged(String value) {
    // ------------------------------------------------------------
    // User entered something
    // ------------------------------------------------------------

    if (value.isNotEmpty) {
      // If user pasted multiple digits
      if (value.length > 1) {
        _handlePaste(value);

        return;
      }

      // Move to next box
      if (widget.index < 5) {
        widget.focusNodes[widget.index + 1].requestFocus();
      } else {
        // Last digit entered
        widget.focusNodes[widget.index].unfocus();
      }
    }
  }

  // ============================================================
  // HANDLE PASTE
  // ============================================================

  void _handlePaste(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return;
    }

    final limitedDigits = digits.substring(
      0,
      digits.length > 6 ? 6 : digits.length,
    );

    for (int i = 0; i < limitedDigits.length; i++) {
      widget.controllers[i].text = limitedDigits[i];
    }

    if (limitedDigits.length == 6) {
      widget.focusNodes[5].unfocus();
    } else {
      widget.focusNodes[limitedDigits.length].requestFocus();
    }

    setState(() {});
  }

  // ============================================================
  // HANDLE BACKSPACE
  // ============================================================

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (widget.controllers[widget.index].text.isEmpty && widget.index > 0) {
        widget.controllers[widget.index - 1].clear();

        widget.focusNodes[widget.index - 1].requestFocus();

        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 58,

      child: KeyboardListener(
        focusNode: FocusNode(),

        onKeyEvent: (event) {
          _handleKeyEvent(event);
        },

        child: TextField(
          controller: widget.controllers[widget.index],

          focusNode: widget.focusNodes[widget.index],

          textAlign: TextAlign.center,

          keyboardType: TextInputType.number,

          textInputAction: TextInputAction.next,

          maxLength: 1,

          inputFormatters: [FilteringTextInputFormatter.digitsOnly],

          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),

          decoration: InputDecoration(
            counterText: '',

            filled: true,

            fillColor: const Color(0xFFF8FAFC),

            contentPadding: EdgeInsets.zero,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),

              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),

              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),

              borderSide: const BorderSide(color: Color(0xFF1264E8), width: 2),
            ),
          ),

          onChanged: (value) {
            _onOtpChanged(value);
          },
        ),
      ),
    );
  }
}
