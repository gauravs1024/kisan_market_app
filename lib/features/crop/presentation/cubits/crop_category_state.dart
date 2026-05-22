import 'package:equatable/equatable.dart';
import '../../domain/entities/crop_category_entity.dart';

abstract class CropCategoryState extends Equatable {
  const CropCategoryState();

  @override
  List<Object?> get props => [];
}

class CropCategoryInitial extends CropCategoryState {}

class CropCategoryLoading extends CropCategoryState {}

class CropCategoryLoaded extends CropCategoryState {
  final List<CropCategoryEntity> categories;

  const CropCategoryLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CropCategoryError extends CropCategoryState {
  final String message;

  const CropCategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
