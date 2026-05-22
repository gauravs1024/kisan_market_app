import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/cache/shared_pref_manager.dart';
import 'core/network/api_client.dart';
import 'features/product/data/data_sources/product_remote_data_source.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/product/domain/usecases/add_product_usecase.dart';
import 'features/product/domain/usecases/get_products_usecase.dart';
import 'features/product/presentation/cubits/product_cubit.dart';
import 'features/crop/data/data_sources/crop_remote_data_source.dart';
import 'features/crop/data/repositories/crop_repository_impl.dart';
import 'features/crop/domain/repositories/crop_repository.dart';
import 'features/crop/domain/usecases/get_crops_usecase.dart';
import 'features/crop/domain/usecases/search_crops_usecase.dart';
import 'features/crop/domain/usecases/get_crop_categories_usecase.dart';
import 'features/crop/domain/usecases/get_crop_by_id_usecase.dart';
import 'features/crop/presentation/cubits/crop_cubit.dart';
import 'features/crop/presentation/cubits/crop_search_cubit.dart';
import 'features/crop/presentation/cubits/crop_category_cubit.dart';
import 'features/crop/presentation/cubits/crop_detail_cubit.dart';
import 'features/auth/data/data_sources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/send_otp_usecase.dart';
import 'features/auth/domain/usecases/verify_otp_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/get_cached_user_usecase.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/profile/data/data_sources/profile_remote_data_source.dart';
import 'features/profile/data/data_sources/location_service.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/cubits/profile_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Product
  // Cubit
  sl.registerFactory(
    () => ProductCubit(
      getProductsUseCase: sl(),
      addProductUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );

  // Features - Crop
  // Cubit
  sl.registerFactory(
    () => CropCubit(
      getCropsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CropSearchCubit(
      searchCropsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CropCategoryCubit(
      getCropCategoriesUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CropDetailCubit(
      getCropByIdUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCropsUseCase(sl()));
  sl.registerLazySingleton(() => SearchCropsUseCase(sl()));
  sl.registerLazySingleton(() => GetCropCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetCropByIdUseCase(sl()));

  // Repository
  sl.registerLazySingleton<CropRepository>(
    () => CropRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CropRemoteDataSource>(
    () => CropRemoteDataSourceImpl(sl()),
  );

  // Features - Auth
  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      sendOtpUseCase: sl(),
      verifyOtpUseCase: sl(),
      logoutUseCase: sl(),
      getCachedUserUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SendOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      sharedPrefManager: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Features - Profile
  // Cubit
  sl.registerFactory(
    () => ProfileCubit(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<LocationService>(
    () => LocationService(sl()),
  );

  // Core
  sl.registerLazySingleton(() => ApiClient(sl(), sl()));
  sl.registerLazySingleton(() => SharedPrefManager(sl()));

  // External
  sl.registerLazySingleton(() => Dio());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
