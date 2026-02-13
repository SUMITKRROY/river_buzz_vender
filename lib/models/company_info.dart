import 'vendor_boat.dart';

/// Company information model for River Buzz Partner App
class CompanyInfo {
  final String id;
  final String name;
  final String businessLicenseNumber;
  final String serviceType; // 'Boat Service' or 'Rafting'
  final int maxCapacity;
  final double basePrice;
  final String accountHolderName;
  final String accountNumber;
  final String bankName;
  final String status; // 'Pending', 'Reviewing', 'Active', 'Rejected'
  final DateTime submittedDate;
  final String? applicationId;
  /// Boat types offered (for Boat Service). e.g. ['Small', 'Large']
  final List<String> boatTypes;
  /// Pricing model: 'Hourly' | 'Per Person' (Boat) or 'Per Trip' | 'Per Person' (Rafting)
  final String? pricingModel;
  /// Multiple boats registered by vendor (Boat Service)
  final List<VendorBoat> boats;

  CompanyInfo({
    required this.id,
    required this.name,
    required this.businessLicenseNumber,
    required this.serviceType,
    required this.maxCapacity,
    required this.basePrice,
    required this.accountHolderName,
    required this.accountNumber,
    required this.bankName,
    required this.status,
    required this.submittedDate,
    this.applicationId,
    List<String>? boatTypes,
    this.pricingModel,
    List<VendorBoat>? boats,
  })  : boatTypes = boatTypes ?? const [],
        boats = boats ?? const [];

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'businessLicenseNumber': businessLicenseNumber,
      'serviceType': serviceType,
      'maxCapacity': maxCapacity,
      'basePrice': basePrice,
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'status': status,
      'submittedDate': submittedDate.toIso8601String(),
      'applicationId': applicationId,
      'boatTypes': boatTypes,
      'pricingModel': pricingModel,
      'boats': boats.map((e) => e.toJson()).toList(),
    };
  }

  // Create from JSON
  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    final boatsList = json['boats'];
    return CompanyInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      businessLicenseNumber: json['businessLicenseNumber'] as String,
      serviceType: json['serviceType'] as String,
      maxCapacity: json['maxCapacity'] as int,
      basePrice: (json['basePrice'] as num).toDouble(),
      accountHolderName: json['accountHolderName'] as String,
      accountNumber: json['accountNumber'] as String,
      bankName: json['bankName'] as String,
      status: json['status'] as String,
      submittedDate: DateTime.parse(json['submittedDate'] as String),
      applicationId: json['applicationId'] as String?,
      boatTypes: (json['boatTypes'] as List<dynamic>?)?.cast<String>() ?? [],
      pricingModel: json['pricingModel'] as String?,
      boats: boatsList != null
          ? (boatsList as List<dynamic>)
              .map((e) => VendorBoat.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  // Create a copy with updated fields
  CompanyInfo copyWith({
    String? id,
    String? name,
    String? businessLicenseNumber,
    String? serviceType,
    int? maxCapacity,
    double? basePrice,
    String? accountHolderName,
    String? accountNumber,
    String? bankName,
    String? status,
    DateTime? submittedDate,
    String? applicationId,
    List<String>? boatTypes,
    String? pricingModel,
    List<VendorBoat>? boats,
  }) {
    return CompanyInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      businessLicenseNumber: businessLicenseNumber ?? this.businessLicenseNumber,
      serviceType: serviceType ?? this.serviceType,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      basePrice: basePrice ?? this.basePrice,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      status: status ?? this.status,
      submittedDate: submittedDate ?? this.submittedDate,
      applicationId: applicationId ?? this.applicationId,
      boatTypes: boatTypes ?? this.boatTypes,
      pricingModel: pricingModel ?? this.pricingModel,
      boats: boats ?? this.boats,
    );
  }
}
