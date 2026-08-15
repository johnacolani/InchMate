import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../blocs/calculator_bloc.dart';
import '../blocs/calculator_event.dart';
import '../blocs/calculator_state.dart';

/// Bottom-sheet history tape. Tap a row to reuse its result; tap the copy icon
/// to copy the value to the clipboard.
void _showCopySnack(BuildContext context, String message) {
  final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          'Copied  $message',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15.sp),
        ),
        duration: const Duration(milliseconds: 1600),
        behavior: SnackBarBehavior.floating,
        width: isTablet ? 0.55.sw : null,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
}

class HistorySheet extends StatelessWidget {
  const HistorySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<CalculatorBloc>(),
        child: const HistorySheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 0.6.sh),
        child: BlocBuilder<CalculatorBloc, CalculatorState>(
          builder: (context, state) {
            final history = state.history;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _grabber(),
                _header(context, history.isNotEmpty),
                if (history.isEmpty)
                  _emptyState()
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      itemCount: history.length,
                      separatorBuilder: (_, __) => Divider(
                        color: Colors.grey.shade800,
                        height: 1,
                      ),
                      itemBuilder: (_, i) => _HistoryTile(entry: history[i]),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _grabber() => Container(
        margin: EdgeInsets.only(top: 10.h, bottom: 4.h),
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(2.r),
        ),
      );

  Widget _header(BuildContext context, bool hasItems) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 8.w, 6.h),
      child: Row(
        children: [
          Text(
            'History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (hasItems)
            TextButton.icon(
              onPressed: () =>
                  context.read<CalculatorBloc>().add(ClearHistoryEvent()),
              icon: Icon(Icons.delete_outline,
                  color: const Color(0xFFFF9F0A), size: 18.dm),
              label: Text('Clear',
                  style: TextStyle(
                      color: const Color(0xFFFF9F0A), fontSize: 14.sp)),
            ),
        ],
      ),
    );
  }

  Widget _emptyState() => Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(Icons.history, color: Colors.grey.shade600, size: 40.dm),
            SizedBox(height: 8.h),
            Text(
              'No calculations yet',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
            ),
          ],
        ),
      );
}

class _HistoryTile extends StatelessWidget {
  final CalcHistoryEntry entry;
  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<CalculatorBloc>().add(ReuseHistoryEvent(
              result: entry.result,
              linearResult: entry.linearResult,
              squareResult: entry.squareResult,
            ));
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.expression,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 12.sp),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '= ${entry.result}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'li ${entry.linearResult}   •   sq ${entry.squareResult}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: const Color(0xFFC7ADD5), fontSize: 11.sp),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy, color: Colors.grey.shade400, size: 18.dm),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: entry.result));
                _showCopySnack(context, entry.result);
              },
            ),
          ],
        ),
      ),
    );
  }
}
