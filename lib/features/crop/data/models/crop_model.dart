import '../../domain/entities/crop_entity.dart';

class CropModel extends CropEntity {
  const CropModel({
    required super.id,
    required super.name,
    required super.localName,
    required super.categoryId,
    required super.categoryName,
    required super.defaultUnit,
    required super.imageUrls,
    super.minPrice,
    super.maxPrice,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) {
    List<String> imgs = [];
    if (json['imageUrls'] != null) {
      if (json['imageUrls'] is List) {
        imgs = (json['imageUrls'] as List).map((e) => e.toString()).toList();
      }
    } else if (json['imageUrl'] != null) {
      imgs = [json['imageUrl'].toString()];
    }

    return CropModel(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      localName: (json['localName'] ?? '') as String,
      categoryId: (json['categoryId'] ?? 0) as int,
      categoryName: (json['categoryName'] ?? '') as String,
      defaultUnit: (json['defaultUnit'] ?? '') as String,
      imageUrls: imgs,
      minPrice: json['minPrice'] != null ? (json['minPrice'] as num).toDouble() : null,
      maxPrice: json['maxPrice'] != null ? (json['maxPrice'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'localName': localName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'defaultUnit': defaultUnit,
      'imageUrls': imageUrls,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
    };
  }
}
