import 'package:flutter/material.dart';
import '../models/company_info.dart';

/// Application data and mock data for River Buzz Partner App
class AppData {
  // Mock company information (replace with actual data source)
  static CompanyInfo? currentCompanyInfo;

  // Navigation menu items
  static const List<Map<String, dynamic>> navigationItems = [
    {
      'title': 'Dashboard',
      'icon': Icons.dashboard_outlined,
      'route': '/home',
    },
    {
      'title': 'Bookings',
      'icon': Icons.calendar_today_outlined,
      'route': '/bookings',
    },
    {
      'title': 'Services',
      'icon': Icons.directions_boat_outlined,
      'route': '/services',
    },
    {
      'title': 'Vendor Wallet',
      'icon': Icons.account_balance_wallet_outlined,
      'route': '/vendor-wallet',
    },
    {
      'title': 'Business Reports',
      'icon': Icons.bar_chart_outlined,
      'route': '/business-reports',
    },
    {
      'title': 'Earnings',
      'icon': Icons.attach_money_outlined,
      'route': '/earnings',
    },
    {
      'title': 'Profile',
      'icon': Icons.person_outline,
      'route': '/profile',
    },
    {
      'title': 'Settings',
      'icon': Icons.settings_outlined,
      'route': '/settings',
    },
  ];

  // Service types available
  static const List<String> serviceTypes = [
    'Boat Service',
    'Hotel/Stay',
  ];

  // Common bank names (for dropdown)
  static const List<String> bankNames = [
    'Select your bank',
    'Chase Bank',
    'Bank of America',
    'Wells Fargo',
    'Citibank',
    'US Bank',
    'PNC Bank',
    'Capital One',
    'TD Bank',
    'HSBC Bank',
    'Other',
  ];

  // Country codes for phone number input
  static const List<Map<String, String>> countryCodes = [
    {'code': '+1', 'country': 'United States', 'flag': '🇺🇸'},
    {'code': '+44', 'country': 'United Kingdom', 'flag': '🇬🇧'},
    {'code': '+91', 'country': 'India', 'flag': '🇮🇳'},
    {'code': '+86', 'country': 'China', 'flag': '🇨🇳'},
    {'code': '+81', 'country': 'Japan', 'flag': '🇯🇵'},
    {'code': '+49', 'country': 'Germany', 'flag': '🇩🇪'},
    {'code': '+33', 'country': 'France', 'flag': '🇫🇷'},
    {'code': '+61', 'country': 'Australia', 'flag': '🇦🇺'},
    {'code': '+55', 'country': 'Brazil', 'flag': '🇧🇷'},
    {'code': '+52', 'country': 'Mexico', 'flag': '🇲🇽'},
  ];

  // Sample company info for testing
  static CompanyInfo getSampleCompanyInfo() {
    return CompanyInfo(
      id: '1',
      name: 'River Tours Inc.',
      businessLicenseNumber: 'RB-9928-XY',
      serviceType: 'Boat Service',
      maxCapacity: 12,
      basePrice: 150.0,
      accountHolderName: 'John Doe',
      accountNumber: '1234567890',
      bankName: 'Chase Bank',
      status: 'Reviewing',
      submittedDate: DateTime.now().subtract(const Duration(days: 1)),
      applicationId: 'RB-99283',
    );
  }

  // Dashboard sample data
  static const double todayEarnings = 425.50;
  static const int activeBookings = 4;
  static const String nextEventTime = '2:00 PM';
  static const String earningsTrend = '+12% vs avg';

  // Recent activity items: type (booking|message|payment), title, detail, timeAgo, iconColor (green|blue|orange)
  static const List<Map<String, dynamic>> recentActivityItems = [
    {
      'type': 'booking',
      'title': 'New Booking Confirmed',
      'detail': 'Sunset Cruise • 2 guests • Today 6 PM',
      'timeAgo': '12m ago',
      'iconColor': 'green',
    },
    {
      'type': 'message',
      'title': 'Message from Sarah J.',
      'detail': '"Where exactly do we meet?"',
      'timeAgo': '45m ago',
      'iconColor': 'blue',
    },
    {
      'type': 'payment',
      'title': 'Payment Received',
      'detail': 'Ref: RB-8921 • \$120.00',
      'timeAgo': '2h ago',
      'iconColor': 'orange',
    },
  ];

