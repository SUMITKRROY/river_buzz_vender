/// Availability status for a boat (drives list UI colors)
enum BoatAvailabilityStatus {
  available, // Green
  booked,    // Blue
  pending,   // Orange
}

/// A single boat entry for vendors offering multiple boats
class VendorBoat {
  final String id;
  final String name;
  final String boatType;
  final int capacity;
  final int jacketCount;
  final String boatNumber;
  final List<String> photoUrls;
  /// 'Hourly' | 'Per Person' | 'Event Package'
  final String pricingModel;
  final BoatAvailabilityStatus availabilityStatus;

  const VendorBoat({
    required this.id,
    required this.name,
    required this.boatType,
    required this.capacity,
    this.jacketCount = 0,
    this.boatNumber = '',
    List<String>? photoUrls,
    this.pricingModel = 'Hourly',
    this.availabilityStatus = BoatAvailabilityStatus.available,
  }) : photoUrls = photoUrls ?? const [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'boatType': boatType,
      'capacity': capacity,
      'jacketCount': jacketCount,
      'boatNumber': boatNumber,
      'photoUrls': photoUrls,
      'pricingModel': pricingModel,
      'availabilityStatus': availabilityStatus.name,
    };
  }

  factory VendorBoat.fromJson(Map<String, dynamic> json) {
    final statusStr = json['availabilityStatus'] as String?;
    BoatAvailabilityStatus status = BoatAvailabilityStatus.available;
    if (statusStr != null) {
      switch (statusStr) {
        case 'booked':
          status = BoatAvailabilityStatus.booked;
          break;
        case 'pending':
          status = BoatAvailabilityStatus.pending;
          break;
        default:
          status = BoatAvailabilityStatus.available;
      }
    }
    final photos = json['photoUrls'];
    return VendorBoat(
      id: json['id'] as String,
      name: json['name'] as String,
      boatType: json['boatType'] as String,
      capacity: json['capacity'] as int,
      jacketCount: json['jacketCount'] as int? ?? 0,
      boatNumber: json['boatNumber'] as String? ?? '',
      photoUrls: photos != null
          ? (photos as List<dynamic>).map((e) => e.toString()).toList()
          : [],
      pricingModel: json['pricingModel'] as String? ?? 'Hourly',
      availabilityStatus: status,
    );
  }

  VendorBoat copyWith({
    String? id,
    String? name,
    String? boatType,
    int? capacity,
    int? jacketCount,
    String? boatNumber,
    List<String>? photoUrls,
    String? pricingModel,
    BoatAvailabilityStatus? availabilityStatus,
  }) {
    return VendorBoat(
      id: id ?? this.id,
      name: name ?? this.name,
      boatType: boatType ?? this.boatType,
      capacity: capacity ?? this.capacity,
      jacketCount: jacketCount ?? this.jacketCount,
      boatNumber: boatNumber ?? this.boatNumber,
      photoUrls: photoUrls ?? this.photoUrls,
      pricingModel: pricingModel ?? this.pricingModel,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
    );
  }
}
