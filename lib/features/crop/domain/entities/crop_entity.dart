import 'package:equatable/equatable.dart';

class CropEntity extends Equatable {
  final int id;
  final String name;
  final String localName;
  final int categoryId;
  final String categoryName;
  final String defaultUnit;
  final List<String> imageUrls;
  final double? minPrice;
  final double? maxPrice;

  const CropEntity({
    required this.id,
    required this.name,
    required this.localName,
    required this.categoryId,
    required this.categoryName,
    required this.defaultUnit,
    required this.imageUrls,
    this.minPrice,
    this.maxPrice,
  });

  double getDisplayMinPrice() {
    if (minPrice != null) return minPrice!;
    // Generate a consistent estimated min price based on id
    return 1500.0 + (id % 7) * 200.0;
  }

  double getDisplayMaxPrice() {
    if (maxPrice != null) return maxPrice!;
    // Generate a consistent estimated max price based on id
    return getDisplayMinPrice() + 300.0 + (id % 5) * 100.0;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        localName,
        categoryId,
        categoryName,
        defaultUnit,
        imageUrls,
        minPrice,
        maxPrice,
      ];
}
