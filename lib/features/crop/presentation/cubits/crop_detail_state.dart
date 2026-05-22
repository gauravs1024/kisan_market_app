import 'package:equatable/equatable.dart';
import '../../domain/entities/crop_entity.dart';

abstract class CropDetailState extends Equatable {
  const CropDetailState();

  @override
  List<Object?> get props => [];
}

class CropDetailInitial extends CropDetailState {}

class CropDetailLoading extends CropDetailState {}

class CropDetailLoaded extends CropDetailState {
  final CropEntity crop;

  const CropDetailLoaded(this.crop);

  @override
  List<Object?> get props => [crop];
}

class CropDetailError extends CropDetailState {
  final String message;

  const CropDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
