import '../../domain/entities/crop_category_entity.dart';

class CropCategoryModel extends CropCategoryEntity {
  const CropCategoryModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.isActive,
  });

  factory CropCategoryModel.fromJson(Map<String, dynamic> json) {
    return CropCategoryModel(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? '') as String,
      isActive: (json['isActive'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}
