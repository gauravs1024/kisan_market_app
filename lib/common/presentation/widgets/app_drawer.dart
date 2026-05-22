import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../../features/profile/presentation/cubits/profile_cubit.dart';
import '../../../features/profile/presentation/screens/profile_screen.dart';
import '../../../injection_container.dart' as di;
import '../screens/privacy_policy_screen.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onThemeToggle;

  const AppDrawer({super.key, required this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.darkSurface, AppColors.darkBackground]
                      : [AppColors.primary.withAlpha(20), AppColors.primary.withAlpha(5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.eco_rounded, color: AppColors.white, size: 28.r),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Kisan Market',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Farm to Market, Simplified',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            SizedBox(height: 8.h),

            // Theme Toggle
            ListTile(
              leading: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: AppColors.primary,
              ),
              title: Text(isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme'),
              onTap: () {
                Navigator.pop(context);
                onThemeToggle();
              },
            ),

            // Profile
            ListTile(
              leading: Icon(Icons.person_rounded, color: AppColors.primary),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider<ProfileCubit>(
                      create: (_) => di.sl<ProfileCubit>()..fetchProfile(),
                      child: const ProfileScreen(),
                    ),
                  ),
                );
              },
            ),

            // Privacy Policy
            ListTile(
              leading: Icon(Icons.privacy_tip_rounded, color: AppColors.primary),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                );
              },
            ),

            // About
            ListTile(
              leading: Icon(Icons.info_outline_rounded, color: AppColors.primary),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Kisan Market',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2026 Kisan Market. All rights reserved.',
                );
              },
            ),

            const Divider(),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Logout', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout of Kisan Market?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            context.read<AuthCubit>().logout();
                          },
                          child: const Text('Logout', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const Spacer(),

            // Footer
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                '© 2026 Kisan Market',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
