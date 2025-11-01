import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather.dart';

class WeatherService {
  // thử cái key mới của bạn
  static const String _owmKey = '40fce4edcdb6f21f1ba8d96812e58442';
  static const String _owmBase =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> getCurrentWeather() async {
    final pos = await _determinePosition();

    // 1. thử OpenWeatherMap trước
    try {
      return await _fetchFromOWM(pos.latitude, pos.longitude);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ OpenWeatherMap fail: $e');
        debugPrint('chuyển sang Open-Meteo cho khỏi ngồi nhìn 401');
      }
      // 2. fallback
      return await _fetchFromOpenMeteo(pos.latitude, pos.longitude);
    }
  }

  Future<Weather> _fetchFromOWM(double lat, double lon) async {
    final url =
        '$_owmBase?lat=$lat&lon=$lon&appid=$_owmKey&units=metric&lang=vi';

    if (kDebugMode) debugPrint('OWM URL: $url');

    final res = await http.get(Uri.parse(url));

    if (kDebugMode) {
      debugPrint('OWM status: ${res.statusCode}');
      debugPrint('OWM body: ${res.body}');
    }

    // nếu vẫn 401 thì quăng để fallback
    if (res.statusCode == 401) {
      throw Exception('OpenWeatherMap từ chối key.');
    }

    if (res.statusCode != 200) {
      throw Exception('OWM lỗi: ${res.statusCode} - ${res.body}');
    }

    final data = jsonDecode(res.body);
    return Weather.fromJson(data);
  }

  Future<Weather> _fetchFromOpenMeteo(double lat, double lon) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true';

    if (kDebugMode) debugPrint('Open-Meteo URL: $url');

    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('Open-Meteo lỗi: ${res.statusCode} - ${res.body}');
    }

    final data = jsonDecode(res.body);
    final current = data['current_weather'];

    return Weather(
      cityName: 'Vị trí hiện tại',
      temperature: (current['temperature'] as num).toDouble(),
      description: 'Mã thời tiết: ${current['weathercode']}',
      humidity: 0,
      windSpeed: (current['windspeed'] as num).toDouble(),
      feelsLike: (current['temperature'] as num).toDouble(),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Dịch vụ vị trí đang tắt. Bật GPS lên.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Bạn đã từ chối quyền vị trí.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Quyền vị trí bị từ chối vĩnh viễn, vào cài đặt để bật lại.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
