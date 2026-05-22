import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../common/presentation/widgets/app_drawer.dart';
import '../../../crop/presentation/screens/crop_list_screen.dart';
import '../../../profile/presentation/cubits/profile_cubit.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../../injection_container.dart' as di;
import 'product_list_page.dart';

class HomeNavigationHub extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const HomeNavigationHub({super.key, required this.onThemeToggle});

  @override
  State<HomeNavigationHub> createState() => _HomeNavigationHubState();
}

class _HomeNavigationHubState extends State<HomeNavigationHub> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens;

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void initState() {
    super.initState();
    _screens = [
      ProductListPage(onOpenDrawer: _openDrawer),
      CropListScreen(onOpenDrawer: _openDrawer),
      BlocProvider<ProfileCubit>(
        create: (_) => di.sl<ProfileCubit>()..fetchProfile(),
        child: const ProfileScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(onThemeToggle: widget.onThemeToggle),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12.r,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
          unselectedLabelStyle: TextStyle(fontSize: 12.sp),
          iconSize: 24.r,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Produce Market',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco_outlined),
              activeIcon: Icon(Icons.eco),
              label: 'Crop Catalog',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
