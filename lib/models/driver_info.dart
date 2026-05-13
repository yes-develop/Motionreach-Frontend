class DriverInfo {
  final String name;
  final String phone;
  final String vehicleType;
  final String vehiclePlate;
  final String region;
  final String status;

  const DriverInfo({
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.region,
    required this.status,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      vehiclePlate: json['vehicle_plate'] ?? '',
      region: json['region'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
