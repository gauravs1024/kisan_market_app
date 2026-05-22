import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

Widget buildShimmerLoading(
  ThemeData theme,
  AnimationController shimmerController,
) {
  return GridView.builder(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 0.72,
    ),
    itemCount: 6,
    itemBuilder: (context, index) {
      return AnimatedBuilder(
        animation: shimmerController,
        builder: (context, child) {
          final opacity = 0.3 + 0.4 * (1.0 - shimmerController.value);
          return Opacity(
            opacity: opacity,
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 110.h,
                    color: AppColors.grey500.withAlpha(77),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 60.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: AppColors.grey500.withAlpha(77),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: AppColors.grey500.withAlpha(77),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          Container(
                            width: 80.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: AppColors.grey500.withAlpha(77),
                              borderRadius: BorderRadius.circular(4.r),
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
        },
      );
    },
  );
}
