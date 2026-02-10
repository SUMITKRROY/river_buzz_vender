/// Application-wide constants for River Buzz Partner App
class AppConstants {
  // App Information
  static const String appName = 'River Buzz';
  static const String appSubtitle = 'PARTNER APP';
  static const String appTagline = "Empowering the world's river services";

  // Route Names
  static const String splashRoute = '/';
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String registrationRoute = '/registration';
  static const String verificationRoute = '/verification';
  static const String approvalStatusRoute = '/approval-status';
  static const String liveBookingSheetRoute = '/live-booking-sheet';
  static const String bookingConfirmationRoute = '/booking-confirmation';
  static const String activeRideRoute = '/active-ride';
  static const String endRideSummaryRoute = '/end-ride-summary';
  static const String vendorWalletRoute = '/vendor-wallet';
  static const String withdrawFundsRoute = '/withdraw-funds';
  static const String businessReportsRoute = '/business-reports';
  static const String chatRoute = '/chat';
  static const String helpSupportRoute = '/help-support';

  // Service Types
  static const String boatService = 'Boat Service';
  static const String hotelStay = 'Hotel/Stay';

  // Status Types
  static const String statusPending = 'Pending';
  static const String statusReviewing = 'Reviewing';
  static const String statusActive = 'Active';
  static const String statusRejected = 'Rejected';

  // Time Constants
  static const int otpExpirySeconds = 45;
  static const int otpResendCooldownSeconds = 60;
  static const int verificationReviewHours = 24; // 24-48 hours

  // Validation
  static const int minMobileNumberLength = 10;
  static const int maxMobileNumberLength = 15;
  static const int minBusinessLicenseLength = 5;
  static const int maxCapacityLimit = 1000;
  static const double minBasePrice = 0.0;
  static const double maxBasePrice = 10000.0;

  // API Endpoints (if needed)
  static const String baseUrl = 'https://api.riverbuzz.com';
  static const String sendOtpEndpoint = '/api/v1/auth/send-otp';
  static const String verifyOtpEndpoint = '/api/v1/auth/verify-otp';
  static const String registerVendorEndpoint = '/api/v1/vendor/register';
  static const String getVendorStatusEndpoint = '/api/v1/vendor/status';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String companyInfoKey = 'company_info';
  static const String isLoggedInKey = 'is_logged_in';

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
