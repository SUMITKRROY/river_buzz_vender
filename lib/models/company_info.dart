/// Company information model for River Buzz Partner App
class CompanyInfo {
  final String id;
  final String name;
  final String businessLicenseNumber;
  final String serviceType; // 'Boat Service' or 'Hotel/Stay'
  final int maxCapacity;
  final double basePrice;
  final String accountHolderName;
  final String accountNumber;
  final String bankName;
  final String status; // 'Pending', 'Reviewing', 'Active', 'Rejected'
  final DateTime submittedDate;
  final String? applicationId;

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
  });

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
    };
  }

  // Create from JSON
  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
