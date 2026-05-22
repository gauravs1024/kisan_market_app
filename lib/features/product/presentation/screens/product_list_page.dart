import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/product_entity.dart';
import '../cubits/product_cubit.dart';
import '../cubits/product_state.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  final VoidCallback onOpenDrawer;

  const ProductListPage({super.key, required this.onOpenDrawer});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _shimmerController;
  String _searchQuery = '';

  final List<String> _categories = ['All', 'Grains', 'Fruits', 'Vegetables', 'Organic'];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    // Initial fetch of products
    context.read<ProductCubit>().fetchProducts();
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

    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {
        if (state is ProductAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.newProduct.name} successfully listed!'),
              backgroundColor: theme.primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          );
        } else if (state is ProductError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          );
        }
      },
      builder: (context, state) {
        // Find selected category
        String selectedCat = 'All';
        List<ProductEntity> displayProducts = [];

        if (state is ProductLoaded) {
          selectedCat = state.selectedCategory;
          displayProducts = state.products.where((p) {
            final nameMatch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
            final farmerMatch = p.farmerName.toLowerCase().contains(_searchQuery.toLowerCase());
            final locMatch = p.location.toLowerCase().contains(_searchQuery.toLowerCase());
            return nameMatch || farmerMatch || locMatch;
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
                actions: const [],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Kisan Market',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22.sp,
                      color: isDark ? Colors.white : Colors.green[900],
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Bar Widget
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 10.r,
                              offset: Offset(0, 4.h),
                            )
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
                            hintText: 'Search wheat, rice, farmers, locations...',
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

                    // Category Chips Bar
                    SizedBox(
                      height: 50.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = cat == selectedCat;
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  _searchController.clear();
                                  _searchQuery = '';
                                  context.read<ProductCubit>().fetchProducts(category: cat);
                                }
                              },
                              selectedColor: theme.primaryColor.withAlpha(51),
                              side: BorderSide(
                                color: isSelected ? theme.primaryColor : Colors.grey.withAlpha(51),
                                width: 1.w,
                              ),
                              labelStyle: TextStyle(
                                color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14.sp,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ],
            body: RefreshIndicator(
              onRefresh: () => context.read<ProductCubit>().fetchProducts(category: selectedCat),
              color: theme.primaryColor,
              child: Builder(
                builder: (context) {
                  if (state is ProductLoading) {
                    return _buildShimmerLoading(theme);
                  } else if (state is ProductLoaded) {
                    if (displayProducts.isEmpty) {
                      return _buildEmptyState(theme, 'No products found');
                    }
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: displayProducts.length,
                      itemBuilder: (context, index) {
                        final product = displayProducts[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            _showProductDetails(context, product);
                          },
                        );
                      },
                    );
                  } else if (state is ProductError) {
                    return _buildErrorState(theme, state.message, selectedCat);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BlocProvider.value(
                  value: context.read<ProductCubit>(),
                  child: AddProductDialog(
                    onSubmit: (newProduct) {
                      context.read<ProductCubit>().addProduct(newProduct);
                    },
                  ),
                ),
              );
            },
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            icon: Icon(Icons.add_shopping_cart, size: 20.r),
            label: Text(
              'Sell Produce',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  // Responsive Shimmer Builder
  Widget _buildShimmerLoading(ThemeData theme) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: 4,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            final opacity = 0.3 + 0.4 * (1.0 - _shimmerController.value);
            return Opacity(
              opacity: opacity,
              child: Card(
                margin: EdgeInsets.only(bottom: 16.h),
                child: SizedBox(
                  height: 160.h,
                  child: Row(
                    children: [
                      Container(
                        width: 120.w,
                        color: Colors.grey[500]!.withAlpha(77),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: 80.w,
                                height: 16.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[500]!.withAlpha(77),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 20.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[500]!.withAlpha(77),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                              Container(
                                width: 150.w,
                                height: 14.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[500]!.withAlpha(77),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 60.w,
                                    height: 24.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[500]!.withAlpha(77),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                  Container(
                                    width: 80.w,
                                    height: 20.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[500]!.withAlpha(77),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_outlined, size: 64.r, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String errorMsg, String category) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.r, color: Colors.redAccent),
            SizedBox(height: 16.h),
            Text(
              errorMsg,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Please check your internet connection and try again.',
              style: TextStyle(color: Colors.grey, fontSize: 13.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProductCubit>().fetchProducts(category: category);
              },
              icon: Icon(Icons.refresh, size: 20.r),
              label: Text('Retry', style: TextStyle(fontSize: 14.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, ProductEntity product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover image
              Expanded(
                child: Stack(
                  children: [
                    Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 16.h,
                      right: 16.w,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withAlpha(128),
                        radius: 20.r,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.white, size: 20.r),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            product.category,
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20.r),
                            SizedBox(width: 4.w),
                            Text(
                              product.rating.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      product.name,
                      style: theme.textTheme.displayLarge?.copyWith(fontSize: 24.sp),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey, size: 16.r),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            '${product.location}  •  By ${product.farmerName}',
                            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price per unit',
                              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                            ),
                            Text(
                              '₹${product.pricePerKg.toStringAsFixed(2)} / ${product.unit}',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(26),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'Available Stock: ${product.quantityAvailable} ${product.unit}',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    ElevatedButton(
                      onPressed: () {
                        // Action to buy or contact farmer
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Contacting ${product.farmerName}...'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: Size.fromHeight(56.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Contact Farmer',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
