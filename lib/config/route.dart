import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../view/spalsh_screen.dart';
import '../view/main_shell_screen.dart';
import '../view/auth/login.dart';
import '../view/auth/otpverify.dart';
import '../view/auth/vendor_registration.dart';
import '../view/auth/approval_status_screen.dart';
import '../view/booking/live_booking_sheet_screen.dart';
import '../view/booking/booking_confirmation_screen.dart';
import '../view/booking/active_ride_screen.dart';
import '../view/booking/end_ride_summary_screen.dart';
import '../view/wallet/vendor_wallet_screen.dart';
import '../view/wallet/withdraw_funds_screen.dart';
import '../view/reports/business_reports_screen.dart';
import '../view/chat_screen.dart';
import '../view/support/help_support_screen.dart';

/// Application routing configuration
class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.splashRoute:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppConstants.loginRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppConstants.verificationRoute:
        final phone = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => OtpVerifyScreen(phoneNumber: phone),
          settings: settings,
        );

      case AppConstants.registrationRoute:
        return MaterialPageRoute(
          builder: (_) => const VendorRegistrationScreen(),
          settings: settings,
        );

      case AppConstants.homeRoute:
        return MaterialPageRoute(
          builder: (_) => const MainShellScreen(),
          settings: settings,
        );

      case AppConstants.approvalStatusRoute:
        final args = settings.arguments as Map<String, String>?;
        return MaterialPageRoute(
          builder: (_) => ApprovalStatusScreen(
            applicationId: args?['applicationId'] ?? 'RB-99283',
            submittedDate: args?['submittedDate'] ?? 'Oct 24',
          ),
          settings: settings,
        );

      case AppConstants.liveBookingSheetRoute:
        return MaterialPageRoute(
          builder: (_) => const LiveBookingSheetScreen(),
          settings: settings,
        );

      case AppConstants.bookingConfirmationRoute:
        return MaterialPageRoute(
          builder: (_) => const BookingConfirmationScreen(),
          settings: settings,
        );

      case AppConstants.activeRideRoute:
        return MaterialPageRoute(
          builder: (_) => const ActiveRideScreen(),
          settings: settings,
        );

      case AppConstants.endRideSummaryRoute:
        return MaterialPageRoute(
          builder: (_) => const EndRideSummaryScreen(),
          settings: settings,
        );

      case AppConstants.vendorWalletRoute:
        return MaterialPageRoute(
          builder: (_) => const VendorWalletScreen(),
          settings: settings,
        );

      case AppConstants.withdrawFundsRoute:
        return MaterialPageRoute(
          builder: (_) => const WithdrawFundsScreen(),
          settings: settings,
        );

      case AppConstants.businessReportsRoute:
        return MaterialPageRoute(
          builder: (_) => const BusinessReportsScreen(),
          settings: settings,
        );

      case AppConstants.chatRoute:
        return MaterialPageRoute(
          builder: (_) => const ChatScreen(),
          settings: settings,
        );

      case AppConstants.helpSupportRoute:
        return MaterialPageRoute(
          builder: (_) => const HelpSupportScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }

  // Route names getter for easy access
  static String get splash => AppConstants.splashRoute;
  static String get home => AppConstants.homeRoute;
  static String get login => AppConstants.loginRoute;
  static String get registration => AppConstants.registrationRoute;
  static String get verification => AppConstants.verificationRoute;
  static String get approvalStatus => AppConstants.approvalStatusRoute;
}
