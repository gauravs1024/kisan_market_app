import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  /// Shows a modal full-screen frosted glass loading indicator overlay.
  /// 
  /// Safe to call multiple times (will ignore subsequent show calls if already showing).
  static void show(OverlayState overlayState, {String message = 'Please wait...'}) {
    if (_overlayEntry != null) return; // Already showing
    
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Frosted Glass Blur
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: isDark ? Colors.black.withAlpha(140) : Colors.black.withAlpha(64),
                ),
              ),
              // Centered Alert Dialog Container
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  margin: EdgeInsets.symmetric(horizontal: 40.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark ? Colors.white.withAlpha(26) : Colors.black.withAlpha(13),
                      width: 1.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(64),
                        blurRadius: 20.r,
                        offset: Offset(0, 10.h),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 32.r,
                        width: 32.r,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                          strokeWidth: 3.w,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlayState.insert(_overlayEntry!);
  }

  /// Hides the active loading indicator overlay.
  static void hide() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}