  // Live Booking Sheet: slots for selected day. Keys: time, isAvailable, isNow; when booked: customerName, bookingId, persons, serviceName, serviceIconKey, statusTag
  static List<Map<String, dynamic>> getBookingSheetSlots(DateTime day) {
    final isWed25 = day.day == 25 && day.month == 10;
    final slots = <Map<String, dynamic>>[
      {'time': '08:00 AM', 'isAvailable': true, 'isNow': false},
      {'time': '09:00 AM', 'isAvailable': true, 'isNow': false},
      {'time': '10:00 AM', 'isAvailable': true, 'isNow': false},
      {'time': '11:00 AM', 'isAvailable': true, 'isNow': isWed25},
      {'time': '12:00 PM', 'isAvailable': true, 'isNow': false},
      {'time': '01:00 PM', 'isAvailable': true, 'isNow': false},
      {'time': '02:00 PM', 'isAvailable': true, 'isNow': false},
    ];
    if (isWed25) {
      slots[1] = {
        'time': '09:00 AM',
        'isAvailable': false,
        'customerName': 'John Smith',
        'bookingId': 'RB-4421',
        'persons': 4,
        'serviceName': 'Standard Kayak Tour',
        'serviceIconKey': 'kayak',
        'statusTag': 'CONFIRMED',
      };
      slots[2] = {
        'time': '10:00 AM',
        'isAvailable': false,
        'customerName': 'Sarah Williams',
        'bookingId': 'RB-4425',
        'persons': 2,
        'serviceName': 'Private Motorboat',
        'serviceIconKey': 'boat',
        'statusTag': 'WAITING',
      };
      slots[4] = {'time': '12:00 PM', 'isAvailable': true, 'isNow': false};
      slots[5] = {
        'time': '01:00 PM',
        'isAvailable': false,
        'customerName': 'Michael Brown',
        'bookingId': 'RB-4430',
        'persons': 6,
        'serviceName': 'River Rafting Adventure',
        'serviceIconKey': 'rafting',
        'statusTag': 'PAID',
      };
      slots[6] = {
        'time': '02:00 PM',
        'isAvailable': false,
        'customerName': 'Emma Davis',
        'bookingId': 'RB-4438',
        'persons': 1,
        'serviceName': 'Solo Kayak Rental',
        'serviceIconKey': 'kayak',
        'statusTag': 'PAID',
      };
    }
    return slots;
  }

  // Vendor Wallet
  static const double totalLifetimeEarnings = 12450.00;
  static const double withdrawableBalance = 840.00;
  static const String walletLastUpdated = '5m ago';

  static const List<Map<String, dynamic>> walletTransactions = [
    {
      'title': 'Sunset River Cruise',
      'detail': 'Booking #RB-9921 • Oct 24, 2023',
      'amount': 120.00,
      'isCredit': true,
      'status': 'Completed',
      'iconKey': 'booking',
    },
    {
      'title': 'Bank Payout',
      'detail': 'Chase Bank • Oct 20, 2023',
      'amount': 500.00,
      'isCredit': false,
      'status': 'Processed',
      'iconKey': 'payout',
    },
    {
      'title': 'Private Kayak Tour',
      'detail': 'Booking #RB-9844 • Oct 18, 2023',
      'amount': 85.50,
      'isCredit': true,
      'status': 'Completed',
      'iconKey': 'booking',
    },
    {
      'title': 'River Fishing Trip',
      'detail': 'Booking #RB-9730 • Oct 15, 2023',
      'amount': 210.00,
      'isCredit': true,
      'status': 'Completed',
      'iconKey': 'booking',
    },
  ];

  // Withdraw screen
  static const String withdrawBankName = 'HDFC Bank';
  static const String withdrawAccountMask = '••••••';
  static const String withdrawAccountType = 'Savings Account';
  static const double withdrawFee = 10.00;
  static const String withdrawTransferNote = 'Transfers to HDFC Bank usually arrive within 2-24 hours. A transaction fee of \$10.00 will be applied.';

  // Business Reports - weekly revenue (Oct 1-7, 2023)
  static const List<double> weeklyRevenueData = [1200, 1450, 1320, 2100, 1800, 2500, 2080];
  static const String weeklyDateRange = 'Oct 1 - Oct 7, 2023';
  static const double weeklyTotalRevenue = 12450.00;
  static const String weeklyRevenueChange = '+12.5%';

  // Business Reports - monthly (sample same total for now)
  static const List<double> monthlyRevenueData = [4200, 4500, 4800, 5200];
  static const String monthlyDateRange = 'Oct 1 - Oct 31, 2023';
  static const double monthlyTotalRevenue = 12450.00;
  static const String monthlyRevenueChange = '+8.2%';

