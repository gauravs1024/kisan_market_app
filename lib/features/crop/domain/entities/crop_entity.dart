import 'package:equatable/equatable.dart';

class CropFarmerEntity extends Equatable {
  final int id;
  final String fullName;
  final String? profileImageUrl;
  final String? phone;
  final String? city;
  final String? state;
  final String? address;

  const CropFarmerEntity({
    required this.id,
    required this.fullName,
    this.profileImageUrl,
    this.phone,
    this.city,
    this.state,
    this.address,
  });

  @override
  List<Object?> get props => [id, fullName, profileImageUrl, phone, city, state, address];
}

class CropEntity extends Equatable {
  final int id;
  final String name;
  final String localName;
  final int categoryId;
  final String categoryName;
  final String defaultUnit;
  final List<String> imageUrls;
  final double? price;
  final double? msp;
  final CropFarmerEntity? farmer;

  const CropEntity({
    required this.id,
    required this.name,
    required this.localName,
    required this.categoryId,
    required this.categoryName,
    required this.defaultUnit,
    required this.imageUrls,
    this.price,
    this.msp,
    this.farmer,
  });

  double getDisplayMinPrice() {
    if (price != null) return price!;
    // Generate a consistent estimated min price based on id
    return 1500.0 + (id % 7) * 200.0;
  }

  double getDisplayMaxPrice() {
    if (msp != null) return msp!;
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
        price,
        msp,
        farmer,
      ];
}
