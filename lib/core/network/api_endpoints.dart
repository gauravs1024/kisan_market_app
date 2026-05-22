class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://kissanmarket.live/';
  
  // Crops
  static const String crops = 'api/crops';
  static const String searchCrops = 'api/crops/search';
  static const String cropsCategory = 'api/crops-category';
  static String cropDetail(int id) => 'api/crops/$id';

  // Products (Produce Market)
  static const String products = 'products';

  // Auth
  static const String sendOtp = 'auth/send-otp';
  static const String verifyOtp = 'auth/verify-otp';
  static const String logout = 'auth/logout';

  // User Profile
  static const String profile = 'api/user/profile';
}
