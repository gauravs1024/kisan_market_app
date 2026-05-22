import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/routes/route_transitions.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'core/widgets/loading_overlay.dart';
import 'features/product/presentation/cubits/product_cubit.dart';
import 'features/crop/presentation/cubits/crop_cubit.dart';
import 'features/crop/presentation/cubits/crop_category_cubit.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/auth/presentation/cubits/auth_state.dart';
import 'features/auth/presentation/screens/auth_page.dart';
import 'features/product/presentation/screens/home_navigation_hub.dart';
import 'injection_container.dart' as di;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Default to sleek dark mode

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => di.sl<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider<ProductCubit>(
          create: (_) => di.sl<ProductCubit>(),
        ),
        BlocProvider<CropCubit>(
          create: (_) => di.sl<CropCubit>(),
        ),
        BlocProvider<CropCategoryCubit>(
          create: (_) => di.sl<CropCategoryCubit>()..fetchCropCategories(),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) {
          return true; // Listen to all state changes to manage the loading overlay
        },
        listener: (context, state) {
          AppLogger.d('Global AuthState Listener caught state: $state');
          
          // Manage global loading overlay
          if (state is! AuthLoading) {
            LoadingOverlay.hide();
          }

          if (state is AuthLoading) {
            final overlayState = navigatorKey.currentState?.overlay;
            if (overlayState != null) {
              LoadingOverlay.show(overlayState, message: 'Please wait...');
            }
          } else if (state is AuthenticatedState) {
            AppLogger.i('Global AuthState Listener routing to HomeNavigationHub');
            navigatorKey.currentState?.pushAndRemoveUntil(
              RouteTransitions.fade(HomeNavigationHub(onThemeToggle: _toggleTheme)),
              (route) => false,
            );
          } else if (state is UnauthenticatedState) {
            AppLogger.i('Global AuthState Listener routing to AuthPage');
            navigatorKey.currentState?.pushAndRemoveUntil(
              RouteTransitions.fade(const AuthPage()),
              (route) => false,
            );
          }
        },
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              title: 'Kisan Market',
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _themeMode,
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
