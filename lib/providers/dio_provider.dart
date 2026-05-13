import 'package:dio/dio.dart';

class DioProvider {

  //get token
  Future<dynamic> getToken(String username, String password) async {
    try {
      var response = await Dio().post('https://motion-reach-app.yesdemo.co/api/login', data: {
        'username': username,
        'password': password
      });

      if (response.statusCode == 200 && response.data != null) {
        return response.data['token'];
      } else {
        throw Exception('Failed to get token');
      }
    } catch (e) {
      rethrow;
    }
  }
}