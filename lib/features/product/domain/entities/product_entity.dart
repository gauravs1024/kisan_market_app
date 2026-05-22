import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final double pricePerKg;
  final double quantityAvailable;
  final String unit;
  final String imageUrl;
  final String farmerName;
  final String location;
  final String category;
  final double rating;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.pricePerKg,
    required this.quantityAvailable,
    required this.unit,
    required this.imageUrl,
    required this.farmerName,
    required this.location,
    required this.category,
    required this.rating,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        pricePerKg,
        quantityAvailable,
        unit,
        imageUrl,
        farmerName,
        location,
        category,
        rating,
      ];
}
