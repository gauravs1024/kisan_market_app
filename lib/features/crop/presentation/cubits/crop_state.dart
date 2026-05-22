import 'package:equatable/equatable.dart';
import '../../domain/entities/crop_entity.dart';

abstract class CropState extends Equatable {
  const CropState();

  @override
  List<Object?> get props => [];
}

class CropInitial extends CropState {}

class CropLoading extends CropState {}

class CropLoaded extends CropState {
  final List<CropEntity> allCrops;
  final List<CropEntity> displayCrops;
  final String selectedCategory;
  final String searchQuery;

  const CropLoaded({
    required this.allCrops,
    required this.displayCrops,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  CropLoaded copyWith({
    List<CropEntity>? allCrops,
    List<CropEntity>? displayCrops,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return CropLoaded(
      allCrops: allCrops ?? this.allCrops,
      displayCrops: displayCrops ?? this.displayCrops,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allCrops, displayCrops, selectedCategory, searchQuery];
}

class CropError extends CropState {
  final String message;

  const CropError(this.message);

  @override
  List<Object?> get props => [message];
}
