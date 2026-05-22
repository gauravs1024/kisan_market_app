import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/route_transitions.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
import 'verify_otp_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _phoneController = TextEditingController();
  final _formKeyPhone = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submitPhone() {
    if (_formKeyPhone.currentState!.validate()) {
      final phone = _phoneController.text.trim();
      context.read<AuthCubit>().sendOtp(phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is OtpSentState) {
            Navigator.of(context).push(
              RouteTransitions.slide(
                VerifyOtpPage(
                  phoneNumber: state.phoneNumber,
                  otpCode: state.otpCode,
                ),
              ),
            );
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    
                    // Brand / Farming Logo Graphic
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primaryColor.withAlpha(31),
                          border: Border.all(
                            color: theme.primaryColor.withAlpha(61),
                            width: 2.w,
                          ),
                        ),
                        child: Icon(
                          Icons.agriculture_rounded,
                          size: 64.r,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // Brand Name
                    Text(
                      'Kisan Market',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.green[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Direct Farmer-to-Market Portal',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const Spacer(),

                    // Phone form
                    Form(
                      key: _formKeyPhone,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Enter Mobile Number',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'We will send a 6-digit OTP code to verify your account',
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                          SizedBox(height: 20.h),

                          // Phone input field
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            validator: (value) {
                              if (value == null || value.trim().length < 10) {
                                return 'Please enter a valid 10-digit number';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '98765 43210',
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                                child: Text(
                                  '+91  | ',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                              filled: true,
                              fillColor: theme.cardTheme.color,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide(color: Colors.grey.withAlpha(51)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide(color: theme.primaryColor, width: 2.w),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Submit Button
                          ElevatedButton(
                            onPressed: isLoading ? null : _submitPhone,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              elevation: 2,
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 24.h,
                                    width: 24.h,
                                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Text(
                                    'Get OTP Code',
                                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