  static const int reportTotalRides = 482;
  static const String reportRidesChange = '+5%';
  static const double reportAvgRating = 4.92;
  static const String reportPeakHours = '2PM-5PM';
  static const double reportNetPayout = 9120.00;

  // Help & Support - FAQ categories
  static const List<Map<String, dynamic>> faqCategories = [
    {
      'id': '1',
      'icon': Icons.attach_money_rounded,
      'title': 'Payment Issues',
      'subtitle': 'Payouts, taxes, and refunds.',
    },
    {
      'id': '2',
      'icon': Icons.build_rounded,
      'title': 'App Troubleshooting',
      'subtitle': 'Error codes and connectivity.',
    },
    {
      'id': '3',
      'icon': Icons.calendar_month_rounded,
      'title': 'Booking Management',
      'subtitle': 'Cancellations and rescheduling.',
    },
  ];

  // Help & Support - recent tickets
  static const List<Map<String, dynamic>> recentTickets = [
    {
      'id': 'TKT-82910',
      'title': 'Delayed Payout - May 15',
      'status': 'OPEN',
      'isResolved': false,
      'lastUpdated': 'Last updated 2h ago',
    },
    {
      'id': 'TKT-82855',
      'title': 'Update Profile Image',
      'status': 'RESOLVED',
      'isResolved': true,
      'lastUpdated': 'Closed May 12, 2024',
    },
  ];

  // Messages: list of conversations for Messages screen
  static const List<Map<String, dynamic>> conversations = [
    {
      'id': '1',
      'name': 'Captain Sarah',
      'avatarUrl': null,
      'lastMessage': 'Can we reschedule the river tour for...',
      'time': '10:45 AM',
      'isOnline': true,
      'isUnread': true,
    },
    {
      'id': '2',
      'name': 'Mark Johnson',
      'avatarUrl': null,
      'lastMessage': 'Thanks for the safety tips! See you then.',
      'time': 'Yesterday',
      'isOnline': false,
      'isUnread': false,
    },
    {
      'id': '3',
      'name': 'River Adventures Co.',
      'avatarUrl': null,
      'lastMessage': 'We have a group of 10 ready for booking.',
      'time': 'Tuesday',
      'isOnline': false,
      'isUnread': false,
    },
    {
      'id': '4',
      'name': 'Alex Miller',
      'avatarUrl': null,
      'lastMessage': 'Where is the best spot for fishing?',
      'time': 'Monday',
      'isOnline': false,
      'isUnread': true,
    },
    {
      'id': '5',
      'name': 'Elena Rodriguez',
      'avatarUrl': null,
      'lastMessage': 'The sunset tour was amazing! Thank you.',
      'time': 'Jun 12',
      'isOnline': false,
      'isUnread': false,
    },
    {
      'id': '6',
      'name': 'David Smith',
      'avatarUrl': null,
      'lastMessage': 'I left my sunglasses on the boat...',
      'time': 'Jun 10',
      'isOnline': false,
      'isUnread': false,
    },
  ];

  // Chat messages for a conversation (e.g. John Doe)
  static const List<Map<String, dynamic>> chatMessagesJohnDoe = [
    {
      'id': '1',
      'isMe': false,
      'text': 'Hi, can you send me a photo of the boat\'s seating area? I want to make sure there\'s enough room for 6 people.',
      'time': '10:24 AM',
      'type': 'text',
    },
    {
      'id': '2',
      'isMe': true,
      'text': 'Sure! Here is the current view of the deck. It easily accommodates 8 people comfortably.',
      'time': '10:25 AM',
      'type': 'text',
      'isRead': true,
    },
    {
      'id': '3',
      'isMe': false,
      'text': 'Looks great! Are you near the north dock? We are arriving in 15 minutes.',
      'time': '10:28 AM',
      'type': 'text',
    },
    {
      'id': '4',
      'isMe': true,
      'text': null,
      'time': '10:25 AM',
      'type': 'image',
      'imageUrl': null,
      'isRead': true,
    },
  ];

  static const List<Map<String, dynamic>> reportRecentActivity = [
    {'type': 'payment', 'title': 'Ride #8291 Payment', 'timeAgo': '2 hours ago', 'amount': 45.00},
    {'type': 'review', 'title': 'New 5-star Review', 'timeAgo': '5 hours ago', 'isStar': true},
  ];

  // Initialize with sample data (for development)
  static void initializeSampleData() {
    currentCompanyInfo = getSampleCompanyInfo();
  }

  // Clear all data
  static void clearData() {
    currentCompanyInfo = null;
  }
}
