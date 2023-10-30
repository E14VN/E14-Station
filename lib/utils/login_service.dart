import 'package:dio/dio.dart';

Future<Map<String, dynamic>> requestLogin(
    String accountName, String password) async {
  var dio = Dio();
  Map<String, dynamic> result = {};
  try {
    result = (await dio.post("https://e14.neursdev.tk/stationLogin/request",
            data: {"accountName": accountName, "password": password},
            options: Options(
                validateStatus: (_) => true,
                sendTimeout: const Duration(seconds: 10))))
        .data;
  } catch (e) {
    result = {"result": false, "reason": "Không thể gửi yêu cầu!"};
  }
  return result;
}
