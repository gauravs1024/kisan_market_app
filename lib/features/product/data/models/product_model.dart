import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.pricePerKg,
    required super.quantityAvailable,
    required super.unit,
    required super.imageUrl,
    required super.farmerName,
    required super.location,
    required super.category,
    required super.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      pricePerKg: (json['pricePerKg'] as num).toDouble(),
      quantityAvailable: (json['quantityAvailable'] as num).toDouble(),
      unit: json['unit'] as String,
      imageUrl: json['imageUrl'] as String,
      farmerName: json['farmerName'] as String,
      location: json['location'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pricePerKg': pricePerKg,
      'quantityAvailable': quantityAvailable,
      'unit': unit,
      'imageUrl': imageUrl,
      'farmerName': farmerName,
      'location': location,
      'category': category,
      'rating': rating,
    };
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      pricePerKg: entity.pricePerKg,
      quantityAvailable: entity.quantityAvailable,
      unit: entity.unit,
      imageUrl: entity.imageUrl,
      farmerName: entity.farmerName,
      location: entity.location,
      category: entity.category,
      rating: entity.rating,
    );
  }
}
