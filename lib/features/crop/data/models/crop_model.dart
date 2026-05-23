import '../../domain/entities/crop_entity.dart';

class CropFarmerModel extends CropFarmerEntity {
  const CropFarmerModel({
    required super.id,
    required super.fullName,
    super.profileImageUrl,
    super.phone,
    super.city,
    super.state,
    super.address,
  });

  factory CropFarmerModel.fromJson(Map<String, dynamic> json) {
    return CropFarmerModel(
      id: json['id'] as int,
      fullName: (json['fullName'] ?? '') as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'phone': phone,
      'city': city,
      'state': state,
      'address': address,
    };
  }
}

class CropModel extends CropEntity {
  const CropModel({
    required super.id,
    required super.name,
    required super.localName,
    required super.categoryId,
    required super.categoryName,
    required super.defaultUnit,
    required super.imageUrls,
    super.price,
    super.msp,
    super.farmer,
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

    CropFarmerModel? parsedFarmer;
    if (json['farmer'] != null) {
      parsedFarmer = CropFarmerModel.fromJson(json['farmer'] as Map<String, dynamic>);
    }

    return CropModel(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      localName: (json['localName'] ?? '') as String,
      categoryId: (json['categoryId'] ?? 0) as int,
      categoryName: (json['categoryName'] ?? '') as String,
      defaultUnit: (json['defaultUnit'] ?? '') as String,
      imageUrls: imgs,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      msp: json['msp'] != null ? (json['msp'] as num).toDouble() : null,
      farmer: parsedFarmer,
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
      'price': price,
      'msp': msp,
      'farmer': farmer != null ? (farmer as CropFarmerModel).toJson() : null,
    };
  }
}
