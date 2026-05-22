import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';

class VerifyOtpPage extends StatefulWidget {
  final String phoneNumber;
  final String? otpCode;

  const VerifyOtpPage({
    super.key,
    required this.phoneNumber,
    this.otpCode,
  });

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _otpController = TextEditingController();
  final _formKeyOtp = GlobalKey<FormState>();

  Timer? _resendTimer;
  int _resendSecondsRemaining = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendSecondsRemaining = 30;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendSecondsRemaining > 0) {
            _resendSecondsRemaining--;
          } else {
            _canResend = true;
            _resendTimer?.cancel();
          }
        });
      }
    });
  }

  void _submitOtp() {
    if (_formKeyOtp.currentState!.validate()) {
      final otp = _otpController.text.trim();
      context.read<AuthCubit>().verifyOtp(widget.phoneNumber, otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.r),
          onPressed: () {
            context.read<AuthCubit>().cancelOtpCodeSent();
          },
        ),
        title: Text(
          'Verification',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            // Global listener in main.dart handles clean routing via pushAndRemoveUntil
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            );
          } else if (state is OtpSentState) {
            // Restart resend timer if code is resent
            _startResendTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('OTP code resent successfully'),
                backgroundColor: theme.primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          
          // Get the dynamic OTP code (either from widget constructor or from state)
          String? currentOtp = widget.otpCode;
          if (state is OtpSentState && state.otpCode != null) {
            currentOtp = state.otpCode;
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Form(
                key: _formKeyOtp,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      'Verify Your Number',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter the 6-digit verification code sent to (+91) ${widget.phoneNumber}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // OTP field
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: TextStyle(
                        fontSize: 22.sp, 
                        fontWeight: FontWeight.w900, 
                        letterSpacing: 8.w, 
                        color: theme.colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                      validator: (value) {
                        if (value == null || value.trim().length < 6) {
                          return 'Please enter 6-digit OTP code';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '000000',
                        hintStyle: TextStyle(color: Colors.grey.withAlpha(102), letterSpacing: 8.w),
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
                    SizedBox(height: 16.h),

                    // Dynamic OTP helper banner for testing
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(31),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.amber.withAlpha(77), width: 1.w),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber[800], size: 20.r),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              currentOtp != null && currentOtp.isNotEmpty
                                  ? 'For testing, use OTP: "$currentOtp" to log in.'
                                  : 'Testing mode: Use OTP "123456" to log in.',
                              style: TextStyle(
                                fontSize: 12.sp, 
                                color: Colors.amber[900], 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Verify Button
                    ElevatedButton(
                      onPressed: isLoading ? null : _submitOtp,
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
                              'Verify & Log In',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                            ),
                    ),
                    SizedBox(height: 24.h),

                    // Resend Timer Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the OTP? ",
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                        ),
                        _canResend
                            ? TextButton(
                                onPressed: () {
                                  context.read<AuthCubit>().sendOtp(widget.phoneNumber);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.primaryColor,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  'Resend OTP',
                                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                                ),
                              )
                            : Text(
                                'Resend in ${_resendSecondsRemaining}s',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                      ],
                    ),
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
