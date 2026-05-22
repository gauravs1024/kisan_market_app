import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'logger.dart';

class ImagePickerHelper {
  ImagePickerHelper._();

  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from the specified source (camera or gallery).
  static Future<XFile?> pickImage(ImageSource source) async {
    try {
      AppLogger.d('ImagePickerHelper: Picking image from source: $source');
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compress to 80% to optimize upload size
        maxWidth: 1024,   // Scale down resolution to max 1024 width
      );
      if (image != null) {
        AppLogger.i('ImagePickerHelper: Successfully picked image: ${image.path}');
      } else {
        AppLogger.d('ImagePickerHelper: User cancelled picking image');
      }
      return image;
    } catch (e) {
      AppLogger.e('ImagePickerHelper: Error picking image: $e');
      return null;
    }
  }

  /// Displays a bottom sheet prompting the user to select either
  /// Camera or Gallery to choose an image.
  static Future<XFile?> showImageSourceBottomSheet(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(38),
                blurRadius: 15.r,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull bar indicator
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withAlpha(38) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceButton(
                    context: sheetContext,
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () async {
                      final image = await pickImage(ImageSource.camera);
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext, image);
                      }
                    },
                  ),
                  _buildSourceButton(
                    context: sheetContext,
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () async {
                      final image = await pickImage(ImageSource.gallery);
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext, image);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSourceButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : theme.primaryColor.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white.withAlpha(13) : theme.primaryColor.withAlpha(26),
              ),
            ),
            child: Icon(
              icon,
              size: 24.r,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
