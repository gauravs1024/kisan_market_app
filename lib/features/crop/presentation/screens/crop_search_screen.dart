import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubits/crop_search_cubit.dart';
import '../cubits/crop_search_state.dart';
import '../widgets/crop_card.dart';
import '../widgets/crop_shimmer_widget.dart';

class CropSearchScreen extends StatefulWidget {
  const CropSearchScreen({super.key});

  @override
  State<CropSearchScreen> createState() => _CropSearchScreenState();
}

class _CropSearchScreenState extends State<CropSearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<CropSearchCubit>().searchCrops(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.r),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 42.h,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightGreyShade,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark ? AppColors.white.withAlpha(20) : AppColors.lightGrey200,
            ),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _onSearchChanged,
            onSubmitted: (val) {
              context.read<CropSearchCubit>().searchCrops(val);
            },
            decoration: InputDecoration(
              hintText: 'Search crops e.g. Wheat...',
              hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.grey),
              prefixIcon: Icon(Icons.search, size: 20.r, color: AppColors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, size: 18.r, color: AppColors.grey),
                      onPressed: () {
                        _searchController.clear();
                        context.read<CropSearchCubit>().clearSearch();
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
        ),
        actions: const [],
      ),
      body: BlocBuilder<CropSearchCubit, CropSearchState>(
        builder: (context, state) {
          if (state is CropSearchInitial) {
            return _buildPlaceholderState(
              icon: Icons.eco_outlined,
              title: 'Search Crops Catalog',
              subtitle: 'Start typing to search crops dynamically from the catalog.',
            );
          } else if (state is CropSearchLoading) {
            return buildShimmerLoading(theme, _shimmerController);
          } else if (state is CropSearchLoaded) {
            final crops = state.crops;
            if (crops.isEmpty) {
              return _buildPlaceholderState(
                icon: Icons.search_off_outlined,
                title: 'No Crops Found',
                subtitle: 'We couldn\'t find any crops matching "${_searchController.text}".',
              );
            }
            return GridView.builder(
              padding: EdgeInsets.all(16.r),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.72,
              ),
              itemCount: crops.length,
              itemBuilder: (context, index) {
                return CropCard(crop: crops[index]);
              },
            );
          } else if (state is CropSearchError) {
            return _buildPlaceholderState(
              icon: Icons.error_outline,
              title: 'Search Failed',
              subtitle: state.message,
              actionButton: ElevatedButton.icon(
                onPressed: () {
                  context.read<CropSearchCubit>().searchCrops(_searchController.text);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPlaceholderState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? actionButton,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64.r, color: AppColors.primary.withAlpha(102)),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13.sp, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            if (actionButton != null) ...[
              SizedBox(height: 20.h),
              actionButton,
            ],
          ],
        ),
      ),
    );
  }
}
