import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kisan_market_app/features/crop/presentation/widgets/crop_shimmer_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/crop_entity.dart';
import '../cubits/crop_cubit.dart';
import '../cubits/crop_state.dart';
import '../cubits/crop_search_cubit.dart';
import '../widgets/crop_card.dart';
import '../widgets/crop_list_widgets.dart';
import 'crop_search_screen.dart';
import '../../../../injection_container.dart' as di;

class CropListScreen extends StatefulWidget {
  final VoidCallback onOpenDrawer;

  const CropListScreen({super.key, required this.onOpenDrawer});

  @override
  State<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _shimmerController;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Initial fetch of crops
    context.read<CropCubit>().fetchCrops();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<CropCubit, CropState>(
      builder: (context, state) {
        List<CropEntity> allCrops = [];
        List<String> categories = ['All'];
        List<CropEntity> displayCrops = [];

        if (state is CropLoaded) {
          allCrops = state.crops;

          // Get unique categories dynamically
          final uniqueCats = allCrops
              .map((c) => c.categoryName)
              .toSet()
              .toList();
          categories.addAll(uniqueCats);

          displayCrops = allCrops.where((crop) {
            // Category filter
            final matchesCategory =
                _selectedCategory == 'All' ||
                crop.categoryName.toLowerCase() ==
                    _selectedCategory.toLowerCase();

            // Search text filter
            final query = _searchQuery.toLowerCase();
            final matchesSearch =
                crop.name.toLowerCase().contains(query) ||
                crop.localName.toLowerCase().contains(query) ||
                crop.categoryName.toLowerCase().contains(query);

            return matchesCategory && matchesSearch;
          }).toList();
        }

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                pinned: true,
                snap: true,
                expandedHeight: 120.h,
                backgroundColor: theme.scaffoldBackgroundColor,
                leading: IconButton(
                  icon: Icon(Icons.menu_rounded, size: 24.r),
                  onPressed: widget.onOpenDrawer,
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.search, size: 24.r),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider<CropSearchCubit>(
                            create: (_) => di.sl<CropSearchCubit>(),
                            child: const CropSearchScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 8.w),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Crop Catalog',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22.sp,
                      color: isDark ? AppColors.white : AppColors.primaryDark,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    bottom: 16.h,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Bar
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withAlpha(10),
                              blurRadius: 10.r,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search crops or local names...',
                            prefixIcon: Icon(Icons.search, size: 24.r),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, size: 20.r),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: theme.cardTheme.color,
                            contentPadding: EdgeInsets.symmetric(vertical: 0.h),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Redesigned Category List with images
                    CropCategoryListView(
                      selectedCategory: _selectedCategory,
                      shimmerAnimation: _shimmerController,
                      onCategorySelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ],
            body: RefreshIndicator(
              onRefresh: () => context.read<CropCubit>().fetchCrops(),
              color: AppColors.primary,
              child: Builder(
                builder: (context) {
                  if (state is CropLoading) {
                    return buildShimmerLoading(theme, _shimmerController);
                  } else if (state is CropLoaded) {
                    if (displayCrops.isEmpty) {
                      return const CropEmptyState(
                        text: 'No crops found matching your filters',
                      );
                    }
                    return GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.69,
                      ),
                      itemCount: displayCrops.length,
                      itemBuilder: (context, index) {
                        return CropCard(crop: displayCrops[index]);
                      },
                    );
                  } else if (state is CropError) {
                    return CropErrorState(errorMessage: state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
