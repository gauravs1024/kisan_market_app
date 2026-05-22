import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubits/crop_cubit.dart';
import '../cubits/crop_category_cubit.dart';
import '../cubits/crop_category_state.dart';

class CropEmptyState extends StatelessWidget {
  final String text;

  const CropEmptyState({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_outlined,
            size: 64.r,
            color: AppColors.grey.withAlpha(128),
          ),
          SizedBox(height: 16.h),
          Text(
            text,
            style: TextStyle(color: AppColors.grey, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}

class CropErrorState extends StatelessWidget {
  final String errorMessage;

  const CropErrorState({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.r, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              errorMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Please check your internet connection and try again.',
              style: TextStyle(color: AppColors.grey, fontSize: 13.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CropCubit>().fetchCrops();
                context.read<CropCategoryCubit>().fetchCropCategories();
              },
              icon: Icon(Icons.refresh, size: 20.r),
              label: Text('Retry', style: TextStyle(fontSize: 14.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CropCategoryListView extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final Animation<double> shimmerAnimation;

  const CropCategoryListView({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.shimmerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<CropCategoryCubit, CropCategoryState>(
      builder: (context, state) {
        if (state is CropCategoryLoading) {
          return _buildCategoryShimmer(theme);
        } else if (state is CropCategoryLoaded) {
          final categories = state.categories;
          return SizedBox(
            height: 90.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                final isAll = index == 0;
                final String name = isAll ? 'All' : categories[index - 1].name;
                final String imageUrl = isAll
                    ? ''
                    : categories[index - 1].imageUrl;
                final isSelected =
                    selectedCategory.toLowerCase() == name.toLowerCase();

                return GestureDetector(
                  onTap: () => onCategorySelected(name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: 12.w, top: 4.h, bottom: 4.h),
                    width: 70.w,
                    child: Column(
                      children: [
                        // Image/Icon Container
                        Container(
                          width: 54.r,
                          height: 54.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.white.withAlpha(26)
                                        : AppColors.lightGrey200),
                              width: isSelected ? 3.r : 1.5.r,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(77),
                                      blurRadius: 8.r,
                                      spreadRadius: 1.r,
                                    ),
                                  ]
                                : null,
                          ),
                          child: ClipOval(
                            child: isAll
                                ? Container(
                                    color: AppColors.primary.withAlpha(26),
                                    child: Icon(
                                      Icons.eco_rounded,
                                      color: AppColors.primary,
                                      size: 28.r,
                                    ),
                                  )
                                : Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: AppColors.primary
                                                  .withAlpha(26),
                                              child: Icon(
                                                Icons.eco_rounded,
                                                color: AppColors.grey,
                                                size: 24.r,
                                              ),
                                            ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        // Label text
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : theme.textTheme.bodyMedium?.color?.withAlpha(
                                    204,
                                  ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else if (state is CropCategoryError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'Failed to load categories',
                style: TextStyle(color: AppColors.error, fontSize: 12.sp),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCategoryShimmer(ThemeData theme) {
    return SizedBox(
      height: 90.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: shimmerAnimation,
            builder: (context, child) {
              final opacity = 0.3 + 0.4 * (1.0 - shimmerAnimation.value);
              return Opacity(
                opacity: opacity,
                child: Container(
                  margin: EdgeInsets.only(right: 12.w, top: 4.h, bottom: 4.h),
                  width: 70.w,
                  child: Column(
                    children: [
                      Container(
                        width: 54.r,
                        height: 54.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.grey500.withAlpha(77),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 45.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: AppColors.grey500.withAlpha(77),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
