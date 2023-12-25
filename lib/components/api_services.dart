// ignore_for_file: avoid_print

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio dio;
  bool isLoggedIn = true;
  bool isRefreshTokenValid = false;
  bool isTokenBeingRefreshed = false;

  ApiService({required this.dio}) {
    if (isLoggedIn) {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          var accessToken = await getAccessTokenFromCache();
          options.headers['Authorization'] = 'Bearer $accessToken';
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            print('Received 401 error, refreshing access token...');

            if (!isTokenBeingRefreshed) {
              isTokenBeingRefreshed = true;
              try {
                final newAccessToken = await gettingAccessToken();
                dio.options.headers["Authorization"] = "Bearer $newAccessToken";
                print('New access token obtained: $newAccessToken');
                isTokenBeingRefreshed = false;
                return handler.resolve(await dio.fetch(error.requestOptions));
              } catch (refreshError) {
                print('Error refreshing access token: $refreshError');
                isTokenBeingRefreshed = false;
                return handler.reject(DioError(requestOptions: error.requestOptions, error: refreshError));
              }
            } else {
              print('Token is already being refreshed, waiting for the new token...');
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ));
    }
  }

  Future<void> checkTokenValidity() async {
    try {
      var refreshToken = await getRefreshTokenFromCache();
      if (refreshToken != null) {
        var response = await dio.post(
          'https://pjhrback.devopspecs.uz/api/token/refresh',
          data: {'refresh': refreshToken},
        );

        if (response.statusCode == 200) {
          isRefreshTokenValid = true;
        } else {
          isRefreshTokenValid = false;
        }
      } else {
        isRefreshTokenValid = false;
      }
    } catch (e) {
      isRefreshTokenValid = false;
    }
  }

  Future<void> login(String username, String password) async {
    var url = 'https://pjhrback.devopspecs.uz/api/token';
    var data = {'username': username, 'password': password};

    var response = await dio.post(url, data: data);
    if (response.statusCode == 200) {
      var refreshToken = response.data['refresh'];
      if (refreshToken != null) {
        await saveRefreshTokenToCache(refreshToken);
        isLoggedIn = true;
      } else {
        throw Exception('Ошибка: Refresh токен равен null');
      }
    } else {
      isLoggedIn = false;
      throw Exception('Ошибка при получении refresh токена. Статус: ${response.statusCode}');
    }
  }

  Future<String> gettingAccessToken() async {
    var refreshToken = await getRefreshTokenFromCache();
    var data = {'refresh': refreshToken};
    var response = await dio.post('https://pjhrback.devopspecs.uz/api/token/refresh/', data: data);

    if (response.statusCode == 200) {
      String accessToken = response.data['access'];
      await saveAccessTokenToCache(accessToken);
      return accessToken;
    } else {
      throw Exception('Ошибка при обновлении токена. Статус: ${response.statusCode}');
    }
  }

  Future<String?> getRefreshTokenFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh');
  }

  Future<void> saveRefreshTokenToCache(String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh', refreshToken);
  }

  Future<void> saveAccessTokenToCache(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('access', accessToken);
  }

  Future<String?> getAccessTokenFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access');
  }

  Future<List<Map<String, dynamic>>> fetchDataFromApi() async {
    var url = 'https://pjhrback.devopspecs.uz/api/application/forms';
    var response = await dio.get(url);

    if (response.statusCode == 200) {
      print('Data from API: ${response.data}');
      return List<Map<String, dynamic>>.from(response.data);
    } else {
      throw Exception('Ошибка при получении данных. Статус: ${response.statusCode}');
    }
  }

  Future<void> updateStatus(int id, String selectedStatus, {DateTime? dateTime}) async {
    String datetimeStatusFlag = "datetime_status_$selectedStatus";
    String sDate = dateTime.toString();

    var url = 'https://pjhrback.devopspecs.uz/api/application/$id';
    var response = await dio.patch(url, data: {
      "status": selectedStatus,
      datetimeStatusFlag: sDate,
    });

    if (response.statusCode != 200) {
      throw Exception('Ошибка при обновлении статуса');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPizzaStores() async {
    try {
      var url = 'https://pjhrback.devopspecs.uz/api/pizza_store';
      var response = await dio.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        List<Map<String, dynamic>> pizzaStoresList = [];

        for (var item in data) {
          pizzaStoresList.add({
            'id': item['id'],
            'name_ru': item['name_ru'],
          });
        }

        return pizzaStoresList;
      } else {
        throw Exception('Ошибка при получении данных. Статус: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }
}
