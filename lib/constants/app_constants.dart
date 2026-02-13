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
  static const String editPricingRoute = '/profile/edit-pricing';
  static const String editBoatTypesRoute = '/profile/edit-boat-types';
  static const String manageBoatsRoute = '/profile/manage-boats';

  // Service Types
  static const String boatService = 'Boat Service';
  static const String rafting = 'Rafting';

  // Boat registration options
  static const List<String> boatTypes = [
    'Small',
    'Large',
    'Luxury',
    'Event',
    'Sharing',
    'Motor',
    'Non-motor',
  ];
  static const List<String> boatCategories = [
    'Couple',
    'Family',
    'Group',
    'VIP',
  ];
  /// Boat pricing: Hourly, Per Person, Event Package
  static const List<String> boatPricingModels = ['Hourly', 'Per Person', 'Event Package'];
  static const List<String> pricingModels = ['Hourly', 'Per Person'];
  static const int minBoatPhotos = 3;
  /// Boat availability status for list colors
  static const String boatStatusAvailable = 'available';
  static const String boatStatusBooked = 'booked';
  static const String boatStatusPending = 'pending';
  // Sample operating ghats (replace with API/data later)
  static const List<String> operatingGhatsList = [
    'Assi Ghat',
    'Dashashwamedh Ghat',
    'Manikarnika Ghat',
    'Harishchandra Ghat',
    'Panchenko Ghat',
    'Raj Ghat',
    'Shivala Ghat',
    'Tulsi Ghat',
  ];

  // Rafting registration options
  static const List<String> raftTypes = [
    '2-Person',
    '4-Person',
    '6-Person',
    '8-Person',
    'Inflatable',
    'Rigid',
  ];
  static const List<String> raftCategories = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];
  static const List<String> raftDurationOptions = [
    '2 Hours',
    'Half Day',
    'Full Day',
    'Multi-day',
  ];
  static const List<String> raftRiversList = [
    'Ganges',
    'Alaknanda',
    'Bhagirathi',
    'Tons',
    'Yamuna',
    'Rishikesh Stretch',
    'Other',
  ];
  static const List<String> raftPricingModels = ['Per Trip', 'Per Person'];
  static const int minRaftPhotos = 3;

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
