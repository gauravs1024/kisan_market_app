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
  final List<CropEntity> crops;

  const CropLoaded(this.crops);

  @override
  List<Object?> get props => [crops];
}

class CropError extends CropState {
  final String message;

  const CropError(this.message);

  @override
  List<Object?> get props => [message];
}
