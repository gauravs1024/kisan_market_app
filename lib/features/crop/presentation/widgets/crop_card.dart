import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/crop_entity.dart';
import '../screens/crop_details_screen.dart';

class CropCard extends StatefulWidget {
  final CropEntity crop;

  const CropCard({super.key, required this.crop});

  @override
  State<CropCard> createState() => _CropCardState();
}

class _CropCardState extends State<CropCard> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CropDetailsScreen(cropId: widget.crop.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isDark ? 2 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: isDark
              ? BorderSide(color: AppColors.white.withAlpha(20), width: 1.w)
              : BorderSide(color: AppColors.lightGrey200, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image / PageView section
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  widget.crop.imageUrls.isEmpty
                      ? Container(
                          color: AppColors.primary.withAlpha(26),
                          child: Center(
                            child: Icon(Icons.eco, size: 40.r, color: AppColors.primary),
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          onPageChanged: (idx) {
                            setState(() {
                              _currentImageIndex = idx;
                            });
                          },
                          itemCount: widget.crop.imageUrls.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              widget.crop.imageUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppColors.primary.withAlpha(26),
                                child: Center(
                                  child: Icon(Icons.broken_image, size: 36.r, color: AppColors.grey),
                                ),
                              ),
                            );
                          },
                        ),
                  // Carousel dots indicator if multiple images
                  if (widget.crop.imageUrls.length > 1)
                    Positioned(
                      bottom: 8.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.crop.imageUrls.length,
                          (index) => Container(
                            width: 6.w,
                            height: 6.h,
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? AppColors.white
                                  : AppColors.white.withAlpha(102),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Crop details section
            Expanded(
              flex: 10,
              child: Padding(
                padding: EdgeInsets.all(10.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        widget.crop.categoryName,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Name and local name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.crop.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.crop.localName.isNotEmpty &&
                            widget.crop.localName.toLowerCase() != widget.crop.name.toLowerCase())
                          Text(
                            '(${widget.crop.localName})',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    const Spacer(),
                    // Price Details & Standard Unit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price estimate
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Est. Price',
                                style: TextStyle(fontSize: 9.sp, color: AppColors.grey),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                '₹${widget.crop.getDisplayMinPrice().toStringAsFixed(0)} - ₹${widget.crop.getDisplayMaxPrice().toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Unit',
                              style: TextStyle(fontSize: 9.sp, color: AppColors.grey),
                            ),
                            SizedBox(height: 2.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.white.withAlpha(26) : AppColors.lightGreyShade,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                widget.crop.defaultUnit.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 8.5.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
}
