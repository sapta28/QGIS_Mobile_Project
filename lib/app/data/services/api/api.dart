class ApiEndpoints {
  ApiEndpoints._();

    static const String baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.253.128.189:8000/api',
    );

  // General
  static const String dashboardData = "$baseUrl/dashboard-data";

  // User auth (public)
  static const String userRegister = "$baseUrl/v1/user/auth/register";
  static const String userLogin = "$baseUrl/v1/user/auth/login";

  // Public user routes
  static const String userSpots = "$baseUrl/v1/user/spots";
  static String userSpotDetail(String id) => "$baseUrl/v1/user/spots/$id";
  static const String userCategories = "$baseUrl/v1/user/categories";

  // Protected user routes
  static const String userMe = "$baseUrl/v1/user/me";
  static const String userUpdateMe = "$baseUrl/v1/user/me";
  static const String userLogout = "$baseUrl/v1/user/logout";
  static const String userDashboardSummary = "$baseUrl/v1/user/dashboard/summary";
  static const String userPaymentChannels = "$baseUrl/v1/user/payment-channels";

  static String userBookSpot(String id) => "$baseUrl/v1/user/spots/$id/book";
  static const String userActivities = "$baseUrl/v1/user/activities";
  static String userActivityDetail(String id) => "$baseUrl/v1/user/activities/$id";
  static String userActivityCancel(String id) =>
      "$baseUrl/v1/user/activities/$id/cancel";

  static String userCompanyDetail(String id) => "$baseUrl/v1/user/companies/$id";
  static String userCompanyUpdate(String id) => "$baseUrl/v1/user/companies/$id";

  // Admin auth
  static const String adminLogin = "$baseUrl/v1/admin/login";
  static const String adminLogout = "$baseUrl/v1/admin/logout";

  // Admin billboards
  static const String adminBillboards = "$baseUrl/v1/admin/billboards";
  static String adminBillboardDetail(String id) =>
      "$baseUrl/v1/admin/billboards/$id";
  static String adminBillboardPhotos(String id) =>
      "$baseUrl/v1/admin/billboards/$id/photos";

  // Admin users
  static const String adminUsers = "$baseUrl/v1/admin/users";
  static String adminUserDetail(String id) => "$baseUrl/v1/admin/users/$id";

  // Admin clients
  static const String adminClients = "$baseUrl/v1/admin/clients";
  static String adminClientDetail(String id) => "$baseUrl/v1/admin/clients/$id";

  // Admin bookings
  static const String adminBookings = "$baseUrl/v1/admin/bookings";
}
