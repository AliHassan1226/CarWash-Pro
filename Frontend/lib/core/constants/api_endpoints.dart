// API endpoint definitions

class ApiEndpoints {
  static const String baseUrl = 'https://api.carwashpro.com/api/v1';
  // Local AI backend served by Backend/main.py on LAN.
  static const String aiAgentBaseUrl = 'http://localhost:8000';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String updateProfile = '/auth/profile/update';
  static const String getProfile = '/auth/profile';

  // Customer endpoints
  static const String getServices = '/services';
  static const String getServiceDetail = '/services/:id';
  static const String searchServices = '/services/search';
  static const String placeOrder = '/orders/place';
  static const String getOrders = '/orders/my-orders';
  static const String getOrderDetail = '/orders/:id';
  static const String cancelOrder = '/orders/:id/cancel';
  static const String rateService = '/orders/:id/rate';
  static const String getOrderHistory = '/orders/history';
  static const String trackOrder = '/orders/:id/track';
  static const String getAvailableSlots = '/services/:id/slots';

  // Vendor endpoints
  static const String vendorDashboard = '/vendor/dashboard';
  static const String getVendorOrders = '/vendor/orders';
  static const String updateOrderStatus = '/vendor/orders/:id/status';
  static const String acceptOrder = '/vendor/orders/:id/accept';
  static const String rejectOrder = '/vendor/orders/:id/reject';
  static const String getVendorServices = '/vendor/services';
  static const String createService = '/vendor/services/create';
  static const String updateService = '/vendor/services/:id/update';
  static const String deleteService = '/vendor/services/:id/delete';
  static const String updateAvailability = '/vendor/availability/update';
  static const String getVendorProfile = '/vendor/profile';
  static const String updateVendorProfile = '/vendor/profile/update';
  static const String getVendorReviews = '/vendor/reviews';
  static const String getVendorEarnings = '/vendor/earnings';

  // Admin endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String getAllUsers = '/admin/users';
  static const String getUserDetail = '/admin/users/:id';
  static const String activateUser = '/admin/users/:id/activate';
  static const String deactivateUser = '/admin/users/:id/deactivate';
  static const String getAllOrders = '/admin/orders';
  static const String getOrdersReport = '/admin/orders/report';
  static const String getAllVendors = '/admin/vendors';
  static const String verifyVendor = '/admin/vendors/:id/verify';
  static const String suspendVendor = '/admin/vendors/:id/suspend';
  static const String generateReports = '/admin/reports/generate';

  // Payment endpoints
  static const String createPayment = '/payments/create';
  static const String verifyPayment = '/payments/verify';
  static const String getTransactionHistory = '/payments/transactions';
  static const String refundPayment = '/payments/:id/refund';

  // Location endpoints
  static const String nearbyVendors = '/vendors/nearby';
  static const String vendorLocation = '/vendors/:id/location';
  static const String aiNearbyServices = '/ai/nearby-services';

  static String? get customerServices => null;

  static get customerAddresses => null;

  static String? get customerPaymentHistory => null;

  static get customerBookings => null;

  static get customerVendors => null;

  static get customerWishlist => null;

  static String? get customerBookingHistory => null;

  static String? get customerServicesSearch => null;

  static String? get createOrder => null;

  static get getRefund => null;

  static String? get orderAnalytics => null;

  static String? get vendorServices => null;

  static String? get vendorOrders => null;

  static String? get vendorProfile => null;

  static String? get vendorEarnings => null;

  static String? get vendorEarningsHistory => null;

  static String? get vendorWithdrawal => null;

  static String? get vendorWithdrawalHistory => null;

  static String? get vendorAnalyticsReport => null;

  static String? get vendorReviews => null;

  static String? get adminRevenueAnalytics => null;

  static String? get adminSystemAnalytics => null;

  static String? get adminUsers => null;

  static String? get adminVendors => null;

  static String? get adminOrders => null;

  static String? get adminDisputes => null;

  static String? get adminSettings => null;
}
