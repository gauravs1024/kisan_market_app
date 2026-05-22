import 'package:equatable/equatable.dart';
import '../../domain/entities/crop_entity.dart';

abstract class CropSearchState extends Equatable {
  const CropSearchState();

  @override
  List<Object?> get props => [];
}

class CropSearchInitial extends CropSearchState {}

class CropSearchLoading extends CropSearchState {}

class CropSearchLoaded extends CropSearchState {
  final List<CropEntity> crops;

  const CropSearchLoaded(this.crops);

  @override
  List<Object?> get props => [crops];
}

class CropSearchError extends CropSearchState {
  final String message;

  const CropSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
