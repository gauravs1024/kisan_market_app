import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/crop_category_entity.dart';
import '../../domain/entities/crop_entity.dart';
import '../../domain/repositories/crop_repository.dart';
import '../data_sources/crop_remote_data_source.dart';

class CropRepositoryImpl implements CropRepository {
  final CropRemoteDataSource remoteDataSource;

  CropRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CropEntity>>> getCrops() async {
    try {
      final remoteCrops = await remoteDataSource.getCrops();
      return Right(remoteCrops);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CropEntity>>> searchCrops(String keyword) async {
    try {
      final remoteCrops = await remoteDataSource.searchCrops(keyword);
      return Right(remoteCrops);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CropCategoryEntity>>> getCropCategories() async {
    try {
      final remoteCategories = await remoteDataSource.getCropCategories();
      return Right(remoteCategories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CropEntity>> getCropById(int id) async {
    try {
      final remoteCrop = await remoteDataSource.getCropById(id);
      return Right(remoteCrop);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
