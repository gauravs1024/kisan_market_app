import 'package:equatable/equatable.dart';

class CropCategoryEntity extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final bool isActive;

  const CropCategoryEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, isActive];
}
