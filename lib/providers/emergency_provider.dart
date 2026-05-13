import 'package:dio/dio.dart';
import 'package:MotionReach/config/api_config.dart';
import 'package:MotionReach/models/driver_info.dart';

class EmergencyProvider {
  EmergencyProvider._internal();

  static final EmergencyProvider instance = EmergencyProvider._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {'Accept': 'application/json'},
    ),
  );

  Future<DriverInfo?> fetchDriver() async {
    try {
      final response = await _dio.get(
        ApiConfig.fleetDriverEndpoint,
        queryParameters: {'vehicle_plate': ApiConfig.vehiclePlate},
      );
      final data = response.data;
      if (data is Map<String, dynamic> &&
          data['success'] == true &&
          data['driver'] is Map<String, dynamic>) {
        return DriverInfo.fromJson(data['driver']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> sendSos({required String phone}) async {
    try {
      final response = await _dio.post(
        ApiConfig.emergencyEndpoint,
        data: {
          'vehicle_id': ApiConfig.vehiclePlate,
          'passenger_phone': phone,
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
