import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationSelectorBottomSheet<T> extends StatefulWidget {
  final String title;
  final Future<List<T>> Function() loadItems;
  final String Function(T) itemLabel;
  final void Function(T) onSelected;

  const LocationSelectorBottomSheet({
    super.key,
    required this.title,
    required this.loadItems,
    required this.itemLabel,
    required this.onSelected,
  });

  @override
  State<LocationSelectorBottomSheet<T>> createState() =>
      _LocationSelectorBottomSheetState<T>();
}

class _LocationSelectorBottomSheetState<T>
    extends State<LocationSelectorBottomSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _allItems = [];
  List<T> _filteredItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await widget.loadItems();
      if (mounted) {
        setState(() {
          _allItems = items;
          _filteredItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) {
          final label = widget.itemLabel(item).toLowerCase();
          return label.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 0.75.sh,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B18) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Drag handle bar
          SizedBox(height: 12.h),
          Container(
            width: 48.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey[300],
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20.sp,
                    color: isDark ? Colors.white : Colors.green[900],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 24.r),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Search Field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 8.r,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search here...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.primaryColor,
                    size: 22.r,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, size: 18.r),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withAlpha(10)
                      : Colors.grey[50],
                  contentPadding: EdgeInsets.symmetric(vertical: 0.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: theme.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Content List / Loading / Error
          Expanded(
            child: Builder(
              builder: (context) {
                if (_isLoading) {
                  return _buildShimmerLoading(theme, isDark);
                }

                if (_errorMessage != null) {
                  return _buildErrorState(theme, isDark);
                }

                if (_filteredItems.isEmpty) {
                  return _buildEmptyState(theme, isDark);
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    bottom: 24.h,
                  ),
                  itemCount: _filteredItems.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark
                        ? Colors.white.withAlpha(13)
                        : Colors.grey[100],
                  ),
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    final label = widget.itemLabel(item);
                    return InkWell(
                      onTap: () {
                        widget.onSelected(item);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 14.h,
                          horizontal: 8.w,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 20.r,
                              color: theme.primaryColor.withAlpha(179),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                label,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 20.r,
                              color: isDark ? Colors.white30 : Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(ThemeData theme, bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(width: 24.w),
              Container(
                width: 16.r,
                height: 16.r,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.r,
              color: Colors.redAccent,
            ),
            SizedBox(height: 16.h),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: Icon(Icons.refresh_rounded, size: 18.r),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48.r,
              color: isDark ? Colors.white30 : Colors.grey[400],
            ),
            SizedBox(height: 12.h),
            Text(
              'No matching items found',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
