import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import '../blocs/calculator_bloc.dart';
import '../blocs/calculator_event.dart';
import '../blocs/calculator_state.dart';
import '../widgets/app_info_overlay.dart';
import '../widgets/calculator_button.dart';
import '../widgets/history_sheet.dart';

class FractionCalculatorScreen extends StatelessWidget {
  const FractionCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191818),
      appBar: AppBar(
        backgroundColor: Color(0xFF191818),
        title: Center(
          child: Text(
            'InchMate',
            style: TextStyle(color: Colors.grey.shade300, fontSize: 16.sp),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.white,
            size: 18.dm,
          ),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const AppInfoOverlay(),
            barrierColor: Colors.transparent,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.paste, color: Colors.white, size: 19.dm),
            tooltip: 'Paste value',
            onPressed: () => _pasteValue(context),
          ),
          IconButton(
            icon: Icon(Icons.history, color: Colors.white, size: 20.dm),
            tooltip: 'History',
            onPressed: () => HistorySheet.show(context),
          ),
        ],
      ),
      body: BlocBuilder<CalculatorBloc, CalculatorState>(
        builder: (context, state) {
          return LayoutBuilder(builder: (context, constraints) {
            double maxWidth = constraints.maxWidth > 600
                ? constraints.maxWidth * 0.8
                : constraints.maxWidth;

            double maxHeight = constraints.maxHeight; // Get screen height
            return Center(
              child: Container(
                width: maxWidth,
                height: maxHeight, // Ensure it doesn't overflow
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                child: Column(
                  children: [
                    _buildDisplaySection(context, state, constraints),
                    _buildResultContainers(context, state),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 4.h),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          border: GradientBoxBorder(
                            width: 1.5.dm,
                            gradient: LinearGradient(colors: [
                              Colors.blue.shade300,
                              Colors.purple.shade300,
                            ]),
                          ),
                        ),
                        child: _buildCalculatorButtons(context),
                      ),
                    ),
                    // _buildAdBanner(),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  void _showSnack(BuildContext context, String message,
      {IconData? icon}) {
    // Scale text with the device (ScreenUtil) and, on tablets, constrain the
    // bar to a centered width so it doesn't stretch edge-to-edge with tiny text.
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: icon == null
              ? Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15.sp),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18.sp, color: Colors.white),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    ),
                  ],
                ),
          duration: const Duration(milliseconds: 1600),
          behavior: SnackBarBehavior.floating,
          width: isTablet ? 0.55.sw : null,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      );
  }

  void _copyValue(BuildContext context, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '0' || trimmed == 'Error') return;
    Clipboard.setData(ClipboardData(text: trimmed));
    _showSnack(context, 'Copied  $trimmed  ·  tap paste ⧉ to use it',
        icon: Icons.paste);
  }

  // Matches an integer, fraction, or mixed number (optionally negative).
  static final RegExp _pasteablePattern = RegExp(r'^-?\d+( \d+/\d+|/\d+)?$');

  Future<void> _pasteValue(BuildContext context) async {
    final bloc = context.read<CalculatorBloc>();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!context.mounted) return;

    final raw = (data?.text ?? '').replaceAll('"', '').trim();
    if (raw.isEmpty) {
      _showSnack(context, 'Clipboard is empty');
      return;
    }
    if (!_pasteablePattern.hasMatch(raw)) {
      _showSnack(context, "Can't paste \"$raw\" — not a number");
      return;
    }
    bloc.add(PasteEvent(raw));
    _showSnack(context, 'Pasted  $raw');
  }

  Widget _buildDisplaySection(
      BuildContext context, CalculatorState state, BoxConstraints constraints) {
    return Padding(
      padding: EdgeInsets.all(6.h),
      child: Container(
        decoration: BoxDecoration(
          color:
              Colors.blue.withValues(red: 0.2, blue: 1, green: 1, alpha: 0.1),
          border: GradientBoxBorder(
            width: 1.dm,
            gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.purple.shade300]),
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              constraints: BoxConstraints(
                maxHeight: 60.h, // Increased height for 3-4 lines
              ),
              child: AutoSizeText(
                state.expression,
                maxLines: 2, // Allow up to 4 lines
                minFontSize:
                    10.0.sp, // Smaller minimum size for longer expressions
                stepGranularity: 0.5.sp, // Required for decimal font sizes
                maxFontSize: constraints.maxWidth > 600
                    ? 16.sp
                    : 20.sp, // Smaller than original
                overflow: TextOverflow.clip,

                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[300],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _copyValue(context, state.displayText),
              child: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                constraints: BoxConstraints(
                  maxHeight: 40.h, // Keep result display compact
                  minHeight: 28.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.copy,
                        color: Colors.grey.shade500, size: 14.dm),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: AutoSizeText(
                        state.displayText,
                        maxLines: 2,
                        minFontSize: 18.sp,
                        stepGranularity: 0.5.sp,
                        maxFontSize: constraints.maxWidth > 600 ? 24.sp : 28.sp,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContainers(BuildContext context, CalculatorState state) {
    // Single row: linear feet anchored to the left, square feet to the right.
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1E1E),
        borderRadius: BorderRadius.circular(14.r),
        border: GradientBoxBorder(
          width: 1.5.dm,
          gradient: LinearGradient(colors: [
            Colors.blue.shade300,
            Colors.purple.shade300,
          ]),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: _buildResultInline(
                context, "", state.linearResult, Colors.white,
                alignEnd: false),
          ),
          Container(
            height: 28.h,
            width: 1.2,
            color: Colors.grey.shade700,
          ),
          Flexible(
            child: _buildResultInline(context, "sq ft", state.squareResult,
                const Color(0xFFC7ADD5),
                alignEnd: true),
          ),
        ],
      ),
    );
  }

  Widget _buildResultInline(BuildContext context, String label, String result,
      Color textColor,
      {required bool alignEnd}) {
    final showLabel = label.trim().isNotEmpty;
    final labelWidget = Text(
      label,
      style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp),
    );
    final valueWidget = Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          result,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );

    final children = alignEnd
        ? [
            valueWidget,
            if (showLabel) SizedBox(width: 6.w),
            if (showLabel) labelWidget,
          ]
        : [
            if (showLabel) labelWidget,
            if (showLabel) SizedBox(width: 6.w),
            valueWidget,
          ];

    return GestureDetector(
      onTap: () => _copyValue(context, result),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildCalculatorButtons(BuildContext context) {
    final rows = [
      _buildOperatorRow(["C", "±", "%", "÷"]),
      _buildNumberRow(["7", "8", "9", "×"]),
      _buildNumberRow(["4", "5", "6", "-"]),
      _buildNumberRow(["1", "2", "3", "+"]),
      _buildBottomRow(),
      _buildFractionRow(["1/4", "3/4", "(", ")"]),
      _buildFractionRow(["1/8", "3/8", "5/8", "7/8"]),
      _buildFractionRow(["1/16", "3/16", "5/16", "7/16"]),
      _buildFractionRow(["9/16", "11/16", "13/16", "15/16"]),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final rowHeight = constraints.maxHeight / rows.length;
        return Column(
          children: rows
              .map((row) => SizedBox(
                    height: rowHeight,
                    child: row,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildOperatorRow(List<String> buttons) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons
          .map((text) => CalculatorButton(
                text: text,
                isOperator: true,
              ))
          .toList(),
    );
  }

  Widget _buildNumberRow(List<String> buttons) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons.map((text) => CalculatorButton(text: text)).toList(),
    );
  }

  Widget _buildBottomRow() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CalculatorButton(text: "0"),
        CalculatorButton(text: "1/2"),
        CalculatorButton(text: "⌫", isOperator: true),
        CalculatorButton(text: "=", isOperator: true),
      ],
    );
  }

  Widget _buildFractionRow(List<String> fractions) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: fractions
          .map((text) => CalculatorButton(
                text: text,
                isFraction: true,
              ))
          .toList(),
    );
  }
}
