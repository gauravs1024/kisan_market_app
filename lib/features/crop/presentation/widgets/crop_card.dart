import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/crop_entity.dart';
import '../screens/crop_details_screen.dart';

class CropCard extends StatelessWidget {
  final CropEntity crop;

  const CropCard({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final double minPrice = crop.getDisplayMinPrice();
    final double maxPrice = crop.getDisplayMaxPrice();
    final double discountPercent = maxPrice > 0 ? ((maxPrice - minPrice) / maxPrice * 100) : 0;
    
    // For subtitle we can use a hardcoded fallback or format based on entity data
    // "Grade A | 500kg Bulk" as in image, let's adapt it to use entity data
    String subtitleText = crop.localName.isNotEmpty 
        ? '${crop.localName} | 1 ${crop.defaultUnit} Bulk' 
        : 'Grade A | 1 ${crop.defaultUnit} Bulk';
        
    if (crop.farmer != null) {
      final farmer = crop.farmer!;
      final location = [farmer.city, farmer.state].where((e) => e != null && e.isNotEmpty).join(', ');
      subtitleText = 'By ${farmer.fullName}${location.isNotEmpty ? ' • $location' : ''}';
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CropDetailsScreen(cropId: crop.id),
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
        margin: EdgeInsets.zero,
        child: SizedBox(
          height: 160.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left side - Image with Badge
              Expanded(
                flex: 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    crop.imageUrls.isEmpty
                        ? Container(
                            color: AppColors.primary.withAlpha(26),
                            child: Center(
                              child: Icon(Icons.eco, size: 40.r, color: AppColors.primary),
                            ),
                          )
                        : Image.network(
                            crop.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.primary.withAlpha(26),
                              child: Center(
                                child: Icon(Icons.broken_image, size: 36.r, color: AppColors.grey),
                              ),
                            ),
                          ),
                    // Discount Badge
                    if (discountPercent > 0)
                      Positioned(
                        top: 12.h,
                        left: 12.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC62828), // Deep red color matching image
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '-${discountPercent.toInt()}% BELOW MSP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Right side - Content
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        crop.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : const Color(0xFF1B5E20), // Dark green color
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      
                      // Subtitle
                      Text(
                        subtitleText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12.h),
                      
                      // Price Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹${minPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '₹${maxPrice.toStringAsFixed(0)} MSP',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Grab Deal Button
                      SizedBox(
                        width: double.infinity,
                        height: 36.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CropDetailsScreen(cropId: crop.id),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB300), // Amber/Yellow matching image
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 18.r),
                              SizedBox(width: 6.w),
                              Text(
                                'Grab Deal',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
