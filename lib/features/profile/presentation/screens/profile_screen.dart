import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../main.dart';
import '../../../../injection_container.dart' as di;
import '../../data/data_sources/location_service.dart';
import '../../data/models/country_model.dart';
import '../../data/models/state_model.dart';
import '../widgets/location_selector_bottom_sheet.dart';
import '../cubits/profile_cubit.dart';
import '../cubits/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  String? _pickedImagePath;
  String? _selectedCountryName;
  int? _selectedCountryId;

  Future<void> _pickProfileImage() async {
    final image = await ImagePickerHelper.showImageSourceBottomSheet(context);
    if (image != null) {
      setState(() {
        _pickedImagePath = image.path;
      });
    }
  }

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _countryController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _pincodeController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _populateFields(dynamic profile) {
    _nameController.text = profile.fullName ?? '';
    _emailController.text = profile.email ?? '';
    _addressController.text = profile.address ?? '';
    _cityController.text = profile.city ?? '';
    _stateController.text = profile.state ?? '';
    _pincodeController.text = profile.pincode ?? '';
    
    _selectedCountryName ??= 'India';
    _selectedCountryId ??= 101;
    _countryController.text = _selectedCountryName!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdating) {
          final overlayState = navigatorKey.currentState?.overlay;
          if (overlayState != null) {
            LoadingOverlay.show(overlayState, message: 'Saving profile...');
          }
        } else {
          LoadingOverlay.hide();
        }

        if (state is ProfileUpdated) {
          SnackBarUtils.showSuccess(
            context,
            message: 'Profile updated successfully!',
          );
          setState(() {
            _isEditing = false;
            _pickedImagePath = null;
          });
        } else if (state is ProfileLoaded) {
          _populateFields(state.profile);
        } else if (state is ProfileError) {
          SnackBarUtils.showError(
            context,
            message: state.message,
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileInitial || (state is ProfileLoading && !_isEditing)) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        dynamic profile;
        if (state is ProfileLoaded) {
          profile = state.profile;
        } else if (state is ProfileUpdated) {
          profile = state.profile;
        } else {
          // Fallback if state is updating or error but we had a profile loaded
          final cubit = context.read<ProfileCubit>();
          // Safe check
          if (cubit.state is ProfileLoaded) {
            profile = (cubit.state as ProfileLoaded).profile;
          } else if (cubit.state is ProfileUpdated) {
            profile = (cubit.state as ProfileUpdated).profile;
          }
        }

        if (profile == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.r),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('My Profile'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load profile details'),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().fetchProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.r),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _isEditing ? 'Edit Profile' : 'My Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header Section
                  _buildProfileHeader(profile, isDark, theme),
                  SizedBox(height: 24.h),

                  // Editable / Viewable Information Section
                  _buildSectionTitle(context, 'Personal Information', Icons.person_outline),
                  SizedBox(height: 10.h),
                  _buildCardContainer(
                    isDark,
                    children: [
                      _buildTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        enabled: _isEditing,
                        prefixIcon: Icons.badge_outlined,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Name cannot be empty' : null,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        label: 'Email Address',
                        controller: _emailController,
                        enabled: _isEditing,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  _buildSectionTitle(context, 'Address Details', Icons.location_on_outlined),
                  SizedBox(height: 10.h),
                  _buildCardContainer(
                    isDark,
                    children: [
                      _buildTextField(
                        label: 'Street Address',
                        controller: _addressController,
                        enabled: _isEditing,
                        prefixIcon: Icons.home_outlined,
                      ),
                      SizedBox(height: 16.h),
                      _buildSelectionField(
                        label: 'Country',
                        controller: _countryController,
                        enabled: _isEditing,
                        prefixIcon: Icons.public_outlined,
                        onTap: _showCountryPicker,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please select a country' : null,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'City',
                              controller: _cityController,
                              enabled: _isEditing,
                              prefixIcon: Icons.location_city_outlined,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildSelectionField(
                              label: 'State',
                              controller: _stateController,
                              enabled: _isEditing,
                              prefixIcon: Icons.map_outlined,
                              onTap: _showStatePicker,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Please select a state' : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        label: 'Pincode / ZIP Code',
                        controller: _pincodeController,
                        enabled: _isEditing,
                        prefixIcon: Icons.pin_drop_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  _buildSectionTitle(context, 'System & Verification Info', Icons.verified_user_outlined),
                  SizedBox(height: 10.h),
                  _buildCardContainer(
                    isDark,
                    children: [
                      _buildReadOnlyInfoRow('Phone Number', profile.phone, theme),
                      _buildDivider(),
                      _buildReadOnlyInfoRow('User Role', profile.role, theme),
                      _buildDivider(),
                      _buildReadOnlyInfoRow('KYC Verification', profile.kycStatus, theme),
                      _buildDivider(),
                      _buildReadOnlyInfoRow('Account Status', profile.accountStatus, theme),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Actions Group
                  if (!_isEditing)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: Text('Edit Profile', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _populateFields(profile);
                              setState(() {
                                _isEditing = false;
                                _pickedImagePath = null;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text('Cancel', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                  context.read<ProfileCubit>().updateProfile(
                                    fullName: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    address: _addressController.text.trim(),
                                    city: _cityController.text.trim(),
                                    state: _stateController.text.trim(),
                                    pincode: _pincodeController.text.trim(),
                                    imagePath: _pickedImagePath,
                                  );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text('Save Changes', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(dynamic profile, bool isDark, ThemeData theme) {
    final initials = (profile.fullName != null && profile.fullName!.isNotEmpty)
        ? profile.fullName!.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [theme.primaryColor.withAlpha(20), theme.primaryColor.withAlpha(5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(13) : theme.primaryColor.withAlpha(26),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _isEditing ? _pickProfileImage : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 36.r,
                  backgroundColor: theme.primaryColor,
                  backgroundImage: _pickedImagePath != null
                      ? FileImage(File(_pickedImagePath!))
                      : null,
                  child: _pickedImagePath == null
                      ? Text(
                          initials,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 14.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName ?? 'Kisan User',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  profile.phone,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (profile.accountStatus == 'ACTIVE' ? Colors.green : Colors.orange).withAlpha(31),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    (profile.accountStatus ?? 'ACTIVE').toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: (profile.accountStatus == 'ACTIVE' ? Colors.green : Colors.orange),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: Theme.of(context).primaryColor),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer(bool isDark, {required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(13) : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return LocationSelectorBottomSheet<CountryModel>(
          title: 'Select Country',
          loadItems: () => di.sl<LocationService>().getCountries(),
          itemLabel: (country) => country.countryName,
          onSelected: (country) {
            setState(() {
              _selectedCountryName = country.countryName;
              _selectedCountryId = country.id;
              _countryController.text = country.countryName;
              _stateController.clear();
            });
          },
        );
      },
    );
  }

  void _showStatePicker() {
    if (_selectedCountryId == null) {
      SnackBarUtils.showInfo(
        context,
        message: 'Please select a country first',
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return LocationSelectorBottomSheet<StateModel>(
          title: 'Select State',
          loadItems: () => di.sl<LocationService>().getStates(_selectedCountryId!),
          itemLabel: (state) => state.stateName,
          onSelected: (state) {
            setState(() {
              _stateController.text = state.stateName;
            });
          },
        );
      },
    );
  }

  Widget _buildSelectionField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData prefixIcon,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      onTap: onTap,
      validator: validator,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, size: 18.r),
        suffixIcon: enabled ? Icon(Icons.arrow_drop_down, size: 24.r) : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.withAlpha(51)),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, size: 18.r),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.withAlpha(51)),
        ),
      ),
    );
  }

  Widget _buildReadOnlyInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 16.h, thickness: 0.5);
  }
}
