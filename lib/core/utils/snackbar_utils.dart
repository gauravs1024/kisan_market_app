import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class SnackBarUtils {
  /// Shows a customized SnackBar.
  /// If [customWidget] is provided, it replaces the default text content, allowing full customization.
  static void showSnackBar(
    BuildContext context, {
    String? message,
    Widget? customWidget,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? elevation,
    ShapeBorder? shape,
  }) {
    assert(message != null || customWidget != null,
        'Either message or customWidget must be provided');

    // Default margin if floating behavior is used and no margin is provided
    final effectiveMargin = behavior == SnackBarBehavior.floating
        ? (margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h))
        : margin;

    final snackBar = SnackBar(
      content: customWidget ??
          Text(
            message!,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
      backgroundColor:
          backgroundColor ?? Theme.of(context).colorScheme.inverseSurface,
      duration: duration,
      action: action,
      behavior: behavior,
      margin: effectiveMargin,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      shape: shape ??
          (behavior == SnackBarBehavior.floating
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))
              : null),
      elevation: elevation ?? 4,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Convenience method for showing a success snackbar
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    showSnackBar(
      context,
      duration: duration,
      behavior: behavior,
      customWidget: Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.white, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success,
    );
  }

  /// Convenience method for showing an error snackbar
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    showSnackBar(
      context,
      duration: duration,
      behavior: behavior,
      customWidget: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.white, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.error,
    );
  }

  /// Convenience method for showing an info/general snackbar
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    showSnackBar(
      context,
      duration: duration,
      behavior: behavior,
      customWidget: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.white, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blueAccent,
    );
  }
}
