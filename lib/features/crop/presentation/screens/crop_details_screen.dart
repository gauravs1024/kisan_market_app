import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubits/crop_detail_cubit.dart';
import '../cubits/crop_detail_state.dart';
import '../../../../injection_container.dart' as di;

class CropDetailsScreen extends StatefulWidget {
  final int cropId;

  const CropDetailsScreen({super.key, required this.cropId});

  @override
  State<CropDetailsScreen> createState() => _CropDetailsScreenState();
}

class _CropDetailsScreenState extends State<CropDetailsScreen> {
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider<CropDetailCubit>(
      create: (_) => di.sl<CropDetailCubit>()..fetchCropById(widget.cropId),
      child: Scaffold(
        body: BlocBuilder<CropDetailCubit, CropDetailState>(
          builder: (context, state) {
            if (state is CropDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CropDetailLoaded) {
              final crop = state.crop;
              return CustomScrollView(
                slivers: [
                  // Sliver App Bar with Crop Image
                  SliverAppBar(
                    expandedHeight: 280.h,
                    pinned: true,
                    elevation: 0,
                    leading: Padding(
                      padding: EdgeInsets.all(8.r),
                      child: CircleAvatar(
                        backgroundColor: isDark ? AppColors.black.withAlpha(115) : AppColors.white.withAlpha(179),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.r, color: isDark ? AppColors.white : AppColors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Images Carousel
                          crop.imageUrls.isEmpty
                              ? Container(
                                  color: AppColors.primary.withAlpha(26),
                                  child: Center(
                                    child: Icon(
                                      Icons.eco,
                                      size: 72.r,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : PageView.builder(
                                  controller: _imagePageController,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentImageIndex = index;
                                    });
                                  },
                                  itemCount: crop.imageUrls.length,
                                  itemBuilder: (context, index) {
                                    return Image.network(
                                      crop.imageUrls[index],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: AppColors.primary.withAlpha(26),
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 64.r,
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          // Carousel Dot Indicator
                          if (crop.imageUrls.length > 1)
                            Positioned(
                              bottom: 16.h,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  crop.imageUrls.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: _currentImageIndex == index ? 16.w : 6.w,
                                    height: 6.h,
                                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3.r),
                                      color: _currentImageIndex == index
                                          ? AppColors.primary
                                          : AppColors.white.withAlpha(153),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Bottom elegant gradient shadow
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, AppColors.black.withAlpha(138)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Crop Content Details
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category and Unit tags
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(31),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  crop.categoryName,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.white.withAlpha(26) : AppColors.lightGreyShade,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: isDark ? AppColors.white.withAlpha(20) : AppColors.lightGrey200,
                                  ),
                                ),
                                child: Text(
                                  'Standard Unit: ${crop.defaultUnit.toUpperCase()}',
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          // Crop Names Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20.r),
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withAlpha(10),
                                  blurRadius: 12.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  crop.name,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 26.sp,
                                  ),
                                ),
                                if (crop.localName.isNotEmpty &&
                                    crop.localName.toLowerCase() != crop.name.toLowerCase()) ...[
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      Text(
                                        'Local Name: ',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        crop.localName,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: theme.textTheme.bodyMedium?.color,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Price Details Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20.r),
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withAlpha(10),
                                  blurRadius: 12.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24.r,
                                  backgroundColor: AppColors.primary.withAlpha(31),
                                  child: Icon(Icons.currency_rupee, color: AppColors.primary, size: 24.r),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Estimated Market Price',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: AppColors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        '₹${crop.getDisplayMinPrice().toStringAsFixed(0)} - ₹${crop.getDisplayMaxPrice().toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(26),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    'Per ${crop.defaultUnit.toLowerCase()}',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Farmer Details Card
                          if (crop.farmer != null) ...[
                            Text(
                              'Farmer Details',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: theme.cardTheme.color,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: isDark ? AppColors.white.withAlpha(20) : AppColors.lightGrey200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30.r,
                                    backgroundColor: AppColors.primary.withAlpha(26),
                                    backgroundImage: crop.farmer!.profileImageUrl != null
                                        ? NetworkImage(crop.farmer!.profileImageUrl!)
                                        : null,
                                    child: crop.farmer!.profileImageUrl == null
                                        ? Icon(Icons.person, color: AppColors.primary, size: 30.r)
                                        : null,
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          crop.farmer!.fullName,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (crop.farmer!.city != null || crop.farmer!.state != null) ...[
                                          SizedBox(height: 4.h),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_outlined, size: 14.r, color: AppColors.grey),
                                              SizedBox(width: 4.w),
                                              Expanded(
                                                child: Text(
                                                  [crop.farmer!.city, crop.farmer!.state]
                                                      .where((e) => e != null && e.isNotEmpty)
                                                      .join(', '),
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: AppColors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (crop.farmer!.phone != null) ...[
                                          SizedBox(height: 4.h),
                                          Row(
                                            children: [
                                              Icon(Icons.phone_outlined, size: 14.r, color: AppColors.grey),
                                              SizedBox(width: 4.w),
                                              Text(
                                                crop.farmer!.phone!,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: AppColors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // Call logic could be added here
                                    },
                                    icon: CircleAvatar(
                                      backgroundColor: AppColors.primary,
                                      radius: 20.r,
                                      child: Icon(Icons.call, color: AppColors.white, size: 20.r),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],

                          // Description / Detailed Information placeholder
                          Text(
                            'About this crop',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'This represents dynamic details of ${crop.name} registered under the ${crop.categoryName} category. Farmers can list produces matching this standard catalog crop to trade in the marketplace. The standard trade unit defined is ${crop.defaultUnit.toLowerCase()}.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDark ? AppColors.grey500 : AppColors.lightSubtext,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is CropDetailError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64.r, color: AppColors.error),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<CropDetailCubit>().fetchCropById(widget.cropId);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
